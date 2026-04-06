const getSupabase = require("../config/supabase");

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

/**
 * ดึงข้อมูลตั้งต้นสำหรับหน้า GPA Calculator (Sandbox)
 * โดยรวมข้อมูล Profile, รายวิชาในเทอมปัจจุบัน, และข้อมูลรายวิชาทั้งหมด
 * @param {string} uid User ID
 * @returns {Promise<Object>} Data Object สำหรับ Flutter Controller
 */
const getInitialData = async (uid) => {
  const supabase = getSupabase();

  // 1. ดึงข้อมูล Profile
  const { data: profile, error: profileError } = await supabase
    .from("profiles")
    .select("gpax, earned_credits, current_year, current_semester")
    .eq("user_id", uid)
    .maybeSingle();

  if (profileError) throw profileError;
  if (!profile) throw new Error("Profile not found");

  const { gpax, earned_credits, current_year, current_semester } = profile;

  // 2. ดึง Roadmap เฉพาะวิชาในเทอมปัจจุบันเพื่อทำ Sandbox เริ่มต้น
  const { data: roadmap, error: roadmapError } = await supabase
    .from("UserRoadmap")
    .select("subject_code, grade")
    .eq("user_id", uid)
    .eq("year", current_year)
    .eq("semester", current_semester);

  if (roadmapError) throw roadmapError;

  // 3. ดึงรายวิชาทั้งหมด (Subjects) เพื่อเอา Name และ Credit
  const { data: allSubjects, error: subjectsError } = await supabase
    .from("Subjects")
    .select("subjectCode, subjectName, credits, subjectId");

  if (subjectsError) throw subjectsError;

  const subjectMap = {};
  allSubjects.forEach((s) => {
    subjectMap[s.subjectCode] = s;
  });

  // 4. ประกอบรายวิชาเทอมปัจจุบัน
  const currentSemesterCourses = roadmap.map((item) => {
    const sub = subjectMap[item.subject_code] || {
      subjectName: item.subject_code,
      credits: 3.0,
    };
    
    // กำหนดเกรดเริ่มต้นเป็น 'A' หากยังไม่มีเกรดใน Roadmap (สำหรับ Sandbox)
    let displayGrade = item.grade || "A";
    if (displayGrade === "-" || !gradeMap[displayGrade]) {
        displayGrade = "A";
    }

    return {
      code: item.subject_code,
      name: sub.subjectName,
      credits: sub.credits,
      grade: displayGrade,
    };
  });

  // 5. ดึงรายวิชาที่สอบผ่านแล้ว (สำหรับกรองใน ManageCoursePage)
  const { data: history, error: historyError } = await supabase
    .from("UserRoadmap")
    .select("subject_code, grade")
    .eq("user_id", uid);

  if (historyError) throw historyError;

  const passedSubjects = history
    .filter((e) => e.grade && e.grade !== "-" && e.grade !== "F" && e.grade !== "W")
    .map((e) => e.subject_code);

  return {
    currentGPA: gpax || 0.0,
    pastTotalCredits: earned_credits || 0.0,
    currentSemesterCourses,
    passedSubjects,
    allSubjects, // ส่งไปเพื่อให้ Flutter ไม่ต้องยิงแยก (ตามแผน)
  };
};

module.exports = {
  getInitialData,
};
