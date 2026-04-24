const getSupabase = require("../config/supabase");

async function getUserData(uid) {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from("UserEnrolled")
    .select("subjectId, grade")
    .eq("uid", uid);

  if (error) throw error;

  return data;
}

async function getPageData() {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from("YearCourses")
    .select(
      `*, Subjects (subjectCode, subjectName, require, credits, corequisite, offeredSemester, su_grade)`,
    );

  if (error) throw error;

  return data;
}

async function getCurSemData(uid) {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from("UserEnrolled")
    .select("grade, Subjects(subjectName, credits, subjectCode)")
    .eq("uid", uid)
    .eq("grade", "-");

  if (error) throw error;

  return data.map((item) => ({
    subjectName: item.Subjects?.subjectName,
    subjectCode: item.Subjects?.subjectCode,
    grade: item.grade,
    credit: item.Subjects?.credits,
  }));
}

module.exports = {
  getUserData,
  getPageData,
  getCurSemData,
};
