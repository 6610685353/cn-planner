// require('dotenv').config();

// const { onRequest } = require("firebase-functions/v2/https")
// const express = require("express");
// const cors = require("cors");

// const app = express();

// const userEnrolledRoutes = require("./src/routes/enrolled_routes");
// const userRoadmapRoutes = require("./src/routes/roadmap_routes")

// // ── Simulator routes ──────────────────────────────────
// const curriculumRoutes = require("./src/simulator/routes/curriculum.routes");
// const simulateRoutes   = require("./src/simulator/routes/simulate.routes");
// const savedRoutes      = require("./src/simulator/routes/saved.routes");
// // ─────────────────────────────────────────────────────

// app.use(cors({ origin: true }));
// app.use(express.json());

// app.use("/v1/enrolled", userEnrolledRoutes);
// app.use("/v1/roadmap", userRoadmapRoutes);

// // ── Simulator routes ──────────────────────────────────
// app.use("/v1/curriculum", curriculumRoutes);
// app.use("/v1/simulate",   simulateRoutes);
// app.use("/v1/simulate",   savedRoutes);
// // ─────────────────────────────────────────────────────

// app.use((err, req, res, next) => {
//   res.status(500).json({ message: err.message });
// });

// exports.api = onRequest({ region: "asia-southeast1" , secrets: ["SUPABASE_URL", "SUPABASE_ANON_KEY"] }, app);

// const gpaRoutes = require("./src/routes/gpa_routes");


require('dotenv').config();
const { onRequest } = require("firebase-functions/v2/https");
const express = require("express");
const cors = require("cors");
const { createClient } = require('@supabase/supabase-js');

const app = express();
const supabase = createClient('https://your-project-name.supabase.co', 'your-anon-key');

// ── Simulator routes ──────────────────────────────────
const curriculumRoutes    = require("./src/simulator/routes/curriculum.routes");
const simulateRoutes      = require("./src/simulator/routes/simulate.routes");
const savedRoutes         = require("./src/simulator/routes/saved.routes");
const impactRoutes        = require("./src/simulator/routes/impact.routes");
const simulatorplanRoutes = require("./src/simulator/routes/simulatorplan.routes");
// ─────────────────────────────────────────────────────

// Function to fetch subjects
async function fetchSubjects() {
  const { data, error } = await supabase
    .from('Subjects')
    .select('*');
  if (error) {
    console.error('Error fetching subjects:', error);
  } else {
    return data;
  }
}

// Function to fetch schedules
async function fetchSchedules() {
  const { data, error } = await supabase
    .from('ClassSchedules')
    .select('*');
  if (error) {
    console.error('Error fetching schedules:', error);
  } else {
    return data;
  }
}

// Function to fetch user roadmap
async function fetchUserRoadmap(userId) {
  const { data, error } = await supabase
    .from('UserRoadmap')
    .select('*')
    .eq('user_id', userId);
  if (error) {
    console.error('Error fetching user roadmap:', error);
  } else {
    return data;
  }
}

app.use(cors({ origin: true }));
app.use(express.json());

// ── Simulator routes ──────────────────────────────────
app.use("/v1/curriculum",    curriculumRoutes);
app.use("/v1/simulate",      simulateRoutes);
app.use("/v1/simulate",      savedRoutes);
app.use("/v1/impact",        impactRoutes);
app.use("/v1/simulatorplan", simulatorplanRoutes);
// ─────────────────────────────────────────────────────

app.get("/v1/subjects", async (req, res) => {
  const subjects = await fetchSubjects();
  res.json(subjects);
});

app.get("/v1/schedules", async (req, res) => {
  const schedules = await fetchSchedules();
  res.json(schedules);
});

app.get("/v1/roadmap/:userId", async (req, res) => {
  const { userId } = req.params;
  const roadmap = await fetchUserRoadmap(userId);
  res.json(roadmap);
});

app.use((err, req, res, next) => {
  res.status(500).json({ message: err.message });
});

exports.api = onRequest(
  { region: "asia-southeast1", secrets: ["SUPABASE_URL", "SUPABASE_ANON_KEY"] },
  app,
);