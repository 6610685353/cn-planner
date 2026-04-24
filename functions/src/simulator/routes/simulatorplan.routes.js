/**
 * routes/simulatorplan.routes.js
 *
 * POST   /api/simulatorplan/:uid        → บันทึกแผนเฉพาะ plan_type ที่ส่งมา
 * GET    /api/simulatorplan/:uid        → ดึงแผนของ user (กรองด้วย ?plan_type= ได้)
 * DELETE /api/simulatorplan/:uid        → ลบแผนของ user (กรองด้วย ?plan_type= ได้)
 */

const router = require('express').Router();
const { savePlan, getPlan, deletePlan } = require('../services/simulatorPlanService');

const VALID_PLAN_TYPES = ['Internship', 'Coop', 'Research'];
const VALID_STATUSES = ['pass', 'fail', 'enrolled'];

// ── POST /api/simulatorplan/:uid ─────────────────────────────────────────────
// Body: { plan_type: 'Internship'|'Coop'|'Research', plan: [{ year, semester, subject_id, subject_code, subject_name, credits, status }] }
router.post('/:uid', async (req, res) => {
  const { uid } = req.params;
  const { plan, plan_type } = req.body;

  if (!uid) {
    return res.status(400).json({ success: false, message: 'uid is required' });
  }

  if (!plan_type || !VALID_PLAN_TYPES.includes(plan_type)) {
    return res.status(400).json({
      success: false,
      message: `"plan_type" is required and must be one of: ${VALID_PLAN_TYPES.join(', ')}`,
    });
  }

  if (!Array.isArray(plan)) {
    return res.status(400).json({ success: false, message: '"plan" array is required' });
  }

  // ตรวจ status ต้องเป็น pass, fail, หรือ enrolled เท่านั้น
  const invalid = plan.find((r) => r.status && !VALID_STATUSES.includes(r.status));
  if (invalid) {
    return res.status(400).json({
      success: false,
      message: `Invalid status "${invalid.status}" — must be one of: ${VALID_STATUSES.join(', ')}`,
    });
  }

  try {
    const result = await savePlan(uid, plan, plan_type);
    res.json({ success: true, data: result });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── GET /api/simulatorplan/:uid ──────────────────────────────────────────────
// Query: ?plan_type=Internship (optional — ถ้าไม่ระบุจะดึงทุก plan_type)
router.get('/:uid', async (req, res) => {
  const { uid } = req.params;
  const { plan_type } = req.query;

  if (!uid) {
    return res.status(400).json({ success: false, message: 'uid is required' });
  }

  if (plan_type && !VALID_PLAN_TYPES.includes(plan_type)) {
    return res.status(400).json({
      success: false,
      message: `Invalid plan_type: "${plan_type}". Must be one of: ${VALID_PLAN_TYPES.join(', ')}`,
    });
  }

  try {
    const data = await getPlan(uid, plan_type || null);
    res.json({ success: true, data });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── DELETE /api/simulatorplan/:uid ───────────────────────────────────────────
// Query: ?plan_type=Internship (optional — ถ้าไม่ระบุจะลบทั้งหมด)
router.delete('/:uid', async (req, res) => {
  const { uid } = req.params;
  const { plan_type } = req.query;

  if (!uid) {
    return res.status(400).json({ success: false, message: 'uid is required' });
  }

  if (plan_type && !VALID_PLAN_TYPES.includes(plan_type)) {
    return res.status(400).json({
      success: false,
      message: `Invalid plan_type: "${plan_type}". Must be one of: ${VALID_PLAN_TYPES.join(', ')}`,
    });
  }

  try {
    const result = await deletePlan(uid, plan_type || null);
    res.json({ success: true, data: result });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;