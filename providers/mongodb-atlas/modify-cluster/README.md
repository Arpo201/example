# MongoDB Atlas Cluster Automation

## Table of Contents
- [Step 1: Create API Key](#step-1-create-api-key)
- [Step 2: Setup Variables](#step-2-setup-variables)
- [Step 3: Create Reusable Function](#step-3-create-reusable-function)
- [Step 4: Create Trigger Function](#step-4-create-trigger-function)
  - [Pause Cluster](#pause-cluster)
  - [Resume Cluster](#resume-cluster)
- [Logs](#logs)
- [Related Links](#related-links)

## Step 1: Create API Key

**Console location:** Top bar Access Manager → Project Access → Left bar Access Manager → Create Application → API Key

**Description:** [<ENV>] For AtlasPublicKey and AtlasPrivateKey values in project app (Triggers Service)

**Project Permissions:** Project Owner

## Step 2: Setup Variables

**Console location:** Left bar Triggers → Right button View All Apps → Left below Card → Left bar Values → Top right button Create New Value

| Name | Type | Value |
|------|------|-------|
| AtlasProjectID | Value | "<PROJECT_ID>" |
| AtlasPublicKey | Secret | <Provided-by-STEP-1> |
| AtlasPrivateKey | Secret | <Provided-by-STEP-1> |
| AtlasPublicKey | Value | Ref AtlasPublicKey.Secret |
| AtlasPrivateKey | Value | Ref AtlasPrivateKey.Secret |

## Step 3: Create Reusable Function

**Console location:** Left bar Triggers → Right button View All Apps → Left below Card → Left bar Functions → Top right button Create a Function

**Name:** modifyCluster

**Authorization Enable:** Private

```javascript
/*
 * Modifies the cluster as defined by the body parameter. 
 * See https://www.mongodb.com/docs/atlas/reference/api-resources-spec/v2/#tag/Clusters/operation/updateCluster
 *
 */
exports = async function(username, password, projectID, clusterName, body) {
  const arg = { 
    scheme: 'https', 
    host: 'cloud.mongodb.com', 
    path: 'api/atlas/v2/groups/' + projectID + '/clusters/' + clusterName, 
    username: username, 
    password: password,
    headers: {'Accept': ['application/vnd.atlas.2023-11-15+json'], 'Content-Type': ['application/json'], 'Accept-Encoding': ['bzip, deflate']}, 
    digestAuth:true,
    body: JSON.stringify(body)
  };
  // The response body is a BSON.Binary object. Parse it and return.
  response = await context.http.patch(arg);
  return EJSON.parse(response.body.text()); 
};
```

## Step 4: Create Trigger Function

**Console location:** Left bar Triggers → Right button View All Apps

### Pause Cluster

**Name:** WorkdayPauseClustersTrigger | WeekendPauseClustersTrigger

**Trigger Type:** Scheduled

**Schedule:** <up-to-your-requirement> (example: 0 15 * * MON-FRI)

**Set:** projectIDs variable

```javascript
/*
 * Iterates over the provided projects and clusters, pausing those clusters
 */
exports = async function () {
  // Get stored credentials...
  const projectID = context.values.get("AtlasProjectID");
  const username = context.values.get("AtlasPublicKey");
  const password = context.values.get("AtlasPrivateKey");
  // Set desired state...
  const body = { paused: true };
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
  return "Clusters Paused";
};
```

### Resume Cluster

**Name:** WorkdayResumeClustersTrigger | WeekendResumeClustersTrigger

**Trigger Type:** Scheduled

**Schedule:** <up-to-your-requirement> (example: 0 15 * * MON-FRI)

**Set:** projectIDs variable

```javascript
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
```

## Logs

**Console location:** Left bar Triggers → Logs

## Related Links

- [Atlas Cluster Automation Using Scheduled Triggers | MongoDB](https://www.mongodb.com/docs/atlas/triggers/)
- [Atlas Functions - Atlas - MongoDB Docs](https://www.mongodb.com/docs/atlas/app-services/functions/)
- [Context - Atlas - MongoDB Docs](https://www.mongodb.com/docs/atlas/app-services/functions/context/)