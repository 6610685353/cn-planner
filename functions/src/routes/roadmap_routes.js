const express = require("express");
const router = express.Router();
const userRoadmapController = require("../controllers/roadmap_controller");

router.post("/submit", userRoadmapController.submitGrade);

module.exports = router;