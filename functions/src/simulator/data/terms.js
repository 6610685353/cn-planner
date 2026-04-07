// /** @type {Array<{ year: number, term: number, courses: string[] }>} */
// const TERMS = [
//   { year: 1, term: 1, courses: ["CN101","CN102","SC133","SC183","MA111","LAS101","TU100","TSE100"] },
//   { year: 1, term: 2, courses: ["CN201","CN103","MA112","SC134","SC184","EL105","IE121","ME100","TSE101"] },
//   { year: 2, term: 1, courses: ["CN202","CN200","CN204","CN260","CN261","MA214","TU108"] },
//   { year: 2, term: 2, courses: ["CN203","CN230","CN210","CN240","CN262","TU122"] },
//   { year: 3, term: 1, courses: ["CN331","CN361","CN321","CN330","CN310","CN320","CN340"] },
//   { year: 3, term: 2, courses: ["CN311","CN332","CN333","CN322","CN341","CN335","CN351","CN334"] },
//   { year: 4, term: 1, courses: [] },
//   { year: 4, term: 2, courses: [] },
//   { year: 5, term: 1, courses: [] },
//   { year: 5, term: 2, courses: [] },
//   { year: 6, term: 1, courses: [] },
//   { year: 6, term: 2, courses: [] },
//   { year: 7, term: 1, courses: [] },
//   { year: 7, term: 2, courses: [] },
//   { year: 8, term: 1, courses: [] },
//   { year: 8, term: 2, courses: [] },
// ];

// /** @type {Record<string, string>} */
// const DEFAULT_OUTCOMES = {
//   CN101: "pass",
//   CN102: "pass",
//   SC133: "pass",
//   SC183: "pass",
//   MA111: "pass",
//   LAS101: "pass",
//   TU100: "pass",
//   TSE100: "pass",
// };

// module.exports = { TERMS, DEFAULT_OUTCOMES };
/** @type {Array<{ year: number, term: number, courses: string[] }>} */
const TERMS = [
  { year: 1, term: 1, courses: ["CN101","CN102","SC133","SC183","MA111","LAS101","TU100","TSE100"] },
  { year: 1, term: 2, courses: ["CN201","CN103","MA112","SC134","SC184","EL105","IE121","ME100","TSE101"] },
  { year: 2, term: 1, courses: ["CN202","CN200","CN204","CN260","CN261","MA214","TU108"] },
  { year: 2, term: 2, courses: ["CN203","CN230","CN210","CN240","CN262","TU122"] },
  { year: 3, term: 1, courses: ["CN331","CN361","CN321","CN330","CN310","CN320","CN340"] },
  { year: 3, term: 2, courses: ["CN311","CN332","CN333","CN322","CN341","CN335","CN351","CN334"] },
  { year: 4, term: 1, courses: [] },
  { year: 4, term: 2, courses: [] },
  { year: 5, term: 1, courses: [] },
  { year: 5, term: 2, courses: [] },
  { year: 6, term: 1, courses: [] },
  { year: 6, term: 2, courses: [] },
  { year: 7, term: 1, courses: [] },
  { year: 7, term: 2, courses: [] },
  { year: 8, term: 1, courses: [] },
  { year: 8, term: 2, courses: [] },
];

/** @type {Record<string, string>} */
const DEFAULT_OUTCOMES = {
  CN101: "pass",
  CN102: "pass",
  SC133: "pass",
  SC183: "pass",
  MA111: "pass",
  LAS101: "pass",
  TU100: "pass",
  TSE100: "pass",
};

module.exports = { TERMS, DEFAULT_OUTCOMES };
