const gpaModel = require("../models/gpa_model");
const cache = require('../utils/cache');

async function getGPA(uid) {
  console.log("calling getGPA in Service")
  const cacheKey = `user:${uid}:gpa_cred`;
  let GPAcred = cache.get(cacheKey);  

  if(!GPAcred) {
    console.log('GPAcred : Pulling from database')
    GPAcred = await gpaModel.getGPAcred(uid);
    cache.set(cacheKey, GPAcred, 300);
    return GPAcred;
  }
  console.log("GPAcred: Using cache");
  return GPAcred;
};

async function getThisSem(uid) {
  console.log("calling getThisSem")
  
  thisSemCourse = await gpaModel.getThisSem(uid);

  const flattenedData = thisSemCourse.map(({ Subjects, ...rest }) => ({
    ...rest,
    ...Subjects,
  }));
  
  return flattenedData; 
};

module.exports = {
  getGPA,
  getThisSem,
}