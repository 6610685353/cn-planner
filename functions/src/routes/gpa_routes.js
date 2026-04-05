const express = require("express");
const router = express.Router();
const gpaController = require("../controllers/gpa_controller");

router.get("/fetch", gpaController.getGPA);
router.get("/this_sem", gpaController.getThisSem);

module.exports = router;
