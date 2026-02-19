const express = require("express");
const router = express.Router();
const gpaController = require("../controllers/gpa_controller");

router.get("/:uid", gpaController.getGPA);

module.exports = router;
