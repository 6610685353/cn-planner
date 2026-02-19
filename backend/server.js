const express = require("express");
const userEnrolledRoutes = require("./src/routes/enrolled_routes");
const app = express();
const PORT = 3000;

app.use(express.json());

app.use("/api/v1/enrolled", userEnrolledRoutes);

app.use((err, req, res, next) => {
  res.status(500).json({ message: err.message });
});

app.listen(PORT, () => {
  console.log(`CNplanner server is running on http://localhost:${PORT}`);
});

const gpaRoutes = require("./src/routes/gpa_routes");

app.use("/api/v1/gpa", gpaRoutes);
