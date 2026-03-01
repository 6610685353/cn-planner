const getSupabase = require('../config/supabase');
const enrolledModel = require('../models/enrolled_model');

//logic function


//call get to model
async function getUserData(uid) {
  const userData = await enrolledModel.getUserData(uid);

  return userData;
}

async function getPageData() {
  const rawPageData = await enrolledModel.getPageData();

  // Convert data to Mapped list for frontend
  const formatted = rawPageData.reduce((acc, item) => {
    const { Subjects, ...rest } = item;

    const flattened = { ...rest, ...Subjects };

    const groupKey = `${item.year}_${item.sem}`;

    if (!acc[groupKey]) {
      acc[groupKey] = [];
    }

    acc[groupKey].push(flattened);

    return acc;
  }, {});

  return formatted;
};


//call post to model
const updateGrade = async (uid, gradeList) => {
  console.log("Calling submit Service")
  console.log(gradeList);
  
  const submittedSubjects = gradeList.map(item => item.subjectId);

  const dataToUpsert = gradeList.map(item => ({
    uid: uid,
    subjectId: item.subjectId,
    grade: item.grade
  }));

  const supabase = getSupabase();
  
  const { error: upsertError } = await supabase
    .from('UserEnrolled')
    .upsert(dataToUpsert, { onConflict: 'uid, subjectId' });

  if (upsertError) console.log(upsertError);

  const {error: deleteError } = await supabase
    .from('UserEnrolled')
    .delete()
    .eq('uid', uid)
    .not('subjectId', 'in', `(${submittedSubjects.join(',')})`);

  if (deleteError) console.log(deleteError);

  return { success: true };
}

module.exports = { 
  updateGrade,
  getUserData,
  getPageData,
  };