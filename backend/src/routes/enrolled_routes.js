const express = require("express");
const router = express.Router();
const userEnrolledController = require("../controllers/enrolled_controller");

router.get("/:uid", userEnrolledController.getUserByUid);
router.post("/:uid", userEnrolledController.addSubject);
router.put("/:uid", userEnrolledController.updateEnrollList);

module.exports = router;
