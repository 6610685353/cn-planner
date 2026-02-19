const express = require("express");
const router = express.Router();
const userEnrolledController = require("../controllers/enrolled_controller");

router.get("/:uid", userEnrolledController.getUserByUid); //get enrolled info
router.post("/:uid", userEnrolledController.addSubject); //post new enrolled subject to database
router.put("/:uid", userEnrolledController.updateEnrollList); //update enrolled subject to database

module.exports = router;
