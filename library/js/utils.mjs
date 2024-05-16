export const parseJSON = (target) => {
  const targetType = Object.prototype.toString.call(target).toString()
  let jsonObj = {}

  if (targetType.includes("[object String]")) {
    // target: string
    jsonObj = JSON.parse(target)
  }

  if (targetType.includes("[object FormData]")) {
    // target: form
    target.forEach((val, key) => {
      jsonObj[key] = val
    })
  }

  if (targetType.includes("[object Object]")) {
    // target: object
    jsonObj = target
  }

  return jsonObj
}

export const getArgs = (event) => {
  if (Array.isArray(event)) {
    console.log("Event is array payload")
    const args = event
    return args[0]
  }

  if (typeof event?.body == "string") {
    console.log("Event is http payload")
    const args = parseJSON(event?.body)
    if (typeof args != "string") {
      return Array.isArray(args) ? args[0] : args
    }
  }

  if (typeof event?.Records?.[0]?.body == "string") {
    console.log("Event is sqs payload")
    const args = parseJSON(event?.Records[0]?.body)
    if (typeof args != "string") {
      return Array.isArray(args) ? args[0] : args
    }
  }

  if (typeof event?.Records?.body == "string") {
    console.log("Event is sqs object payload")
    const args = parseJSON(event?.Records?.body)
    if (typeof args != "string") {
      return args[0]
    }
  }

  if (!!event.Records[0].Sns.Message) {
    console.log("Event is sns payload")
    const args = parseJSON(event.Records[0].Sns.Message)
    return args
  }

  return event
}
