require('dotenv').config();

const { onRequest } = require("firebase-functions/v2/https")
const express = require("express");
const cors = require("cors");

const app = express();

const userEnrolledRoutes = require("./src/routes/enrolled_routes");

app.use(cors({ origin: true }));
app.use(express.json());

app.use("/api/v1/enrolled", userEnrolledRoutes);

app.use((err, req, res, next) => {
  res.status(500).json({ message: err.message });
});

exports.api = onRequest(app);

const gpaRoutes = require("./src/routes/gpa_routes");

