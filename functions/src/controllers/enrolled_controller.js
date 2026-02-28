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
  console.log("call submit Controller");
  
  try {
    const { uid , gradeList } = req.body;

    if (!uid || !Array.isArray(gradeList)) {
      return res.status(400).json({ message : "Invalid data" });
    }

    console.log("Body",req.body);

    await enrolledService.updateGrade(uid, gradeList);
    console.log("controller updated")
    res.status(200).json({ message: "Submit successful"});
  } catch (err) {
    res.status(500).json({ error: err.message});
  }
};

module.exports = {
  getUserData,
  getPageData,
  submitGrade,
}
