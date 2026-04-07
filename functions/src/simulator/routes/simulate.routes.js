// // const router   = require("express").Router();
// // const COURSES  = require("../data/courses");
// // const SCHEDULE = require("../data/schedule");
// // const { runSimulation }  = require("../services/simulatorService");
// // const { findConflicts }  = require("../services/scheduleService");

// // // ── POST /api/simulate ──────────────────────────────────────────────────────
// // router.post("/", (req, res) => {
// //   const { outcomes, simulatedTerms, customCourses } = req.body;

// //   if (!outcomes || typeof outcomes !== "object") {
// //     return res.status(400).json({ success: false, message: '"outcomes" object is required' });
// //   }

// //   const result = runSimulation(outcomes, customCourses || {}, simulatedTerms || null);
// //   res.json({ success: true, data: result });
// // });

// // // ── POST /api/simulate/check-schedule ──────────────────────────────────────
// // router.post("/check-schedule", (req, res) => {
// //   const { courses } = req.body;

// //   if (!Array.isArray(courses) || courses.length === 0) {
// //     return res.status(400).json({ success: false, message: '"courses" array is required' });
// //   }

// //   const raw       = findConflicts(courses);
// //   const conflicts = raw.map(({ courseA, courseB }) => ({
// //     courseA: { code: courseA, name: COURSES[courseA]?.name || courseA, schedule: SCHEDULE[courseA] || [] },
// //     courseB: { code: courseB, name: COURSES[courseB]?.name || courseB, schedule: SCHEDULE[courseB] || [] },
// //   }));

// //   res.json({ success: true, data: { hasConflict: conflicts.length > 0, conflicts } });
// // });

// // module.exports = router;
// const router   = require("express").Router();
// const COURSES  = require("../data/courses");
// const SCHEDULE = require("../data/schedule");
// const { runSimulation }  = require("../services/simulatorService");
// const { findConflicts }  = require("../services/scheduleService");

// // ── POST /api/simulate ──────────────────────────────────────────────────────
// router.post("/", (req, res) => {
//   const { outcomes, simulatedTerms, simulatedCurrentTerm, customCourses } = req.body;

//   if (!outcomes || typeof outcomes !== "object") {
//     return res.status(400).json({ success: false, message: '"outcomes" object is required' });
//   }

//   const result = runSimulation(outcomes, customCourses || {}, simulatedTerms || null, simulatedCurrentTerm || null);
//   res.json({ success: true, data: result });
// });

// // ── POST /api/simulate/check-schedule ──────────────────────────────────────
// router.post("/check-schedule", (req, res) => {
//   const { courses } = req.body;

//   if (!Array.isArray(courses) || courses.length === 0) {
//     return res.status(400).json({ success: false, message: '"courses" array is required' });
//   }

//   const raw       = findConflicts(courses);
//   const conflicts = raw.map(({ courseA, courseB }) => ({
//     courseA: { code: courseA, name: COURSES[courseA]?.name || courseA, schedule: SCHEDULE[courseA] || [] },
//     courseB: { code: courseB, name: COURSES[courseB]?.name || courseB, schedule: SCHEDULE[courseB] || [] },
//   }));

//   res.json({ success: true, data: { hasConflict: conflicts.length > 0, conflicts } });
// });

// module.exports = router;
const router   = require("express").Router();
const COURSES  = require("../data/courses");
const SCHEDULE = require("../data/schedule");
const { runSimulation }  = require("../services/simulatorService");
const { findConflicts }  = require("../services/scheduleService");

// ── POST /api/simulate ──────────────────────────────────────────────────────
router.post("/", (req, res) => {
  console.log("SIMULATE BODY =", JSON.stringify(req.body, null, 2));

  const { outcomes, simulatedTerms, customCourses, simulatedCurrentTerm } = req.body;

  console.log(
    "SIMULATE parsed =",
    JSON.stringify(
      {
        outcomes,
        simulatedTerms,
        customCourses,
        simulatedCurrentTerm,
      },
      null,
      2,
    ),
  );

  if (!outcomes || typeof outcomes !== "object") {
    return res
      .status(400)
      .json({ success: false, message: '"outcomes" object is required' });
  }

  const result = runSimulation(
    outcomes,
    customCourses || {},
    simulatedTerms || null,
    simulatedCurrentTerm || null,
  );

  console.log(
    "EFFECTIVE CURRENT TERM =",
    JSON.stringify(result?.effectiveCurrentTerm || null, null, 2),
  );
  console.log("CURRENT YEAR =", result?.effectiveCurrentTerm?.year ?? null);
  console.log("CURRENT TERM =", result?.effectiveCurrentTerm?.term ?? null);

  res.json({ success: true, data: result });
});

// ── POST /api/simulate/check-schedule ──────────────────────────────────────
router.post("/check-schedule", (req, res) => {
  const { courses } = req.body;

  if (!Array.isArray(courses) || courses.length === 0) {
    return res
      .status(400)
      .json({ success: false, message: '"courses" array is required' });
  }

  const raw = findConflicts(courses);
  const conflicts = raw.map(({ courseA, courseB }) => ({
    courseA: {
      code: courseA,
      name: COURSES[courseA]?.name || courseA,
      schedule: SCHEDULE[courseA] || [],
    },
    courseB: {
      code: courseB,
      name: COURSES[courseB]?.name || courseB,
      schedule: SCHEDULE[courseB] || [],
    },
  }));

  res.json({
    success: true,
    data: {
      hasConflict: conflicts.length > 0,
      conflicts,
    },
  });
});

module.exports = router;
