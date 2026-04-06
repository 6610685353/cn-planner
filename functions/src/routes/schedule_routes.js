const express = require("express");
const router = express.Router();
const scheduleController = require("../controllers/schedule_controller");

router.get("/:uid", scheduleController.getUserSchedule);

module.exports = router;
