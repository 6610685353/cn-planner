const supabase = require('../config/supabase');

async function findUser(uid) {
  const { data, error } = await supabase.from('Enrolled').select('*').eq("uid", uid);

  if(error) throw error;

  return data;
}

async function getAllSubject() {
  const { data, error } = await supabase.from('Subjects').select('*');

  if(error) throw error;

  return data;
}

async function getAllCourse() {
  const { data, error } = await supabase.from('YearCourses').select('*');

  if(error) throw error;

  return data;
}

module.exports = {
   findUser,
   getAllSubject,
   getAllCourse,
   };