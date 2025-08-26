/*
 * Modifies the cluster as defined by the body parameter.
 * See https://www.mongodb.com/docs/atlas/reference/api-resources-spec/v2/#tag/Clusters/operation/updateCluster
 *
 */

exports = async function (username, password, projectID, clusterName, body) {
  try {
    const arg = {
      scheme: "https",
      host: "cloud.mongodb.com",
      path: "api/atlas/v2/groups/" + projectID + "/clusters/" + clusterName,
      username: username,
      password: password,
      headers: {
        Accept: ["application/vnd.atlas.2023-11-15+json"],
        "Content-Type": ["application/json"],
        "Accept-Encoding": ["bzip, deflate"],
      },
      digestAuth: true,
      body: JSON.stringify(body),
    };

    const response = await context.http.patch(arg);

    if (response.statusCode !== 200) {
      const errorBody = JSON.parse(response.body.text());
      console.error(`Error: ${errorBody.detail || errorBody.error}`);
      return { error: true, message: errorBody.detail || errorBody.error };
    }

    return EJSON.parse(response.body.text());
  } catch (error) {
    console.error("Function error:", error.message);
    return { error: true, message: error.message };
  }
};
