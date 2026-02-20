const express = require("express");
const router = express.Router();
const userEnrolledController = require("../controllers/enrolled_controller");

router.get("/:uid", userEnrolledController.getUserByUid); //get enrolled info
router.get("/subjects", userEnrolledController.getAllSubject); //get all subject to show

module.exports = router;
