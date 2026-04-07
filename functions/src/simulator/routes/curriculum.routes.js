// /**
//  * routes/curriculum.routes.js
//  * GET /api/curriculum  →  ข้อมูลหลักสูตรทั้งหมด
//  */

// const router   = require("express").Router();
// const COURSES  = require("../data/courses");
// const SCHEDULE = require("../data/schedule");
// const { TERMS, DEFAULT_OUTCOMES } = require("../data/terms");

// router.get("/", (req, res) => {
//   const data = TERMS.map((term) => ({
//     year:  term.year,
//     term:  term.term,
//     label: `Year ${term.year} / Term ${term.term}`,
//     courses: term.courses.map((code) => ({
//       ...(COURSES[code] ?? { code, name: code, credits: 0, prerequisites: [], type: "core" }),
//       schedule:       SCHEDULE[code] ?? [],
//       defaultOutcome: DEFAULT_OUTCOMES[code] ?? "notSet",
//     })),
//   }));

//   res.json({ success: true, data });
// });

// module.exports = router;
/**
 * routes/curriculum.routes.js
 * GET /api/curriculum  →  ข้อมูลหลักสูตรทั้งหมด
 */

const router   = require("express").Router();
const COURSES  = require("../data/courses");
const SCHEDULE = require("../data/schedule");
const { TERMS, DEFAULT_OUTCOMES } = require("../data/terms");

router.get("/", (req, res) => {
  const data = TERMS.map((term) => ({
    year:  term.year,
    term:  term.term,
    label: `Year ${term.year} / Term ${term.term}`,
    courses: term.courses.map((code) => ({
      ...(COURSES[code] ?? { code, name: code, credits: 0, prerequisites: [], type: "core" }),
      schedule:       SCHEDULE[code] ?? [],
      defaultOutcome: DEFAULT_OUTCOMES[code] ?? "notSet",
    })),
  }));

  res.json({ success: true, data });
});

module.exports = router;