const userEnrolledService = require("../services/enrolled_service");

exports.getUserByUid = async (req, res, next) => {
  try {
    const user = await userEnrolledService.getUserByUid(req.params.uid);
    res.status(200).json(user);
  } catch (error) {
    next(error);
  }
};

exports.addSubject = async (req, res, next) => {
  try {
    const { uid } = req.params;
    const { subject, grade } = req.body;

    if (!subject || !grade) {
      return res.status(400).json({
        message: "Subject and grade are required",
      });
    }

    const updatedUser = await userEnrolledService.addSubjectToUser(
      uid,
      subject,
      grade,
    );

    res.status(200).json({
      message: "Subject added successfully",
      data: updatedUser,
    });
  } catch (error) {
    next(error);
  }
};

exports.updateEnrollList = async (req, res, next) => {
  try {
    const { uid } = req.params;
    const { enroll } = req.body;

    if (!enroll) {
      return res.status(400).json({
        message: "Enroll list is required",
      });
    }

    const result = await userEnrolledService.updateEnrollList(uid, enroll);

    res.status(200).json({
      message: "Enroll list updated successfully",
      data: result,
    });
  } catch (error) {
    next(error);
  }
};
