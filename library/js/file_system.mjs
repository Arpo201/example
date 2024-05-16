import path from "path"
import { fileURLToPath } from "url"
export const getPath = (importMeta) => {
  /*
  Input:
    importMeta: import.meta
  Output: object
  */
  const __filename = fileURLToPath(importMeta.url)
  const __dirname = path.dirname(__filename)

  return { filename: __filename, dirname: __dirname }
}
