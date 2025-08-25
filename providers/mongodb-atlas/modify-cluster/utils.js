/*
 * Modifies the cluster as defined by the body parameter.
 * See https://www.mongodb.com/docs/atlas/reference/api-resources-spec/v2/#tag/Clusters/operation/updateCluster
 *
 */
exports = async function (username, password, projectID, clusterName, body) {
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

  // The response body is a BSON.Binary object. Parse it and return.
  response = await context.http.patch(arg);

  return EJSON.parse(response.body.text());
};
