const express = require("express");
const app = express();
const port = 4000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/", (req, res) => {
  console.log(req.body);
});

app.post("/hook", (req, res) => {
  console.log(req.body);
  
  return res.status(400).send({"message":"fail"})
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
