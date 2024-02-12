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
