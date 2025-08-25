import { TranscoderServiceClient } from "@google-cloud/video-transcoder"

export const getInfo = {
  pubsub(cloudEvent) {
    return cloudEvent.data.message.data
  },
  transcoderJob(data) {
    return {
      state: data.state,
      source: data.config.inputs[0].uri || null,
      destination: data.config.output.uri || null,
      createTime: data.createTime,
      startTime: data.startTime,
      endTime: data.endTime,
    }
  }
}

export const gcp = {
  async getTranscoderJob(jobName) {
    const transcoderClient = new TranscoderServiceClient()
    const jobData = await transcoderClient.getJob({ name: jobName })
    return jobData[0]
  },
}
