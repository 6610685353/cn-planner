const supabase = require('../config/supabase');

async function getUserData(uid) {
  const { data, error } = await supabase.from('UserEnrolled').select('*').eq("uid", uid);

  if(error) throw error;

  return data;
}

async function getPageData() {
  const { data , error } = await supabase
    .from('YearCourses')
    .select(`*, Subjects (*)`);

  if (error) throw error;
  
  return data;
}

module.exports = {
   getUserData,
   getPageData,
   };