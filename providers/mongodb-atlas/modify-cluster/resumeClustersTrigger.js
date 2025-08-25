/*
 * Iterates over the provided projects and clusters, pausing those clusters
 */
exports = async function () {
  // Get stored credentials...
  const projectID = context.values.get("AtlasProjectID");
  const username = context.values.get("AtlasPublicKey");
  const password = context.values.get("AtlasPrivateKey");
  
  // Set desired state...
  const body = { paused: false };
  const projectIDs = [{ id: projectID, names: ["Cluster0"] }];

  // Execute the modification for each cluster in each project...
  var result = "";

  projectIDs.forEach(async function (project) {
    project.names.forEach(async function (cluster) {
      result = await context.functions.execute(
        "modifyCluster",
        username,
        password,
        project.id,
        cluster,
        body
      );
      console.log("Cluster " + cluster + ": " + EJSON.stringify(result));
    });
  });

  return "Clusters Resumed";
};
