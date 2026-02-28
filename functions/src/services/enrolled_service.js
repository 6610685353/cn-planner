const supabase = require('../config/supabase');
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
const updateGrade = async (uid, enrolledSubjects) => {
  const { data, error } = await supabase
    .from("Enrolled")
    .update({ enrolledSubjects })
    .eq("uid", uid)
    .select();

  console.log("Update result:", data);
  console.log("Update error:", error);

  if (error) throw error;

  if (!data || data.length === 0) {
    throw new Error("No row updated");
  }

  return data;
}

module.exports = { 
  updateGrade,
  getUserData,
  getPageData,
  };