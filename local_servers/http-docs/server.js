const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8888;
const DIR = `${__dirname}/docs`;
const DEBOUNCE_MS = 300;

// --- SSE clients ---
const clients = new Set();

function broadcast(data) {
  const msg = `data: ${JSON.stringify(data)}\n\n`;
  for (const res of clients) {
    res.write(msg);
  }
}

// --- File watcher with debounce ---
let debounceTimer = null;
fs.watch(DIR, (eventType, filename) => {
  if (!filename || !filename.endsWith('.html')) return;
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(() => {
    broadcast({ type: eventType, file: filename });
  }, DEBOUNCE_MS);
});

// --- Helpers ---
function getHtmlFiles() {
  return fs.readdirSync(DIR)
    .filter(f => f.endsWith('.html'))
    .map(f => ({ name: f, mtime: fs.statSync(path.join(DIR, f)).mtimeMs }))
    .sort((a, b) => b.mtime - a.mtime)
    .map(f => f.name);
}

function shellHtml() {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Docs Server</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body { height: 100%; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
  body { display: flex; background: #0d1117; color: #c9d1d9; }

  /* Sidebar */
  #sidebar {
    width: 260px; min-width: 260px;
    background: #161b22;
    border-right: 1px solid #30363d;
    display: flex; flex-direction: column;
    overflow: hidden;
  }
  #sidebar-header {
    padding: 16px;
    border-bottom: 1px solid #30363d;
    display: flex; align-items: center; gap: 10px;
    font-size: 14px; font-weight: 600; color: #e6edf3;
  }
  #status-dot {
    width: 8px; height: 8px; border-radius: 50%;
    background: #3fb950;
    animation: pulse 2s ease-in-out infinite;
  }
  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.4; }
  }
  #status-dot.disconnected { background: #f85149; animation: none; }

  #file-list {
    flex: 1; overflow-y: auto;
    padding: 8px 0;
  }
  .file-entry {
    padding: 10px 16px;
    cursor: pointer;
    font-size: 13px;
    color: #8b949e;
    border-left: 3px solid transparent;
    transition: all 0.15s ease;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .file-entry:hover { background: #1c2128; color: #c9d1d9; }
  .file-entry.active {
    background: #1c2128;
    color: #58a6ff;
    border-left-color: #58a6ff;
    font-weight: 500;
  }

  /* Main area */
  #main { flex: 1; display: flex; flex-direction: column; }
  #main iframe {
    flex: 1; border: none; width: 100%; height: 100%;
    background: #fff;
  }
  #empty-state {
    flex: 1; display: flex; align-items: center; justify-content: center;
    color: #484f58; font-size: 15px;
  }
</style>
</head>
<body>
  <div id="sidebar">
    <div id="sidebar-header">
      <div id="status-dot"></div>
      <span>Docs Server</span>
    </div>
    <div id="file-list"></div>
  </div>
  <div id="main">
    <div id="empty-state">No HTML files found</div>
  </div>

<script>
  const fileList = document.getElementById('file-list');
  const main = document.getElementById('main');
  const statusDot = document.getElementById('status-dot');
  const emptyState = document.getElementById('empty-state');
  let currentFile = null;
  let iframe = null;

  function selectFile(name) {
    currentFile = name;
    document.querySelectorAll('.file-entry').forEach(el => {
      el.classList.toggle('active', el.dataset.file === name);
    });
    if (!iframe) {
      if (emptyState) emptyState.remove();
      iframe = document.createElement('iframe');
      main.appendChild(iframe);
    }
    iframe.src = '/' + encodeURIComponent(name) + '?t=' + Date.now();
  }

  function renderFileList(files, autoSelect) {
    fileList.innerHTML = '';
    if (files.length === 0) {
      if (iframe) { iframe.remove(); iframe = null; }
      if (!document.getElementById('empty-state')) {
        const es = document.createElement('div');
        es.id = 'empty-state';
        es.textContent = 'No HTML files found';
        main.appendChild(es);
      }
      return;
    }
    files.forEach(f => {
      const div = document.createElement('div');
      div.className = 'file-entry' + (f === currentFile ? ' active' : '');
      div.dataset.file = f;
      div.textContent = f.replace('.html', '');
      div.title = f;
      div.onclick = () => selectFile(f);
      fileList.appendChild(div);
    });
    if (autoSelect || !currentFile || !files.includes(currentFile)) {
      selectFile(files[0]);
    }
  }

  async function loadFiles(autoSelect) {
    try {
      const res = await fetch('/api/files');
      const files = await res.json();
      renderFileList(files, autoSelect);
    } catch (e) { console.error('Failed to load file list', e); }
  }

  // SSE connection
  function connectSSE() {
    const es = new EventSource('/events');
    es.onopen = () => { statusDot.classList.remove('disconnected'); };
    es.onmessage = (e) => {
      const data = JSON.parse(e.data);
      if (data.type === 'rename') {
        // New file added or removed — reload list and auto-select newest
        loadFiles(true);
      } else if (data.type === 'change') {
        // File content changed — reload iframe
        if (iframe && currentFile === data.file) {
          iframe.src = '/' + encodeURIComponent(data.file) + '?t=' + Date.now();
        }
        // Also refresh list in case mtime changed sort order
        loadFiles(false);
      }
    };
    es.onerror = () => {
      statusDot.classList.add('disconnected');
      es.close();
      setTimeout(connectSSE, 2000);
    };
  }

  // Init
  loadFiles(true);
  connectSSE();
</script>
</body>
</html>`;
}

// --- HTTP Server ---
const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  const pathname = decodeURIComponent(url.pathname);

  // Shell page
  if (pathname === '/') {
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(shellHtml());
    return;
  }

  // SSE endpoint
  if (pathname === '/events') {
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    });
    res.write(':\n\n'); // heartbeat
    clients.add(res);
    req.on('close', () => clients.delete(res));
    return;
  }

  // File list API
  if (pathname === '/api/files') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(getHtmlFiles()));
    return;
  }

  // Serve static HTML files
  const filename = pathname.slice(1); // remove leading /
  if (!filename.endsWith('.html') || filename.includes('/') || filename.includes('..')) {
    res.writeHead(404);
    res.end('Not found');
    return;
  }

  const filePath = path.join(DIR, filename);
  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404);
      res.end('Not found');
      return;
    }
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(data);
  });
});

server.listen(PORT, () => {
  console.log(`Docs server running at http://localhost:${PORT}`);
  console.log(`Serving HTML files from: ${DIR}`);
  console.log('Press Ctrl+C to stop');
});
