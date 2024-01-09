import * as functions from "@google-cloud/functions-framework"

functions.cloudEvent("main", async (cloudEvent) => {
  console.log(cloudEvent)
})