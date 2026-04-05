const gpaService = require("../services/gpa_service");

const getGPA = async (req, res, next) => {
  try {
    const { uid } = req.query;

    const result = await gpaService.getGPA(uid);

    res.status(200).json(result);
  } catch (err) {
    console.log(`Error getGPA : ${err}`)
    next(err);
  }
};

const getThisSem = async (req, res, next) => {
  try {
    const { uid } = req.query;
    
    const result = await gpaService.getThisSem(uid);

    res.status(200).json(result);
  } catch (err) {
    console.log(`Error getThisSem : ${err}`);
    next(err);
  }
}

module.exports = {
  getGPA,
  getThisSem,
}