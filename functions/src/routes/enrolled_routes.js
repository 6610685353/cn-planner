const express = require("express");
const router = express.Router();
const userEnrolledController = require("../controllers/enrolled_controller");

//new
router.get("/manage", userEnrolledController.getPageData); //get Manage page data
router.get("/manage/:uid", userEnrolledController.getUserData); //get Enrolled data
router.get("/gpa/:uid", userEnrolledController.getCurSemData); //get Current semester data
router.get("/all_enrolled/", userEnrolledController.getAllEnrolled); // get user all enrolled

router.post("/submit", userEnrolledController.submitGrade); //rebuild in future

module.exports = router;
