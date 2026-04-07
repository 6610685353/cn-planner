// /**
//  * routes/saved.routes.js
//  *
//  * POST   /api/simulate/save        →  บันทึก simulation
//  * GET    /api/simulate/saved       →  ดู simulations ทั้งหมด
//  * GET    /api/simulate/saved/:id   →  ดู simulation ตาม id
//  * DELETE /api/simulate/saved/:id   →  ลบ simulation
//  */

// /**
//  * routes/saved.routes.js
//  *
//  * POST   /api/simulate/save        →  บันทึก simulation
//  * GET    /api/simulate/saved       →  ดู simulations ทั้งหมด
//  * GET    /api/simulate/saved/:id   →  ดู simulation ตาม id
//  * DELETE /api/simulate/saved/:id   →  ลบ simulation
//  */

// const router       = require("express").Router();
// const savedService = require("../services/savedService");

// // ── POST /api/simulate/save ─────────────────────────────────────────────────
// router.post("/save", (req, res) => {
//   const { name, outcomes, notes } = req.body;

//   if (!outcomes || Object.keys(outcomes).length === 0) {
//     return res.status(400).json({ success: false, message: '"outcomes" is required' });
//   }

//   const saved = savedService.save({ name, outcomes, notes });
//   res.json({
//     success: true,
//     message: "Simulation saved.",
//     data: { id: saved.id, name: saved.name },
//   });
// });

// // ── GET /api/simulate/saved ─────────────────────────────────────────────────
// router.get("/saved", (req, res) => {
//   res.json({ success: true, data: savedService.getAll() });
// });

// // ── GET /api/simulate/saved/:id ─────────────────────────────────────────────
// router.get("/saved/:id", (req, res) => {
//   const sim = savedService.getById(req.params.id);
//   if (!sim) return res.status(404).json({ success: false, message: "Not found" });
//   res.json({ success: true, data: sim });
// });

// // ── DELETE /api/simulate/saved/:id ──────────────────────────────────────────
// router.delete("/saved/:id", (req, res) => {
//   const ok = savedService.remove(req.params.id);
//   if (!ok) return res.status(404).json({ success: false, message: "Not found" });
//   res.json({ success: true, message: "Deleted." });
// });

// module.exports = router;
/**
 * routes/saved.routes.js
 *
 * POST   /api/simulate/save        →  บันทึก simulation
 * GET    /api/simulate/saved       →  ดู simulations ทั้งหมด
 * GET    /api/simulate/saved/:id   →  ดู simulation ตาม id
 * DELETE /api/simulate/saved/:id   →  ลบ simulation
 */

/**
 * routes/saved.routes.js
 *
 * POST   /api/simulate/save        →  บันทึก simulation
 * GET    /api/simulate/saved       →  ดู simulations ทั้งหมด
 * GET    /api/simulate/saved/:id   →  ดู simulation ตาม id
 * DELETE /api/simulate/saved/:id   →  ลบ simulation
 */

const router       = require("express").Router();
const savedService = require("../services/savedService");

// ── POST /api/simulate/save ─────────────────────────────────────────────────
router.post("/save", (req, res) => {
  const { name, outcomes, notes } = req.body;

  if (!outcomes || Object.keys(outcomes).length === 0) {
    return res.status(400).json({ success: false, message: '"outcomes" is required' });
  }

  const saved = savedService.save({ name, outcomes, notes });
  res.json({
    success: true,
    message: "Simulation saved.",
    data: { id: saved.id, name: saved.name },
  });
});

// ── GET /api/simulate/saved ─────────────────────────────────────────────────
router.get("/saved", (req, res) => {
  res.json({ success: true, data: savedService.getAll() });
});

// ── GET /api/simulate/saved/:id ─────────────────────────────────────────────
router.get("/saved/:id", (req, res) => {
  const sim = savedService.getById(req.params.id);
  if (!sim) return res.status(404).json({ success: false, message: "Not found" });
  res.json({ success: true, data: sim });
});

// ── DELETE /api/simulate/saved/:id ──────────────────────────────────────────
router.delete("/saved/:id", (req, res) => {
  const ok = savedService.remove(req.params.id);
  if (!ok) return res.status(404).json({ success: false, message: "Not found" });
  res.json({ success: true, message: "Deleted." });
});

module.exports = router;
