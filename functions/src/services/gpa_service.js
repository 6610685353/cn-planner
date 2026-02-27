const userEnrolledModel = require("../models/enrolled_model");

const gradeMap = {
  A: 4,
  "B+": 3.5,
  B: 3,
  "C+": 2.5,
  C: 2,
  "D+": 1.5,
  D: 1,
  F: 0,
};

exports.calculateGPA = async (uid) => {
  const user = await userEnrolledModel.findByUid(uid);

  if (!user) {
    throw new Error("User not found");
  }

  if (user.enroll.length === 0) {
    return { uid, gpa: 0, totalSubjects: 0 };
  }

  let totalScore = 0;

  user.enroll.forEach((item) => {
    totalScore += gradeMap[item.grade] || 0;
  });

  const gpa = totalScore / user.enroll.length;

  return {
    uid: user.uid,
    gpa: gpa.toFixed(2),
    totalSubjects: user.enroll.length,
  };
};
