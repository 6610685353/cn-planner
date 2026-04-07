require('dotenv').config();

const { onRequest } = require("firebase-functions/v2/https")
const express = require("express");
const cors = require("cors");

const app = express();

const userEnrolledRoutes = require("./src/routes/enrolled_routes");

// ── Simulator routes ──────────────────────────────────
const curriculumRoutes = require("./src/simulator/routes/curriculum.routes");
const simulateRoutes   = require("./src/simulator/routes/simulate.routes");
const savedRoutes      = require("./src/simulator/routes/saved.routes");
// ─────────────────────────────────────────────────────

app.use(cors({ origin: true }));
app.use(express.json());

app.use("/v1/enrolled", userEnrolledRoutes);

// ── Simulator routes ──────────────────────────────────
app.use("/v1/curriculum", curriculumRoutes);
app.use("/v1/simulate",   simulateRoutes);
app.use("/v1/simulate",   savedRoutes);
// ─────────────────────────────────────────────────────

app.use((err, req, res, next) => {
  res.status(500).json({ message: err.message });
});

exports.api = onRequest({ region: "asia-southeast1" , secrets: ["SUPABASE_URL", "SUPABASE_ANON_KEY"] }, app);

const gpaRoutes = require("./src/routes/gpa_routes");

