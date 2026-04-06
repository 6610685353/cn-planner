require('dotenv').config();

const { onRequest } = require("firebase-functions/v2/https")
const express = require("express");
const cors = require("cors");

const app = express();

const userEnrolledRoutes = require("./src/routes/enrolled_routes");
const userRoadmapRoutes = require("./src/routes/roadmap_routes");
const scheduleRoutes = require("./src/routes/schedule_routes");
const gpaRoutes = require("./src/routes/gpa_routes");

app.use(cors({ origin: true }));
app.use(express.json());

app.use("/v1/enrolled", userEnrolledRoutes);
app.use("/v1/roadmap", userRoadmapRoutes);
app.use("/v1/schedule", scheduleRoutes);
app.use("/v1/gpa", gpaRoutes);

app.use((err, req, res, next) => {
  res.status(500).json({ message: err.message });
});

exports.api = onRequest({ region: "asia-southeast1" , secrets: ["SUPABASE_URL", "SUPABASE_ANON_KEY"] }, app);

