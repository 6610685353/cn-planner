const gpaService = require("../services/gpa_service");

exports.getGPA = async (req, res, next) => {
  // อันนี้เป็นโค้ดเก่า เก็บไว้เผื่อมีคนใช้อยู่ แต่ในอนาคตควรย้ายไปใช้ Roadmap 
  try {
    const { uid } = req.params;
    // ปัจจุบัน calculateGPA ใน service ถูกเขียนทับไปแล้ว 
    // ถ้าต้องการรักษาฟังก์ชันเดิม ต้องสร้างชื่อใหม่ 
    // แต่ตามแผนคือให้ Rewrite ดังนั้นเราจะเปลี่ยนเป็นฟังก์ชันใหม่
    res.status(501).json({ message: "This endpoint is deprecated. Use /init/:uid" });
  } catch (error) {
    next(error);
  }
};

exports.getInitialData = async (req, res, next) => {
  try {
    const { uid } = req.params;
    if (!uid) {
      return res.status(400).json({ message: "UID is required" });
    }

    const data = await gpaService.getInitialData(uid);
    res.status(200).json(data);
  } catch (error) {
    console.error("Error in getInitialData:", error);
    next(error);
  }
};
