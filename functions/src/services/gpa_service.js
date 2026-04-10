const gpaModel = require("../models/gpa_model");
const cache = require('../utils/cache');

async function getGPA(uid, isUsingCache) {
  console.log("calling getGPA Service")
  const cacheKey = `user:${uid}:gpa_cred`;
  let GPAcred = null;

  if (isUsingCache) {
    GPAcred = cache.get(cacheKey);  
  }

  if(!GPAcred) {
    console.log('GPAcred : Pulling from database')
    GPAcred = await gpaModel.getGPAcred(uid);
    cache.set(cacheKey, GPAcred, 300);
    return GPAcred;
  }
  console.log("GPAcred: Using cache");
  return GPAcred;
};

async function getThisSem(uid, isUsingCache) {
  console.log("calling getThisSem Service")
  const cacheKey = `user:${uid}:this_sem`;
  let flattenedData = null;

  if (isUsingCache) {
    flattenedData = cache.get(cacheKey);
  }

  if (!flattenedData) {
    console.log("getThisSem : pulling from database")
    thisSemCourse = await gpaModel.getThisSem(uid);

    flattenedData = thisSemCourse.map(({ Subjects, ...rest }) => ({
      ...rest,
      ...Subjects,
    }));

    cache.set(cacheKey, flattenedData, 300);
    return flattenedData; 
  }
  
  console.log("getThisSem : using cache")
  return flattenedData; 
};

module.exports = {
  getGPA,
  getThisSem,
}