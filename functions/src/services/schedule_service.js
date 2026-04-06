const roadmapService = require("../services/roadmap_service"); // existing (used for submit)
const getSupabase = require("../config/supabase");

/**
 * ดึงข้อมูลตารางเรียนที่สมบูรณ์ของผู้ใช้ โดยรวมข้อมูลจาก Profiles, UserRoadmap, ClassSchedules และ Subjects
 * @param {string} uid User ID ของผู้ใช้
 * @returns {Promise<Array>} ลิสต์ของ MasterCourseModel JSON
 */
const getUserSchedule = async (uid) => {
  const supabase = getSupabase();

  // 1. ดึง Profile ของผู้ใช้เพื่อหาปีการศึกษาและเทอมปัจจุบัน
  const { data: profile, error: profileError } = await supabase
    .from("profiles")
    .select("current_year, current_semester")
    .eq("user_id", uid)
    .maybeSingle();

  if (profileError) throw profileError;
  if (!profile) return [];

  const { current_year, current_semester } = profile;

  // 2. ดึง Roadmap เพื่อหาว่าผู้ใช้ลงทะเบียนวิชาอะไรบ้างในเทอมปัจจุบัน และ Section ไหน
  const { data: roadmap, error: roadmapError } = await supabase
    .from("UserRoadmap")
    .select("subject_code, section")
    .eq("user_id", uid)
    .eq("year", current_year)
    .eq("semester", current_semester);

  if (roadmapError) throw roadmapError;
  if (!roadmap || roadmap.length === 0) return [];

  // สร้าง Map เก็บ Section ของแต่ละวิชา
  const userSections = {};
  const enrolledCodes = [];
  roadmap.forEach((item) => {
    const code = item.subject_code.toString();
    userSections[code] = item.section ? item.section.toString() : "";
    enrolledCodes.push(code);
  });

  // 3. ดึง ClassSchedules (วัน เวลา ห้องเรียน) ของวิชาที่ลงทะเบียน
  const { data: schedules, error: scheduleError } = await supabase
    .from("ClassSchedules")
    .select("*")
    .in("subject_code", enrolledCodes);

  if (scheduleError) throw scheduleError;

  // 4. ดึงข้อมูลรายวิชา (Subjects) เพื่อเอาชื่อวิชาและชื่ออาจารย์
  const { data: subjects, error: subjectError } = await supabase
    .from("Subjects")
    .select("subjectCode, subjectName, instructor")
    .in("subjectCode", enrolledCodes);

  if (subjectError) throw subjectError;

  const subjectDetails = {};
  subjects.forEach((sub) => {
    subjectDetails[sub.subjectCode] = sub;
  });

  // 5. ประกอบร่างข้อมูล (Grouping by courseCode)
  const courseMap = {};

  schedules.forEach((row) => {
    const code = row.subject_code;
    const sectionFromDB = row.section ? row.section.toString() : "01";

    // กรองให้เหลือแค่ Section ที่ผู้ใช้ลงทะเบียนไว้
    if (userSections[code] !== sectionFromDB) {
      return;
    }

    const slot = {
      day: row.day,
      startTime: row.start_time,
      endTime: row.end_time,
      room: row.room,
    };

    if (courseMap[code]) {
      courseMap[code].timeSlots.push(slot);
    } else {
      const info = subjectDetails[code] || {};
      courseMap[code] = {
        courseCode: code,
        courseName: info.subjectName || "Unknown Course",
        instructor: info.instructor || "TBA",
        section: sectionFromDB,
        timeSlots: [slot],
      };
    }
  });

  return Object.values(courseMap);
};

module.exports = {
  getUserSchedule,
};
