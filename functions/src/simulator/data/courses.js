// /**
//  * data/courses.js
//  * Curriculum course catalog used by the simulator backend.
//  */

// /** @type {Record<string, { code: string, name: string, credits: number, prerequisites: string[], type: string, availableTerms: number[], category?: string }>} */
// const COURSES = {
//   // Year 1 / Term 1
//   CN101:  { code: "CN101",  name: "Programming",                credits: 3, prerequisites: [],                        type: "core",            availableTerms: [1]    },
//   CN102:  { code: "CN102",  name: "Practice",                   credits: 1, prerequisites: [],                        type: "core",            availableTerms: [1]    },
//   SC133:  { code: "SC133",  name: "Physics 1",                  credits: 3, prerequisites: [],                        type: "core",            availableTerms: [1, 2] },
//   SC183:  { code: "SC183",  name: "Physics Lab 1",              credits: 1, prerequisites: [],                        type: "core",            availableTerms: [1, 2] },
//   MA111:  { code: "MA111",  name: "Calculus 1",                 credits: 3, prerequisites: [],                        type: "core",            availableTerms: [1, 2] },
//   LAS101: { code: "LAS101", name: "LAS101",                     credits: 3, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },
//   TU100:  { code: "TU100",  name: "TU100",                      credits: 1, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },
//   TSE100: { code: "TSE100", name: "TSE100",                     credits: 0, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },

//   // Year 1 / Term 2
//   CN201:  { code: "CN201",  name: "OOP",                        credits: 3, prerequisites: ["CN101"],                 type: "core",            availableTerms: [2]    },
//   CN103:  { code: "CN103",  name: "Practice 2",                 credits: 1, prerequisites: [],                        type: "core",            availableTerms: [2]    },
//   MA112:  { code: "MA112",  name: "Calculus 2",                 credits: 3, prerequisites: ["MA111"],                 type: "core",            availableTerms: [1, 2] },
//   SC134:  { code: "SC134",  name: "Physics 2",                  credits: 3, prerequisites: [],                        type: "core",            availableTerms: [1, 2] },
//   SC184:  { code: "SC184",  name: "Physics Lab 2",              credits: 1, prerequisites: [],                        type: "core",            availableTerms: [1, 2] },
//   EL105:  { code: "EL105",  name: "EL105",                      credits: 3, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },
//   IE121:  { code: "IE121",  name: "IE121",                      credits: 3, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },
//   ME100:  { code: "ME100",  name: "ME100",                      credits: 3, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },
//   TSE101: { code: "TSE101", name: "TSE101",                     credits: 1, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },

//   // Year 2 / Term 1
//   CN202:  { code: "CN202",  name: "Data Structures & Algo 1",   credits: 3, prerequisites: ["CN101", "CN201"],       type: "core",            availableTerms: [1]    },
//   CN200:  { code: "CN200",  name: "Discrete Math",              credits: 3, prerequisites: [],                        type: "core",            availableTerms: [1]    },
//   CN204:  { code: "CN204",  name: "Probability & Statistics",   credits: 3, prerequisites: ["MA111"],                 type: "core",            availableTerms: [1]    },
//   CN260:  { code: "CN260",  name: "Circuit Theory",             credits: 3, prerequisites: [],                        type: "core",            availableTerms: [1]    },
//   CN261:  { code: "CN261",  name: "Circuit Lab",                credits: 1, prerequisites: ["CN260"],                 type: "core",            availableTerms: [1]    },
//   MA214:  { code: "MA214",  name: "Differential Equations",     credits: 3, prerequisites: ["MA111", "MA112"],        type: "core",            availableTerms: [1, 2] },
//   TU108:  { code: "TU108",  name: "TU108",                      credits: 1, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },

//   // Year 2 / Term 2
//   CN203:  { code: "CN203",  name: "Data Structures & Algo 2",   credits: 3, prerequisites: ["CN202", "CN201", "CN101"], type: "core", availableTerms: [2] },
//   CN230:  { code: "CN230",  name: "Database Systems",           credits: 3, prerequisites: [],                        type: "core",            availableTerms: [2]    },
//   CN210:  { code: "CN210",  name: "Computer Architecture",      credits: 3, prerequisites: [],                        type: "core",            availableTerms: [2]    },
//   CN240:  { code: "CN240",  name: "Data Science",               credits: 3, prerequisites: ["CN204", "MA111"],        type: "core",            availableTerms: [2]    },
//   CN262:  { code: "CN262",  name: "Digital Systems",            credits: 3, prerequisites: [],                        type: "core",            availableTerms: [1, 2] },
//   TU122:  { code: "TU122",  name: "TU122",                      credits: 1, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },

