require('dotenv').config();

const express = require("express");
const app = express();
const PORT = process.env.PORT || 3000;

const userEnrolledRoutes = require("./src/routes/enrolled_routes");

app.use(express.json());

app.use("/api/v1/enrolled", userEnrolledRoutes);

app.use((err, req, res, next) => {
  res.status(500).json({ message: err.message });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`CNplanner server is running on http://localhost:${PORT}`);
});

const gpaRoutes = require("./src/routes/gpa_routes");

app.use("/api/v1/gpa", gpaRoutes);
