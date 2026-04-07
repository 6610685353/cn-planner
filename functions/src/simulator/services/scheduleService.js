// /**
//  * services/scheduleService.js
//  * ตรวจสอบการชนกันของตารางเรียน
//  */

// const SCHEDULE = require("../data/schedule");

// /** แปลง "09:30" → นาที */
// const toMin = (t) => {
//   const [h, m] = t.split(":").map(Number);
//   return h * 60 + m;
// };

// /** ตรวจว่า 2 timeslot ซ้อนทับกันไหม */
// const slotsOverlap = (a, b) => {
//   if (a.day !== b.day) return false;
//   return toMin(a.start) < toMin(b.end) && toMin(b.start) < toMin(a.end);
// };

// /** ตรวจว่าวิชา a กับ b ชนตารางกันไหม */
// const hasConflict = (codeA, codeB) => {
//   const slotsA = SCHEDULE[codeA] || [];
//   const slotsB = SCHEDULE[codeB] || [];
//   return slotsA.some((a) => slotsB.some((b) => slotsOverlap(a, b)));
// };

// /**
//  * ตรวจชนตารางในกลุ่มวิชาที่เลือก
//  * @param {string[]} courses
//  * @returns {{ courseA, courseB }[]}
//  */
// const findConflicts = (courses) => {
//   const conflicts = [];
//   for (let i = 0; i < courses.length; i++) {
//     for (let j = i + 1; j < courses.length; j++) {
//       if (hasConflict(courses[i], courses[j])) {
//         conflicts.push({ courseA: courses[i], courseB: courses[j] });
//       }
//     }
//   }
//   return conflicts;
// };



// /** ตรวจว่า slot arrays 2 ชุดชนกันไหม (ใช้กับ custom course ที่มี schedule เป็น array โดยตรง) */
// const hasConflictWithSlots = (slotsA, slotsB) => {
//   if (!slotsA.length || !slotsB.length) return false;
//   return slotsA.some((a) => slotsB.some((b) => slotsOverlap(a, b)));
// };

// module.exports = { hasConflict, hasConflictWithSlots, findConflicts };
/**
 * services/scheduleService.js
 * ตรวจสอบการชนกันของตารางเรียน
 */

const SCHEDULE = require("../data/schedule");

/** แปลง "09:30" → นาที */
const toMin = (t) => {
  const [h, m] = t.split(":").map(Number);
  return h * 60 + m;
};

/** ตรวจว่า 2 timeslot ซ้อนทับกันไหม */
const slotsOverlap = (a, b) => {
  if (a.day !== b.day) return false;
  return toMin(a.start) < toMin(b.end) && toMin(b.start) < toMin(a.end);
};

/** ตรวจว่าวิชา a กับ b ชนตารางกันไหม */
const hasConflict = (codeA, codeB) => {
  const slotsA = SCHEDULE[codeA] || [];
  const slotsB = SCHEDULE[codeB] || [];
  return slotsA.some((a) => slotsB.some((b) => slotsOverlap(a, b)));
};

/**
 * ตรวจชนตารางในกลุ่มวิชาที่เลือก
 * @param {string[]} courses
 * @returns {{ courseA, courseB }[]}
 */
const findConflicts = (courses) => {
  const conflicts = [];
  for (let i = 0; i < courses.length; i++) {
    for (let j = i + 1; j < courses.length; j++) {
      if (hasConflict(courses[i], courses[j])) {
        conflicts.push({ courseA: courses[i], courseB: courses[j] });
      }
    }
  }
  return conflicts;
};



/** ตรวจว่า slot arrays 2 ชุดชนกันไหม (ใช้กับ custom course ที่มี schedule เป็น array โดยตรง) */
const hasConflictWithSlots = (slotsA, slotsB) => {
  if (!slotsA.length || !slotsB.length) return false;
  return slotsA.some((a) => slotsB.some((b) => slotsOverlap(a, b)));
};

module.exports = { hasConflict, hasConflictWithSlots, findConflicts };
