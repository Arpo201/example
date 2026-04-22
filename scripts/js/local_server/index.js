const express = require("express");
const app = express();
const port = 8888;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/", (req, res) => {
  console.log(req.body);
  return res.status(200).send(req.body);
});
app.post("/", (req, res) => {
  console.log(req.body);
  console.log(req.headers);
  return res.status(200).send(req.body);
});

app.post("/fail", (req, res) => {
  console.log(req.body);
  return res.status(400).send({ message: "fail" });
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
