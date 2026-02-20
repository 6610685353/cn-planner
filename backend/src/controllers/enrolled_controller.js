const enrolledService = require('../services/enrolled_service')

const getUserByUid = async (req, res) => {
  const { uid } = req.params;

  if (!uid) {
    return res.status(400).json({ message: "uid is required"});
  }

  const enrollment = await enrolledService.getUserByUid(uid);
  res.json(enrollment);
}

const getAllSubject = async (req, res) => {
  const subjects = await enrolledService.getAllSubject();
  res.json(subjects);
}

const getAllCourse = async (req, res) => {
  const courses = await enrolledService.getAllCourse();
  res.json(courses);
}

module.exports = {
  getUserByUid,
  getAllSubject,
  getAllCourse,
}
