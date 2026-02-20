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
  console.log(data);
  const mapData = arraySumKeyMap(data, 'year', 'sem');
  console.log(mapData);
  return mapData;
}

module.exports = { 
  getUserByUid, 
  getAllSubject,
  getAllCourse,
  };