const gpaService = require("../services/gpa_service");

const getGPA = async (req, res, next) => {
  try {
    const { uid , useCache } = req.query;
    const isUsingCache = useCache === 'true';

    const result = await gpaService.getGPA(uid, isUsingCache);

    res.status(200).json(result);
  } catch (err) {
    console.log(`Error getGPA : ${err}`)
    next(err);
  }
};

const getThisSem = async (req, res, next) => {
  try {
    const { uid, useCache } = req.query;
    const isUsingCache = useCache === 'true';
    
    const result = await gpaService.getThisSem(uid, isUsingCache);

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