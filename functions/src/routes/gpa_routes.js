const express = require("express");
const router = express.Router();
const gpaController = require("../controllers/gpa_controller");

router.get("/:uid", gpaController.getGPA);
router.get("/init/:uid", gpaController.getInitialData);

module.exports = router;
