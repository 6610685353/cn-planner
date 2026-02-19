const userEnrolledModel = require("../models/enrolled_model");

exports.getUserByUid = async (uid) => {
  const user = await userEnrolledModel.findByUid(uid);

  if (!user) {
    throw new Error("User not found");
  }

  return user;
};

exports.addSubjectToUser = async (uid, subject, grade) => {
  const user = await userEnrolledModel.addSubjectToUser(uid, subject, grade);

  if (!user) {
    throw new Error("User not found");
  }

  return user;
};

exports.updateEnrollList = async (uid, enrollList) => {
  if (!Array.isArray(enrollList)) {
    throw new Error("Enroll must be an array");
  }

  const subjectSet = new Set();

  for (const item of enrollList) {
    if (subjectSet.has(item.subject)) {
      throw new Error(`Duplicate subject found: ${item.subject}`);
    }
    subjectSet.add(item.subject);
  }

  const updatedUser = await userEnrolledModel.replaceEnrollList(
    uid,
    enrollList,
  );

  if (!updatedUser) {
    throw new Error("User not found");
  }

  return updatedUser;
};
