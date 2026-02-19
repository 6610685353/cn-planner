// mock database
const mockUsers = [
  {
    uid: "001",
    enroll: [
      { subject: "CN101", grade: "A" },
      { subject: "MA102", grade: "B+" },
      { subject: "CS201", grade: "A" },
    ],
  },
  {
    uid: "002",
    enroll: [
      { subject: "CN101", grade: "B" },
      { subject: "PH103", grade: "A" },
    ],
  },
  {
    uid: "003",
    enroll: [],
  },
];

exports.findByUid = async (uid) => {
  const user = mockUsers.find((user) => user.uid === uid);

  if (!user) {
    return null; // เหมือนไม่เจอข้อมูล
  }

  return user;
};

exports.addSubjectToUser = async (uid, subject, grade) => {
  const user = mockUsers.find((user) => user.uid === uid);

  if (!user) {
    return null;
  }

  const newSubject = { subject, grade };

  user.enroll.push(newSubject);

  const exists = user.enroll.find((s) => s.subject === subject);
  if (exists) {
    throw new Error("Subject already exists");
  }
  return user;
};

exports.replaceEnrollList = async (uid, newEnrollList) => {
  const user = mockUsers.find((user) => user.uid === uid);

  if (!user) {
    return null;
  }

  // แทนที่ enroll เดิมทั้งหมด
  user.enroll = newEnrollList;

  return user;
};

//pull data from Supabase

const supabase = require('../config/supabase');

async function findUser(uid) {
  const { data, error } = await supabase.from('Enrolled').select('*').eq("uid", uid);

  if(error) throw error;

  return data;
}

module.exports = { findUser };