//   // Year 3 / Term 1
//   CN331:  { code: "CN331",  name: "Software Engineering",       credits: 3, prerequisites: ["CN101"],                 type: "core",            availableTerms: [1]    },
//   CN361:  { code: "CN361",  name: "CN361",                      credits: 3, prerequisites: ["CN262"],                 type: "major_elective",  availableTerms: [1], category: "Major Elective" },
//   CN321:  { code: "CN321",  name: "Data Communications",        credits: 3, prerequisites: [],                        type: "core",            availableTerms: [1]    },
//   CN330:  { code: "CN330",  name: "App Development",            credits: 3, prerequisites: ["CN101"],                 type: "major_elective",  availableTerms: [1], category: "Major Elective" },
//   CN310:  { code: "CN310",  name: "Server Technology",          credits: 3, prerequisites: [],                        type: "major_elective",  availableTerms: [1], category: "Major Elective" },
//   CN320:  { code: "CN320",  name: "Network",                    credits: 3, prerequisites: [],                        type: "major_elective",  availableTerms: [1], category: "Major Elective" },
//   CN340:  { code: "CN340",  name: "Machine Learning",           credits: 3, prerequisites: ["CN240"],                 type: "major_elective",  availableTerms: [1], category: "Major Elective" },

//   // Year 3 / Term 2
//   CN311:  { code: "CN311",  name: "Operating Systems",          credits: 3, prerequisites: [],                        type: "core",            availableTerms: [2]    },
//   CN332:  { code: "CN332",  name: "OOAD",                       credits: 3, prerequisites: ["CN201"],                 type: "core",            availableTerms: [2]    },
//   CN333:  { code: "CN333",  name: "Mobile App Dev",             credits: 3, prerequisites: [],                        type: "core",            availableTerms: [2]    },
//   CN322:  { code: "CN322",  name: "Network Security",           credits: 3, prerequisites: ["CN320"],                 type: "major_elective",  availableTerms: [2], category: "Major Elective" },
//   CN341:  { code: "CN341",  name: "Deep Learning",              credits: 3, prerequisites: ["CN340"],                 type: "major_elective",  availableTerms: [2], category: "Major Elective" },
//   CN335:  { code: "CN335",  name: "Animation",                  credits: 3, prerequisites: [],                        type: "major_elective",  availableTerms: [2], category: "Major Elective" },
//   CN351:  { code: "CN351",  name: "Web Security",               credits: 3, prerequisites: [],                        type: "major_elective",  availableTerms: [2], category: "Major Elective" },
//   CN334:  { code: "CN334",  name: "Web Development",            credits: 3, prerequisites: ["CN101"],                 type: "major_elective",  availableTerms: [2], category: "Major Elective" },

//   // Year 4 track options
//   CN401:  { code: "CN401",  name: "Senior Project 1",           credits: 1, prerequisites: [],                        type: "track",           availableTerms: [1], category: "Project" },
//   CN402:  { code: "CN402",  name: "Senior Project 2",           credits: 1, prerequisites: ["CN401"],                 type: "track",           availableTerms: [2], category: "Project" },
//   CN403:  { code: "CN403",  name: "Co-op Preparation",          credits: 1, prerequisites: [],                        type: "track",           availableTerms: [1], category: "Co-op" },
//   CN404:  { code: "CN404",  name: "Co-operative Education",     credits: 6, prerequisites: ["CN403"],                 type: "track",           availableTerms: [2], category: "Co-op" },
//   CN472:  { code: "CN472",  name: "Research 1",                 credits: 1, prerequisites: [],                        type: "track",           availableTerms: [1], category: "Research" },
//   CN473:  { code: "CN473",  name: "Research 2",                 credits: 6, prerequisites: ["CN472"],                 type: "track",           availableTerms: [2], category: "Research" },
// };

