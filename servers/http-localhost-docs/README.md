# Docs Server

Live HTML viewer with sidebar navigation and auto-refresh. Zero dependencies — Node.js built-in modules only.

## Quick Start

```bash
cd ~/Documents/http-localhost-docs
node server.js
```

Open **http://localhost:8888**

## Features

- Dark sidebar listing all `.html` files, sorted newest first
- Full-height iframe to view selected file
- SSE-based live reload — new/changed files refresh automatically
- Green pulsing dot = connected, red = disconnected (auto-reconnects)

## Auto-Start on Login

A macOS LaunchAgent is installed at:

```
~/Library/LaunchAgents/com.sd-mac-23.docs-server.plist
```

### Manage the service

```bash
# Check status
launchctl list | grep docs-server

# Stop
launchctl unload ~/Library/LaunchAgents/com.sd-mac-23.docs-server.plist

# Start
launchctl load ~/Library/LaunchAgents/com.sd-mac-23.docs-server.plist

# Restart (stop + start)
launchctl unload ~/Library/LaunchAgents/com.sd-mac-23.docs-server.plist
launchctl load ~/Library/LaunchAgents/com.sd-mac-23.docs-server.plist
```

### Logs

```bash
tail -f /tmp/docs-server.log
tail -f /tmp/docs-server.err
```

## Adding Files

Drop any `.html` file into `~/Documents/http-localhost-docs/` — it appears in the sidebar instantly.

## Shell Alias

Add to `~/.zshrc`:

```bash
alias docs='open http://localhost:8888'
```

Then reload:

```bash
source ~/.zshrc
```

Now run `docs` to open the server in your browser.
