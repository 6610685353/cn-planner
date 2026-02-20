const supabase = require('../config/supabase');
const enrolledModel = require('../models/enrolled_model');

function arrayToKeyMap(data, keyMap,) {
  return data.reduce((acc, item) => {
    const key = `${item[keyMap]}`;
    acc[key] = item;               
    return acc;
  }, {});
}

function arraySumKeyMap(data, keyC1, keyC2) {
  return data.reduce((acc, item) => {
    const key = `${item[keyC1]}_${item[keyC2]}`;
    acc[key] = item; 
    return acc;
  }, {});
}


async function getUserByUid(uid) {
  return await enrolledModel.findUser(uid);
}

async function getAllSubject() {
  const data = await enrolledModel.getAllSubject();
  
  const mapData = arrayToKeyMap(data, 'subjectCode');
  
  return mapData;
}

async function getAllCourse() {
  const data = await enrolledModel.getAllCourse();
  const mapData = arraySumKeyMap(data, 'year', 'sem');
  return mapData;
}

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
  getUserByUid, 
  getAllSubject,
  getAllCourse,
  updateGrade,
  };