// module.exports = COURSES;
/**
 * data/courses.js
 * Curriculum course catalog used by the simulator backend.
 */

/** @type {Record<string, { code: string, name: string, credits: number, prerequisites: string[], type: string, availableTerms: number[], category?: string }>} */
const COURSES = {
  // Year 1 / Term 1
  CN101:  { code: "CN101",  name: "Programming",                credits: 3, prerequisites: [],                        type: "core",            availableTerms: [1]    },
  CN102:  { code: "CN102",  name: "Practice",                   credits: 1, prerequisites: [],                        type: "core",            availableTerms: [1]    },
  SC133:  { code: "SC133",  name: "Physics 1",                  credits: 3, prerequisites: [],                        type: "core",            availableTerms: [1, 2] },
  SC183:  { code: "SC183",  name: "Physics Lab 1",              credits: 1, prerequisites: [],                        type: "core",            availableTerms: [1, 2] },
  MA111:  { code: "MA111",  name: "Calculus 1",                 credits: 3, prerequisites: [],                        type: "core",            availableTerms: [1, 2] },
  LAS101: { code: "LAS101", name: "LAS101",                     credits: 3, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },
  TU100:  { code: "TU100",  name: "TU100",                      credits: 1, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },
  TSE100: { code: "TSE100", name: "TSE100",                     credits: 0, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },

  // Year 1 / Term 2
  CN201:  { code: "CN201",  name: "OOP",                        credits: 3, prerequisites: ["CN101"],                 type: "core",            availableTerms: [2]    },
  CN103:  { code: "CN103",  name: "Practice 2",                 credits: 1, prerequisites: [],                        type: "core",            availableTerms: [2]    },
  MA112:  { code: "MA112",  name: "Calculus 2",                 credits: 3, prerequisites: ["MA111"],                 type: "core",            availableTerms: [1, 2] },
  SC134:  { code: "SC134",  name: "Physics 2",                  credits: 3, prerequisites: [],                        type: "core",            availableTerms: [1, 2] },
  SC184:  { code: "SC184",  name: "Physics Lab 2",              credits: 1, prerequisites: [],                        type: "core",            availableTerms: [1, 2] },
  EL105:  { code: "EL105",  name: "EL105",                      credits: 3, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },
  IE121:  { code: "IE121",  name: "IE121",                      credits: 3, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },
  ME100:  { code: "ME100",  name: "ME100",                      credits: 3, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },
  TSE101: { code: "TSE101", name: "TSE101",                     credits: 1, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },

  // Year 2 / Term 1
  CN202:  { code: "CN202",  name: "Data Structures & Algo 1",   credits: 3, prerequisites: ["CN101", "CN201"],       type: "core",            availableTerms: [1]    },
  CN200:  { code: "CN200",  name: "Discrete Math",              credits: 3, prerequisites: [],                        type: "core",            availableTerms: [1]    },
  CN204:  { code: "CN204",  name: "Probability & Statistics",   credits: 3, prerequisites: ["MA111"],                 type: "core",            availableTerms: [1]    },
  CN260:  { code: "CN260",  name: "Circuit Theory",             credits: 3, prerequisites: [],                        type: "core",            availableTerms: [1]    },
  CN261:  { code: "CN261",  name: "Circuit Lab",                credits: 1, prerequisites: ["CN260"],                 type: "core",            availableTerms: [1]    },
  MA214:  { code: "MA214",  name: "Differential Equations",     credits: 3, prerequisites: ["MA111", "MA112"],        type: "core",            availableTerms: [1, 2] },
  TU108:  { code: "TU108",  name: "TU108",                      credits: 1, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },

  // Year 2 / Term 2
  CN203:  { code: "CN203",  name: "Data Structures & Algo 2",   credits: 3, prerequisites: ["CN202", "CN201", "CN101"], type: "core", availableTerms: [2] },
  CN230:  { code: "CN230",  name: "Database Systems",           credits: 3, prerequisites: [],                        type: "core",            availableTerms: [2]    },
  CN210:  { code: "CN210",  name: "Computer Architecture",      credits: 3, prerequisites: [],                        type: "core",            availableTerms: [2]    },
  CN240:  { code: "CN240",  name: "Data Science",               credits: 3, prerequisites: ["CN204", "MA111"],        type: "core",            availableTerms: [2]    },
  CN262:  { code: "CN262",  name: "Digital Systems",            credits: 3, prerequisites: [],                        type: "core",            availableTerms: [1, 2] },
  TU122:  { code: "TU122",  name: "TU122",                      credits: 1, prerequisites: [],                        type: "general_core",    availableTerms: [1, 2] },

  // Year 3 / Term 1
  CN331:  { code: "CN331",  name: "Software Engineering",       credits: 3, prerequisites: ["CN101"],                 type: "core",            availableTerms: [1]    },
  CN361:  { code: "CN361",  name: "CN361",                      credits: 3, prerequisites: ["CN262"],                 type: "major_elective",  availableTerms: [1], category: "Major Elective" },
  CN321:  { code: "CN321",  name: "Data Communications",        credits: 3, prerequisites: [],                        type: "core",            availableTerms: [1]    },
  CN330:  { code: "CN330",  name: "App Development",            credits: 3, prerequisites: ["CN101"],                 type: "major_elective",  availableTerms: [1], category: "Major Elective" },
  CN310:  { code: "CN310",  name: "Server Technology",          credits: 3, prerequisites: [],                        type: "major_elective",  availableTerms: [1], category: "Major Elective" },
  CN320:  { code: "CN320",  name: "Network",                    credits: 3, prerequisites: [],                        type: "major_elective",  availableTerms: [1], category: "Major Elective" },
  CN340:  { code: "CN340",  name: "Machine Learning",           credits: 3, prerequisites: ["CN240"],                 type: "major_elective",  availableTerms: [1], category: "Major Elective" },

  // Year 3 / Term 2
  CN311:  { code: "CN311",  name: "Operating Systems",          credits: 3, prerequisites: [],                        type: "core",            availableTerms: [2]    },
  CN332:  { code: "CN332",  name: "OOAD",                       credits: 3, prerequisites: ["CN201"],                 type: "core",            availableTerms: [2]    },
  CN333:  { code: "CN333",  name: "Mobile App Dev",             credits: 3, prerequisites: [],                        type: "core",            availableTerms: [2]    },
  CN322:  { code: "CN322",  name: "Network Security",           credits: 3, prerequisites: ["CN320"],                 type: "major_elective",  availableTerms: [2], category: "Major Elective" },
  CN341:  { code: "CN341",  name: "Deep Learning",              credits: 3, prerequisites: ["CN340"],                 type: "major_elective",  availableTerms: [2], category: "Major Elective" },
  CN335:  { code: "CN335",  name: "Animation",                  credits: 3, prerequisites: [],                        type: "major_elective",  availableTerms: [2], category: "Major Elective" },
  CN351:  { code: "CN351",  name: "Web Security",               credits: 3, prerequisites: [],                        type: "major_elective",  availableTerms: [2], category: "Major Elective" },
  CN334:  { code: "CN334",  name: "Web Development",            credits: 3, prerequisites: ["CN101"],                 type: "major_elective",  availableTerms: [2], category: "Major Elective" },

  // Year 4 track options
  CN401:  { code: "CN401",  name: "Senior Project 1",           credits: 1, prerequisites: [],                        type: "track",           availableTerms: [1], category: "Project" },
  CN402:  { code: "CN402",  name: "Senior Project 2",           credits: 1, prerequisites: ["CN401"],                 type: "track",           availableTerms: [2], category: "Project" },
  CN403:  { code: "CN403",  name: "Co-op Preparation",          credits: 1, prerequisites: [],                        type: "track",           availableTerms: [1], category: "Co-op" },
  CN404:  { code: "CN404",  name: "Co-operative Education",     credits: 6, prerequisites: ["CN403"],                 type: "track",           availableTerms: [2], category: "Co-op" },
  CN472:  { code: "CN472",  name: "Research 1",                 credits: 1, prerequisites: [],                        type: "track",           availableTerms: [1], category: "Research" },
  CN473:  { code: "CN473",  name: "Research 2",                 credits: 6, prerequisites: ["CN472"],                 type: "track",           availableTerms: [2], category: "Research" },
};

module.exports = COURSES;
