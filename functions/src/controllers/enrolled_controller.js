const enrolledService = require('../services/enrolled_service')

//GET
const getUserData = async (req, res) => {
  const { uid } = req.params;

  if (!uid) {
    return res.status(400).json({ message : "error" });
  }

  try {
    const data = await enrolledService.getUserData(uid);
    res.json(data);
  } catch (err) {
    console.log("get user data error : ", err);
  }
}

const getPageData = async (req, res) => {
  try {
    const data = await enrolledService.getPageData();
    res.json(data);
  } catch (err) {
    console.log("get page data error : ", err);
  }
}


//POST
const submitGrade = async (req, res) => {
  try {
    const { uid , enrolledSubjects } = req.body;

    console.log("Body",req.body);

    const result = await enrolledService.updateGrade(uid, enrolledSubjects);

    res.status(200).json(result);
  } catch (err) {
    console.log("submit Error : ", err)
  }
}

module.exports = {
  getUserData,
  getPageData,
  submitGrade,
}
