/**
 * routes/simulatorplan.routes.js
 *
 * POST   /api/simulatorplan/:uid        → บันทึกแผนทั้งหมด
 * GET    /api/simulatorplan/:uid        → ดึงแผนของ user
 * DELETE /api/simulatorplan/:uid        → ลบแผนของ user
 */

const router = require('express').Router();
const { savePlan, getPlan, deletePlan } = require('../services/simulatorPlanService');

// ── POST /api/simulatorplan/:uid ─────────────────────────────────────────────
// Body: { plan: [{ year, semester, subject_id, subject_code, status }] }
router.post('/:uid', async (req, res) => {
  const { uid } = req.params;
  const { plan } = req.body;

  if (!uid) {
    return res.status(400).json({ success: false, message: 'uid is required' });
  }

  if (!Array.isArray(plan)) {
    return res.status(400).json({ success: false, message: '"plan" array is required' });
  }

  // ตรวจ status ต้องเป็นค่าที่กำหนดเท่านั้น
  // 'pass' | 'fail'     → ผลการเรียน
  // 'enrolled'          → วิชาที่อยู่ใน term แต่ยังไม่ตัดสิน (add มาหรือ notSet)
  const VALID_STATUSES = ['pass', 'fail', 'enrolled'];
  const invalid = plan.find((r) => r.status && !VALID_STATUSES.includes(r.status));
  if (invalid) {
    return res.status(400).json({
      success: false,
      message: `Invalid status "${invalid.status}" — must be one of: ${VALID_STATUSES.join(', ')}`,
    });
  }

  try {
    const result = await savePlan(uid, plan);
    res.json({ success: true, data: result });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── GET /api/simulatorplan/:uid ──────────────────────────────────────────────
router.get('/:uid', async (req, res) => {
  const { uid } = req.params;

  if (!uid) {
    return res.status(400).json({ success: false, message: 'uid is required' });
  }

  try {
    const data = await getPlan(uid);
    res.json({ success: true, data });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── DELETE /api/simulatorplan/:uid ───────────────────────────────────────────
router.delete('/:uid', async (req, res) => {
  const { uid } = req.params;

  if (!uid) {
    return res.status(400).json({ success: false, message: 'uid is required' })
  }

  try {
    const result = await deletePlan(uid);
    res.json({ success: true, data: result });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

const { runSimulation } = require('../services/simulatorService');

// ── POST /v1/simulate ────────────────────────────────────────────────────────
// Body: {
//   outcomes             : { [subject_code]: "pass" | "fail" | "enrolled" },
//   simulatedTerms       : [{ year, term, status, courses: [...] }],
//   simulatedCurrentTerm : { year, term },   // optional
//   customCourses        : { [subject_code]: { ... } }  // optional
// }
router.post('/', (req, res) => {
  const {
    outcomes = {},
    customCourses = {},
    simulatedTerms = null,
    simulatedCurrentTerm = null,
  } = req.body;

  try {
    const result = runSimulation(
      outcomes,
      customCourses,
      simulatedTerms,
      simulatedCurrentTerm,
    );
    res.json({ success: true, data: result });
  } catch (err) {
    console.error('simulate error:', err.message);
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
