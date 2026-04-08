/**
 * routes/impact.routes.js
 *
 * GET /api/impact/:uid
 *   → วิเคราะห์ผลกระทบจากวิชาที่สอบตก ดึงข้อมูลจาก Supabase
 *   → คืน structured JSON + rawText ตาม format ใน prompt.txt
 */

const router = require('express').Router();
const { runImpactAnalysis } = require('../services/impactAnalysisService');

router.get('/:uid', async (req, res) => {
  const { uid } = req.params;

  if (!uid) {
    return res.status(400).json({ success: false, message: 'uid is required' });
  }

  try {
    const result = await runImpactAnalysis(uid);
    res.json({ success: true, data: result });
  } catch (err) {
    console.error('impact analysis error:', err.message);
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
