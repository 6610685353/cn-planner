const scheduleService = require("../services/schedule_service");

exports.getUserSchedule = async (req, res, next) => {
  try {
    const { uid } = req.params;
    if (!uid) {
      return res.status(400).json({ message: "UID is required" });
    }

    const schedule = await scheduleService.getUserSchedule(uid);
    res.status(200).json(schedule);
  } catch (error) {
    console.error("Error in getUserSchedule:", error);
    next(error);
  }
};
