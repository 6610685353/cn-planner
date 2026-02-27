const gpaService = require("../services/gpa_service");

exports.getGPA = async (req, res, next) => {
  try {
    const { uid } = req.params;

    const result = await gpaService.calculateGPA(uid);

    res.status(200).json(result);
  } catch (error) {
    next(error);
  }
};
