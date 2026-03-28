const getSupabase = require('../config/supabase');
const enrolledModel = require('../models/enrolled_model');
const cache = require('../utils/cache');

async function getPageData() {
  const cacheKey = 'PageData';
  let PageData = cache.get(cacheKey);

  if(!PageData) {
    console.log('PageData : Pulling from database')
    const rawPageData = await enrolledModel.getPageData();
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

    cache.set(cacheKey, formatted, 600);
    return formatted;
  }
  console.log("PageData: Using cache")
  return PageData;
};

async function getUserData(uid) {
  const cacheKey = `user:${uid}:enrolled_list`;
  let userData = cache.get(cacheKey);

  if (!userData) {
    userData = await enrolledModel.getUserData(uid);
    cache.set(cacheKey, userData, 180);
    console.log("UserData : Pulling from database")
    return userData;
  }
  console.log("UserData : Using cache")
  return userData;
}

const updateGrade = async (uid, gradeList) => {
  // for debug
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

  if (!upsertError && !deleteError) {
    const listKey = `user:${uid}:enrolled_list`;
    cache.del(listKey);
  }

  return { success: true };
}

module.exports = { 
  updateGrade,
  getUserData,
  getPageData,
  };