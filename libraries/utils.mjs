import Handlebars from "handlebars"
const renderTemplate = async (config, templatePath) => {
  /*
    Input:
      config: Object (Key will be assigned to variable on template file)
      templatePath: String (Path of template)
    Output: string
  */
  const src = await fs.promises.readFile(templatePath, { encoding: "utf-8" })
  const template = Handlebars.compile(src, { noEscape: true })
  const res = template(config)
  return res
}

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
