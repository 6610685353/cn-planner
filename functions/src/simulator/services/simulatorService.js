const COURSES = require("../data/courses");
const SCHEDULE = require("../data/schedule");
const { TERMS, DEFAULT_OUTCOMES } = require("../data/terms");
const { hasConflictWithSlots } = require("./scheduleService");

const MIN_CREDITS_PER_TERM = 9;
const MAX_CREDITS_PER_TERM = 21;
const TOTAL_PROGRAM_CREDITS = 146;
const BASELINE_TERM_INDEX = 8; // Year 4 / Term 2

const CORE_REQUIRED = [
  "CN101", "CN102", "SC133", "SC183", "MA111", "LAS101", "TU100", "TSE100",
  "CN201", "CN103", "MA112", "SC134", "SC184", "EL105", "IE121", "ME100", "TSE101",
  "CN202", "CN200", "CN204", "CN260", "CN261", "MA214", "TU108",
  "CN203", "CN230", "CN210", "CN240", "CN262", "TU122",
  "CN331", "CN321", "CN311", "CN332", "CN333",
];

const TERM_1_ELECTIVES = ["CN330", "CN310", "CN320", "CN340", "CN361"];
const TERM_2_ELECTIVES = ["CN322", "CN341", "CN335", "CN351", "CN334"];

const TRACKS = {
  project: {
    key: "project",
    label: "Project",
    term1: "CN401",
    term2: "CN402",
    exclusiveTerm2: false,
  },
  coop: {
    key: "coop",
    label: "Co-op",
    term1: "CN403",
    term2: "CN404",
    exclusiveTerm2: true,
  },
  research: {
    key: "research",
    label: "Research",
    term1: "CN472",
    term2: "CN473",
    exclusiveTerm2: false,
  },
};

const termIndex = (year, term) => ((year - 1) * 2) + term;
const termKeyOf = (year, term) => `Year ${year} / Term ${term}`;
const compareTerms = (a, b) => termIndex(a.year, a.term) - termIndex(b.year, b.term);

const sortAndNormalizeTerms = (terms = []) => {
  return [...terms]
    .map((term) => ({
      year: term.year,
      term: term.term,
      status: term.status || "upcoming",
      courses: Array.isArray(term.courses) ? [...new Set(term.courses)] : [],
    }))
    .sort(compareTerms);
};

const buildProjectionTerms = (effectiveTerms = [], extraYears = 0) => {
  const sortedEffective = sortAndNormalizeTerms(effectiveTerms);
  const maxExistingYear = Math.max(...sortedEffective.map((t) => t.year), 4);
  const maxYear = Math.max(4, maxExistingYear + extraYears);
  const map = new Map(sortedEffective.map((t) => [`${t.year}-${t.term}`, t]));
  const projection = [];

  for (let year = 1; year <= maxYear; year += 1) {
    for (const term of [1, 2]) {
      const existing = map.get(`${year}-${term}`);
      projection.push(existing || { year, term, status: "upcoming", courses: [] });
    }
  }

  return projection;
};

const normalTermOf = (code, termPool = TERMS) => {
  return termPool.find((t) => Array.isArray(t.courses) && t.courses.includes(code)) ?? null;
};

const courseTypeFromCategory = (category = "") => {
  switch (String(category).trim().toLowerCase()) {
    case "major elective":
      return "major_elective";
    case "general education":
      return "general_education";
    case "free elective":
      return "free_elective";
    default:
      return "custom";
  }
};

const buildAllCourses = (customCourses = {}) => {
  const mappedCustomCourses = Object.fromEntries(
    Object.entries(customCourses).map(([code, info]) => {
      const category = info.category || null;
      return [
        code,
        {
          code,
          name: info.name || code,
          credits: Number(info.credits || 0),
          prerequisites: Array.isArray(info.prerequisites) ? info.prerequisites : [],
          type: info.type || courseTypeFromCategory(category),
          category,
          availableTerms:
            Array.isArray(info.availableTerms) && info.availableTerms.length > 0
              ? info.availableTerms
              : [1, 2],
        },
      ];
    }),
  );

  return { ...COURSES, ...mappedCustomCourses };
};

const buildScheduleMap = (customCourses = {}) => {
  const scheduleMap = { ...SCHEDULE };
  for (const [code, info] of Object.entries(customCourses)) {
    if (Array.isArray(info.schedule)) {
      scheduleMap[code] = info.schedule;
    }
  }
  return scheduleMap;
};

const sameTerm = (a, b) => {
  if (!a || !b) return false;
  return Number(a.year) === Number(b.year) && Number(a.term) === Number(b.term);
};

const getCourseOutcomeFromTerm = (term, code) => {
  const detail = (term.courseDetails || []).find((course) => course.code === code);
  return detail?.outcome || null;
};

const getExplicitOutcomeForCode = (term, code, fallbackOutcomes = {}) => {
  const fromTerm = getCourseOutcomeFromTerm(term, code);
  if (fromTerm != null && fromTerm !== "") return String(fromTerm).toLowerCase();
  const fromFallback = fallbackOutcomes[code];
  if (fromFallback != null && fromFallback !== "") return String(fromFallback).toLowerCase();
  return "notSet";
};

const termIndexToObject = (idx) => {
  if (idx == null) return null;
  const normalized = Math.max(1, Number(idx));
  const year = Math.ceil(normalized / 2);
  const term = normalized % 2 === 0 ? 2 : 1;
  return { year, term, label: termKeyOf(year, term), index: normalized };
};

const isIgnoredCoopTermForRetake = (term, code, effectiveTerms = []) => {
  if (code === "CN404") return false;
  if (!(term.year === 4 && term.term === 2)) return false;
  const matched = effectiveTerms.find((t) => t.year === 4 && t.term === 2) || term;
  return Array.isArray(matched.courses) && matched.courses.includes("CN404");
};

const resolveEffectiveCurrentTerm = (
  effectiveTerms,
  rawOutcomes = {},
  simulatedCurrentTerm = null,
) => {
  const sortedTerms = sortAndNormalizeTerms(effectiveTerms);

  // Ensure current is always considered, even if F-laden
  const currentTerm = sortedTerms.find(term => term.status === "current");
  if (currentTerm) {
    return {
      year: currentTerm.year,
      term: currentTerm.term,
      source: "current-term",
    };
  }

  let latestValidTerm = null;
  for (const term of sortedTerms) {
    // Check if this term is all F
    const allFailed = term.courses.every(
      (code) => String(rawOutcomes[code] || "notSet") === "fail"
    );

    // If all courses are F and there's no pass after it, skip this term
    if (allFailed) {
      const nextTermWithPass = sortedTerms.find(t => {
        const hasPass = t.courses.some(
          (code) => String(rawOutcomes[code] || "notSet") === "pass"
        );
        return hasPass && termIndex(t.year, t.term) > termIndex(term.year, term.term);
      });

      if (!nextTermWithPass) {
        continue;
      }
    }

    // If any term after current term has a pass, this term becomes current (simulated)
    const hasPassInCurrentTerm = term.courses.some(
      (code) => String(rawOutcomes[code] || "notSet") === "pass"
    );

    if (hasPassInCurrentTerm) {
      latestValidTerm = term;
    }
  }

  if (latestValidTerm) {
    return {
      year: latestValidTerm.year,
      term: latestValidTerm.term,
      source: "pass-latest-term",
    };
  }

  // Fallback to simulatedCurrentTerm if no pass found
  if (simulatedCurrentTerm && simulatedCurrentTerm.year && simulatedCurrentTerm.term) {
    return {
      year: Number(simulatedCurrentTerm.year),
      term: Number(simulatedCurrentTerm.term),
      source: "explicit-fallback",
    };
  }

  const firstUpcoming = sortedTerms.find((term) => term.status === "upcoming");
  if (firstUpcoming) {
    return { year: firstUpcoming.year, term: firstUpcoming.term, source: "first-upcoming" };
  }

  return null;
};

const normalizeOutcomesForSimulation = (
  effectiveTerms,
  rawOutcomes = {},
  effectiveCurrentTerm = null,
) => {
  const normalized = { ...DEFAULT_OUTCOMES, ...rawOutcomes };
  const currentIdx = effectiveCurrentTerm
    ? termIndex(effectiveCurrentTerm.year, effectiveCurrentTerm.term)
    : null;

  for (const term of effectiveTerms) {
    const idx = termIndex(term.year, term.term);
    const isBeforeOrAtCurrent = currentIdx != null && idx <= currentIdx;
    const isCurrentLike = currentIdx != null && idx === currentIdx;
    const isAfterCurrent = currentIdx != null && idx > currentIdx;

    if (isBeforeOrAtCurrent || term.status === "passed" || term.status === "current") {
      for (const code of term.courses) {
        const explicitOutcome = getExplicitOutcomeForCode(term, code, rawOutcomes);

        if (explicitOutcome === "pass" || explicitOutcome === "fail" || explicitOutcome === "withdraw") {
          normalized[code] = explicitOutcome;
          continue;
        }

        if (isCurrentLike) {
          normalized[code] = normalized[code] === "pass" ? "pass" : "fail";
          continue;
        }

        if (!Object.prototype.hasOwnProperty.call(normalized, code)) {
          normalized[code] = "notSet";
        }
      }
      continue;
    }

    if (term.status === "upcoming" || isAfterCurrent) {
      for (const code of term.courses) {
        normalized[code] = "notSet";
      }
    }
  }

  return normalized;
};

const getDependents = (failedCode, allCourses) => {
  const visited = new Set();

  const walk = (code) => {
    for (const [courseCode, info] of Object.entries(allCourses)) {
      const prerequisites = Array.isArray(info.prerequisites) ? info.prerequisites : [];
      if (prerequisites.includes(code) && !visited.has(courseCode)) {
        visited.add(courseCode);
        walk(courseCode);
      }
    }
  };

  walk(failedCode);
  return [...visited];
};

const dependencyWeightOf = (code, allCourses, memo = {}) => {
  if (memo[code] != null) return memo[code];
  const dependents = getDependents(code, allCourses);
  memo[code] = dependents.length;
  return memo[code];
};

const hasNoDependents = (code, allCourses) => {
  return !Object.values(allCourses).some((info) =>
    (info.prerequisites || []).includes(code),
  );
};

const findSwapSuggestions = (
  retakeCode,
  targetTermKey,
  effectiveTerms,
  termCreditsMap,
  outcomes,
  scheduleMap,
  allCourses,
) => {
  const targetTerm = effectiveTerms.find((t) => termKeyOf(t.year, t.term) === targetTermKey);
  if (!targetTerm) return [];

  const retakeCredits = allCourses[retakeCode]?.credits || 0;
  const retakeSchedule = scheduleMap[retakeCode] || [];
  const suggestions = [];

  for (const courseCode of targetTerm.courses) {
    if (courseCode === retakeCode) continue;
    const info = allCourses[courseCode];
    if (!info) continue;
    if (!hasNoDependents(courseCode, allCourses)) continue;

    const courseSchedule = scheduleMap[courseCode] || [];
    if (hasConflictWithSlots(retakeSchedule, courseSchedule)) continue;

    const moveToOptions = [];
    for (const term of effectiveTerms) {
      const termKey = termKeyOf(term.year, term.term);
      if (termKey === targetTermKey) continue;
      if (!(info.availableTerms || [1, 2]).includes(term.term)) continue;

      const currentCredits = termCreditsMap[termKey] || 0;
      if (currentCredits + (info.credits || 0) > MAX_CREDITS_PER_TERM) continue;
      if (
        currentCredits - (allCourses[courseCode]?.credits || 0) + retakeCredits >
        MAX_CREDITS_PER_TERM
      ) {
        continue;
      }

      const conflict = term.courses
        .filter((c) => c !== courseCode)
        .some((c) => hasConflictWithSlots(courseSchedule, scheduleMap[c] || []));

      if (!conflict) moveToOptions.push(termKey);
    }

    if (moveToOptions.length > 0) {
      suggestions.push({
        code: courseCode,
        name: info.name,
        credits: info.credits,
        moveTo: moveToOptions[0],
        moveToAll: moveToOptions,
      });
    }
  }

  return suggestions.sort((a, b) => a.credits - b.credits);
};

const isCoopExclusiveTerm = (term) => {
  return (
    term.year === 4 &&
    term.term === 2 &&
    Array.isArray(term.courses) &&
    term.courses.includes("CN404")
  );
};

const findSimulationFrontierIndex = (
  effectiveTerms,
  rawOutcomes = {},
  effectiveCurrentTerm = null,
) => {
  if (effectiveCurrentTerm) {
    const explicitIndex = effectiveTerms.findIndex((term) =>
      sameTerm(term, effectiveCurrentTerm),
    );
    if (explicitIndex >= 0) return explicitIndex;

    for (let i = 0; i < effectiveTerms.length; i += 1) {
      const term = effectiveTerms[i];
      if (termIndex(term.year, term.term) >= termIndex(effectiveCurrentTerm.year, effectiveCurrentTerm.term)) {
        return i;
      }
    }
  }

  for (let i = 0; i < effectiveTerms.length; i += 1) {
    if (effectiveTerms[i].status === "current") return i;
  }

  const firstUpcoming = effectiveTerms.findIndex((t) => t.status === "upcoming");
  return firstUpcoming >= 0 ? firstUpcoming : effectiveTerms.length;
};

const isDepartmentElective = (course) => {
  if (!course) return false;
  const category = String(course.category || "").trim().toLowerCase();
  return course.type === "major_elective" || category === "major elective";
};

const isGeneralEducation = (course) => {
  if (!course) return false;
  const category = String(course.category || "").trim().toLowerCase();
  return course.type === "general_education" || category === "general education";
};

const isFreeElective = (course) => {
  if (!course) return false;
  const category = String(course.category || "").trim().toLowerCase();
  return course.type === "free_elective" || category === "free elective";
};

const getTrackSelection = (termsByKey) => {
  const y4t1 = termsByKey[termKeyOf(4, 1)] || { courses: [] };
  const y4t2 = termsByKey[termKeyOf(4, 2)] || { courses: [] };

  return Object.values(TRACKS).filter(
    (track) => y4t1.courses.includes(track.term1) || y4t2.courses.includes(track.term2),
  );
};

const getIncompleteMajorElectivesFromPlan = (effectiveTerms, completedSet, allCourses) => {
  const codes = new Set();
  for (const term of effectiveTerms) {
    for (const code of term.courses) {
      if (isDepartmentElective(allCourses[code]) && !completedSet.has(code)) {
        codes.add(code);
      }
    }
  }
  return [...codes];
};

const getIncompleteGenEdFromPlan = (effectiveTerms, completedSet, allCourses) => {
  const codes = new Set();
  for (const term of effectiveTerms) {
    for (const code of term.courses) {
      if (isGeneralEducation(allCourses[code]) && !completedSet.has(code)) {
        codes.add(code);
      }
    }
  }
  return [...codes];
};

const getIncompleteFreeElectiveFromPlan = (effectiveTerms, completedSet, allCourses) => {
  const codes = new Set();
  for (const term of effectiveTerms) {
    for (const code of term.courses) {
      if (isFreeElective(allCourses[code]) && !completedSet.has(code)) {
        codes.add(code);
      }
    }
  }
  return [...codes];
};

const buildGraduationBacklog = ({
  effectiveTerms,
  allCourses,
  completedSet,
}) => {
  const termsByKey = Object.fromEntries(effectiveTerms.map((t) => [termKeyOf(t.year, t.term), t]));
  const selectedTracks = getTrackSelection(termsByKey);
  const selectedTrack = selectedTracks.length === 1 ? selectedTracks[0] : null;

  const backlog = new Set();

  for (const code of CORE_REQUIRED) {
    if (!completedSet.has(code)) backlog.add(code);
  }

  const term1Completed = TERM_1_ELECTIVES.filter((code) => completedSet.has(code)).length;
  const term2Completed = TERM_2_ELECTIVES.filter((code) => completedSet.has(code)).length;

  if (term1Completed < 3) {
    for (const code of TERM_1_ELECTIVES) {
      if (!completedSet.has(code)) backlog.add(code);
    }
  }
  if (term2Completed < 3) {
    for (const code of TERM_2_ELECTIVES) {
      if (!completedSet.has(code)) backlog.add(code);
    }
  }

  if (selectedTrack) {
    if (!completedSet.has(selectedTrack.term1)) backlog.add(selectedTrack.term1);
    if (!completedSet.has(selectedTrack.term2)) backlog.add(selectedTrack.term2);
  }

  for (const code of getIncompleteMajorElectivesFromPlan(effectiveTerms, completedSet, allCourses)) {
    backlog.add(code);
  }

  for (const code of getIncompleteGenEdFromPlan(effectiveTerms, completedSet, allCourses)) {
    backlog.add(code);
  }

  for (const code of getIncompleteFreeElectiveFromPlan(effectiveTerms, completedSet, allCourses)) {
    backlog.add(code);
  }

  return {
    backlog: [...backlog],
    selectedTrack,
  };
};

const canCourseBeTakenInTerm = ({
  code,
  term,
  allCourses,
  completedSet,
  scheduleMap,
  plannedCodes,
  usedCredits,
  selectedTrack,
}) => {
  const info = allCourses[code];
  if (!info) return false;

  if (!(info.availableTerms || [1, 2]).includes(term.term)) return false;

  if ((info.prerequisites || []).some((pr) => !completedSet.has(pr))) return false;

  if (usedCredits + (info.credits || 0) > MAX_CREDITS_PER_TERM) return false;

  if (selectedTrack?.key === "coop" && term.year === 4 && term.term === 2) {
    if (code !== "CN404") return false;
    if (plannedCodes.length > 0 && !plannedCodes.includes("CN404")) return false;
  }

  const mySchedule = scheduleMap[code] || [];
  const conflict = plannedCodes.some((planned) =>
    hasConflictWithSlots(mySchedule, scheduleMap[planned] || []),
  );
  if (conflict) return false;

  return true;
};

const scheduleBacklogBestCase = ({
  effectiveTerms,
  allCourses,
  scheduleMap,
  completedSet,
  fixedTermCredits,
  fixedPlannedCodesByTerm,
  backlogCodes,
  selectedTrack,
  frontierIndex,
  horizonTermIndex,
}) => {
  const projectionTerms = buildProjectionTerms(effectiveTerms, 8);
  const dependencyMemo = {};
  const scheduledByTerm = {};
  const scheduledSet = new Set();
  let rollingCompleted = new Set(completedSet);
  let completionTermIndex = backlogCodes.every((code) => rollingCompleted.has(code))
    ? horizonTermIndex
    : null;

  for (let i = 0; i < projectionTerms.length; i += 1) {
    const term = projectionTerms[i];
    const idx = termIndex(term.year, term.term);
    const termKey = termKeyOf(term.year, term.term);

    if (i < frontierIndex) continue;

    const fixedCodes = fixedPlannedCodesByTerm[termKey] || [];
    const dynamicCodes = [];
    let usedCredits = fixedTermCredits[termKey] || 0;

    const remaining = backlogCodes.filter(
      (code) => !rollingCompleted.has(code) && !scheduledSet.has(code),
    );

    const candidates = remaining
      .filter((code) =>
        canCourseBeTakenInTerm({
          code,
          term,
          allCourses,
          completedSet: rollingCompleted,
          scheduleMap,
          plannedCodes: [...fixedCodes, ...dynamicCodes],
          usedCredits,
          selectedTrack,
        }),
      )
      .sort((a, b) => {
        const aInfo = allCourses[a] || {};
        const bInfo = allCourses[b] || {};
        const aWeight = dependencyWeightOf(a, allCourses, dependencyMemo);
        const bWeight = dependencyWeightOf(b, allCourses, dependencyMemo);
        const aCore = CORE_REQUIRED.includes(a) ? 1 : 0;
        const bCore = CORE_REQUIRED.includes(b) ? 1 : 0;
        if (bWeight !== aWeight) return bWeight - aWeight;
        if (bCore !== aCore) return bCore - aCore;
        return (bInfo.credits || 0) - (aInfo.credits || 0);
      });

    for (const code of candidates) {
      const info = allCourses[code] || {};
      if (
        canCourseBeTakenInTerm({
          code,
          term,
          allCourses,
          completedSet: rollingCompleted,
          scheduleMap,
          plannedCodes: [...fixedCodes, ...dynamicCodes],
          usedCredits,
          selectedTrack,
        })
      ) {
        dynamicCodes.push(code);
        scheduledSet.add(code);
        usedCredits += info.credits || 0;
      }
    }

    scheduledByTerm[termKey] = [...fixedCodes, ...dynamicCodes];

    for (const code of scheduledByTerm[termKey]) {
      rollingCompleted.add(code);
    }

    const remainingAfterThisTerm = backlogCodes.filter((code) => !rollingCompleted.has(code));
    if (completionTermIndex == null && remainingAfterThisTerm.length === 0) {
      completionTermIndex = idx;
    }

    if (idx >= horizonTermIndex && remainingAfterThisTerm.length === 0) {
      return {
        scheduledByTerm,
        completedByHorizon: new Set(rollingCompleted),
        firstTermBeyondHorizonNeeded: null,
        completionTermIndex,
      };
    }
  }

  const remaining = backlogCodes.filter((code) => !rollingCompleted.has(code));
  let firstTermBeyondHorizonNeeded = null;
  if (remaining.length > 0) {
    for (const term of projectionTerms) {
      const idx = termIndex(term.year, term.term);
      const termKey = termKeyOf(term.year, term.term);
      const scheduled = scheduledByTerm[termKey] || [];
      const anyRemainingHere = scheduled.some((code) => remaining.includes(code));
      if (idx > horizonTermIndex && anyRemainingHere) {
        firstTermBeyondHorizonNeeded = idx;
        break;
      }
    }
    if (firstTermBeyondHorizonNeeded == null) {
      firstTermBeyondHorizonNeeded = horizonTermIndex + 1;
    }
  }

  return {
    scheduledByTerm,
    completedByHorizon: new Set(rollingCompleted),
    firstTermBeyondHorizonNeeded,
    completionTermIndex,
  };
};

const buildExactYearPathSummary = ({
  allCourses,
  effectiveTerms,
  outcomes,
  effectiveCurrentTerm,
  scheduleMap,
}) => {
  const frontierIndex = findSimulationFrontierIndex(
    effectiveTerms,
    outcomes,
    effectiveCurrentTerm,
  );

  const completedSet = new Set();
  const fixedTermCredits = {};
  const fixedPlannedCodesByTerm = {};

  for (let i = 0; i < effectiveTerms.length; i += 1) {
    const term = effectiveTerms[i];
    const termKey = termKeyOf(term.year, term.term);
    fixedTermCredits[termKey] = 0;
    fixedPlannedCodesByTerm[termKey] = [];

    const isCurrentLike = sameTerm(term, effectiveCurrentTerm);

    if (i < frontierIndex || isCurrentLike) {
      for (const code of term.courses) {
        if ((outcomes[code] || "notSet") === "pass") {
          completedSet.add(code);
          fixedPlannedCodesByTerm[termKey].push(code);
          fixedTermCredits[termKey] += allCourses[code]?.credits || 0;
        } else if (isCurrentLike) {
          fixedPlannedCodesByTerm[termKey].push(code);
          fixedTermCredits[termKey] += allCourses[code]?.credits || 0;
        }
      }
    }
  }

  const { backlog, selectedTrack } = buildGraduationBacklog({
    effectiveTerms,
    allCourses,
    completedSet,
  });

  const horizonTermIndex = BASELINE_TERM_INDEX;
  const scheduleResult = scheduleBacklogBestCase({
    effectiveTerms,
    allCourses,
    scheduleMap,
    completedSet,
    fixedTermCredits,
    fixedPlannedCodesByTerm,
    backlogCodes: backlog,
    selectedTrack,
    frontierIndex,
    horizonTermIndex,
  });

  const projectionTerms = buildProjectionTerms(effectiveTerms, 8);

  const completedByBaseline = new Set(completedSet);
  for (const term of projectionTerms) {
    const idx = termIndex(term.year, term.term);
    if (idx > BASELINE_TERM_INDEX) continue;
    const codes = scheduleResult.scheduledByTerm[termKeyOf(term.year, term.term)] || [];
    for (const code of codes) completedByBaseline.add(code);
  }

  const projectedCompletedCreditsByYear4Term2 = [...completedByBaseline].reduce(
    (sum, code) => sum + (allCourses[code]?.credits || 0),
    0,
  );

  const canCompleteByYear4Term2 = backlog.every((code) => completedByBaseline.has(code));

  const projectedGraduationIndex =
    scheduleResult.completionTermIndex ||
    (canCompleteByYear4Term2 ? BASELINE_TERM_INDEX : scheduleResult.firstTermBeyondHorizonNeeded || (BASELINE_TERM_INDEX + 1));

  const delayTerms = Math.max(0, projectedGraduationIndex - BASELINE_TERM_INDEX);
  const extraYearsNeeded = Number((delayTerms / 2).toFixed(1));
  const projectedGraduationTerm = termIndexToObject(projectedGraduationIndex);

  const changedYears = [...new Set(
    effectiveTerms.flatMap((term) =>
      term.courses
        .filter((code) => (outcomes[code] || "notSet") === "fail")
        .map(() => term.year),
    ),
  )].filter((year) => year <= Math.max(4, projectedGraduationTerm?.year || 4)).sort((a, b) => a - b);

  const statusText = canCompleteByYear4Term2
    ? "Best case: still on track to graduate within 4 years."
    : `Best case: projected graduation is ${projectedGraduationTerm?.label || "later than Year 4 / Term 2"} (delay ${delayTerms} term(s), ${extraYearsNeeded} year(s)).`;

  return {
    canCompleteByYear4Term2,
    baselineLabel: "Year 4 / Term 2",
    delayTerms,
    extraYearsNeeded,
    projectedCompletedCreditsByYear4Term2,
    totalRequiredCredits: TOTAL_PROGRAM_CREDITS,
    selectedTrack: selectedTrack ? selectedTrack.label : null,
    changedYears,
    missingRequirements: backlog.filter((code) => !completedByBaseline.has(code)),
    genEdCredits: [...completedByBaseline].reduce(
      (sum, code) => sum + (isGeneralEducation(allCourses[code]) ? (allCourses[code]?.credits || 0) : 0),
      0,
    ),
    freeElectiveCredits: [...completedByBaseline].reduce(
      (sum, code) => sum + (isFreeElective(allCourses[code]) ? (allCourses[code]?.credits || 0) : 0),
      0,
    ),
    term1ElectiveCount: TERM_1_ELECTIVES.filter((code) => completedByBaseline.has(code)).length,
    term2ElectiveCount: TERM_2_ELECTIVES.filter((code) => completedByBaseline.has(code)).length,
    statusText,
    scheduledByTerm: scheduleResult.scheduledByTerm,
    projectedGraduationTerm,
  };
};

const getRetakeOptions = (
  code,
  outcomes,
  termCreditsMap = {},
  scheduleMap = {},
  effectiveTerms = TERMS,
  allCourses = COURSES,
  effectiveCurrentTerm = null,
  visibleMaxTermIndex = null,
) => {
  const maxExtraYears = visibleMaxTermIndex != null
    ? Math.max(4, Math.ceil((visibleMaxTermIndex - BASELINE_TERM_INDEX) / 2) + 4)
    : 8;
  const projectionTerms = buildProjectionTerms(effectiveTerms, maxExtraYears);
  const originalTerm =
    normalTermOf(code, effectiveTerms) ||
    normalTermOf(code, projectionTerms) ||
    normalTermOf(code, TERMS);

  if (!originalTerm) return [];

  const originalIndex = projectionTerms.findIndex(
    (t) => t.year === originalTerm.year && t.term === originalTerm.term,
  );
  if (originalIndex === -1) return [];

  const frontierIndex = findSimulationFrontierIndex(
    effectiveTerms,
    outcomes,
    effectiveCurrentTerm,
  );

  const minStartIndex = Math.max(originalIndex + 1, frontierIndex + 1);

  const courseInfo = allCourses[code];
  const availableTerms = courseInfo?.availableTerms || [1, 2];
  const courseCredits = courseInfo?.credits || 0;

  return projectionTerms
    .slice(minStartIndex)
    .filter((term) => visibleMaxTermIndex == null || termIndex(term.year, term.term) <= visibleMaxTermIndex)
    .map((term) => {
      const termKey = termKeyOf(term.year, term.term);
      const termData =
        effectiveTerms.find((t) => t.year === term.year && t.term === term.term) || term;

      const coopBlocked = isIgnoredCoopTermForRetake(termData, code, effectiveTerms);

      const mandatory = termData.courses.filter(
        (c) => c !== code && (outcomes[c] || "notSet") !== "withdraw",
      );

      const mySchedule = scheduleMap[code] || [];

      const conflicts = mandatory
        .filter((c) => hasConflictWithSlots(mySchedule, scheduleMap[c] || []))
        .map((c) => ({
          code: c,
          name: allCourses[c]?.name || c,
          schedule: scheduleMap[c] || [],
        }));

      const currentTermCredits = termCreditsMap[termKey] || 0;
      const creditsAfterRetake = currentTermCredits + courseCredits;
      const wouldExceedLimit = creditsAfterRetake > MAX_CREDITS_PER_TERM;
      const termAvailable = !coopBlocked && availableTerms.includes(term.term);
      const canRetake = termAvailable && conflicts.length === 0 && !wouldExceedLimit;

      const swapSuggestions =
        !canRetake && termAvailable
          ? findSwapSuggestions(
              code,
              termKey,
              effectiveTerms,
              termCreditsMap,
              outcomes,
              scheduleMap,
              allCourses,
            )
          : [];

      return {
        year: term.year,
        term: term.term,
        label: termKey,
        canRetake,
        termAvailable,
        conflicts,
        wouldExceedLimit,
        creditsAfterRetake,
        maxCredits: MAX_CREDITS_PER_TERM,
        swapSuggestions,
      };
    });
};

const checkTermCreditLimits = (effectiveTerms, termCreditsMap) => {
  const violations = [];

  for (const term of effectiveTerms) {
    const termKey = termKeyOf(term.year, term.term);
    const credits = termCreditsMap[termKey] || 0;
    if (credits <= 0) continue;

    if (isCoopExclusiveTerm(term)) {
      if (credits > MAX_CREDITS_PER_TERM) {
        violations.push({
          termKey,
          credits,
          issue: "over",
          message: `Warning: ${termKey} has ${credits} credits enrolled (maximum allowed: ${MAX_CREDITS_PER_TERM}).`,
        });
      }
      continue;
    }

    if (credits < MIN_CREDITS_PER_TERM) {
      violations.push({
        termKey,
        credits,
        issue: "under",
        message: `Warning: ${termKey} has only ${credits} credit(s) enrolled (minimum recommended: ${MIN_CREDITS_PER_TERM}).`,
      });
    } else if (credits > MAX_CREDITS_PER_TERM) {
      violations.push({
        termKey,
        credits,
        issue: "over",
        message: `Warning: ${termKey} has ${credits} credits enrolled (maximum allowed: ${MAX_CREDITS_PER_TERM}).`,
      });
    }
  }

  return violations;
};

const buildImpactSummary = (
  code,
  outcome,
  blockedCourses,
  retakeOptions,
  allCourses,
  termPool,
) => {
  const info = allCourses[code] || {};
  const word = outcome === "fail" ? "Failed (F)" : "Withdrawn (W)";
  const normTerm = normalTermOf(code, termPool) || normalTermOf(code, TERMS);
  const lines = [];

  lines.push(`Course ${code} - ${info.name || code}: ${word}`);
  if (normTerm) {
    lines.push(`Normally planned in Year ${normTerm.year} / Term ${normTerm.term}`);
  }
  lines.push(`Offered in term(s): ${(info.availableTerms || [1, 2]).join(" and ")}`);
  lines.push(
    outcome === "fail"
      ? "Must be retaken before taking courses that depend on it."
      : "No credit earned; the course must be taken again in an available term.",
  );

  if (blockedCourses.length > 0) {
    lines.push(`Blocked courses: ${blockedCourses.map((b) => b.code).join(", ")}`);
  }

  const firstRetake = retakeOptions.find((r) => r.canRetake);
  if (firstRetake) {
    lines.push(`Best retake option: ${firstRetake.label}`);
  } else {
    lines.push("No feasible retake slot was found in the current projection.");
  }

  return lines.join("\n");
};

const runSimulation = (
  rawOutcomes = {},
  customCourses = {},
  simulatedTerms = null,
  simulatedCurrentTerm = null,
) => {
  const allCourses = buildAllCourses(customCourses);

  const effectiveTerms =
    Array.isArray(simulatedTerms) && simulatedTerms.length > 0
      ? sortAndNormalizeTerms(simulatedTerms)
      : sortAndNormalizeTerms(TERMS);

  const effectiveCurrentTerm = resolveEffectiveCurrentTerm(
    effectiveTerms,
    rawOutcomes,
    simulatedCurrentTerm,
  );

  const outcomes = normalizeOutcomesForSimulation(
    effectiveTerms,
    rawOutcomes,
    effectiveCurrentTerm,
  );

  const scheduleMap = buildScheduleMap(customCourses);

  const termCreditsMap = {};
  for (const term of effectiveTerms) {
    const termKey = termKeyOf(term.year, term.term);
    const credits = term.courses
      .filter((code) => (outcomes[code] || "notSet") !== "withdraw")
      .reduce((sum, code) => sum + (allCourses[code]?.credits || 0), 0);

    termCreditsMap[termKey] = credits;
  }

  let earnedCredits = 0;
  const failed = [];
  const withdrawn = [];
  const passed = [];

  for (const [code, outcome] of Object.entries(outcomes)) {
    const info = allCourses[code];
    if (!info) continue;

    if (outcome === "pass") {
      earnedCredits += info.credits || 0;
      passed.push(code);
    } else if (outcome === "fail") {
      failed.push(code);
    } else if (outcome === "withdraw") {
      withdrawn.push(code);
    }
  }

  const yearPathSummary = buildExactYearPathSummary({
    allCourses,
    effectiveTerms,
    outcomes,
    effectiveCurrentTerm,
    scheduleMap,
  });

  const effectiveCurrentTermIndex = effectiveCurrentTerm
    ? termIndex(effectiveCurrentTerm.year, effectiveCurrentTerm.term)
    : null;
  const projectedTermIndex = yearPathSummary?.projectedGraduationTerm?.index || BASELINE_TERM_INDEX;
  const visibleMaxTermIndex = Math.max(
    BASELINE_TERM_INDEX,
    projectedTermIndex,
    ...(effectiveTerms.map((t) => termIndex(t.year, t.term))),
    effectiveCurrentTermIndex || 0,
  );

  const impacts = [...failed, ...withdrawn]
    .map((code) => {
      const outcome = outcomes[code];
      const dependents = getDependents(code, allCourses);

      const retakeOptions = getRetakeOptions(
        code,
        outcomes,
        termCreditsMap,
        scheduleMap,
        effectiveTerms,
        allCourses,
        effectiveCurrentTerm,
        visibleMaxTermIndex,
      );

      const blockedCourses = dependents.map((dep) => {
        const plannedTerm = normalTermOf(dep, effectiveTerms) || normalTermOf(dep, TERMS);
        return {
          code: dep,
          name: allCourses[dep]?.name || dep,
          term: plannedTerm ? termKeyOf(plannedTerm.year, plannedTerm.term) : "Unknown",
          currentOutcome: outcomes[dep] || "notSet",
        };
      });

      const originalTerm = normalTermOf(code, effectiveTerms) || normalTermOf(code, TERMS);

      return {
        code,
        name: allCourses[code]?.name || code,
        outcome,
        normalTerm: originalTerm
          ? termKeyOf(originalTerm.year, originalTerm.term)
          : "Unknown",
        availableTerms: (allCourses[code]?.availableTerms || [1, 2]).map(String),
        blockedCourses,
        retakeOptions,
        summary: buildImpactSummary(
          code,
          outcome,
          blockedCourses,
          retakeOptions,
          allCourses,
          effectiveTerms,
        ),
      };
    })
    .filter((impact) => {
      const match = /Year\s+(\d+)\s*\/\s*Term\s*(\d+)/.exec(impact.normalTerm || "");
      if (!match) return true;
      return termIndex(Number(match[1]), Number(match[2])) <= visibleMaxTermIndex;
    });

  const prereqViolations = [];
  for (const [code, outcome] of Object.entries(outcomes)) {
    if (outcome !== "pass") continue;
    const info = allCourses[code];
    if (!info) continue;

    for (const prereq of info.prerequisites || []) {
      if ((outcomes[prereq] || "notSet") !== "pass") {
        prereqViolations.push({
          code,
          name: info.name,
          missingPrereq: prereq,
          missingPrereqName: allCourses[prereq]?.name || prereq,
        });
      }
    }
  }

  const creditViolations = checkTermCreditLimits(effectiveTerms, termCreditsMap);

  const warnings = [];
  if (failed.length > 2) {
    warnings.push(
      "More than 2 failed courses are selected. This may affect multiple future terms.",
    );
  }

  if (prereqViolations.length > 0) {
    warnings.push(
      `Some courses are marked Pass while prerequisites are still missing: ${prereqViolations
        .map((v) => v.code)
        .join(", ")}.`,
    );
  }

  creditViolations.forEach((violation) => warnings.push(violation.message));

  if (!yearPathSummary.canCompleteByYear4Term2) {
    warnings.push(yearPathSummary.statusText);
  }

  return {
    summary: {
      earnedCredits,
      totalCredits: TOTAL_PROGRAM_CREDITS,
      progressPercent: Number(
        ((earnedCredits / TOTAL_PROGRAM_CREDITS) * 100).toFixed(1),
      ),
      passCount: passed.length,
      failCount: failed.length,
      withdrawCount: withdrawn.length,
      failedCourses: failed.map((code) => ({
        code,
        name: allCourses[code]?.name || code,
      })),
      withdrawnCourses: withdrawn.map((code) => ({
        code,
        name: allCourses[code]?.name || code,
      })),
    },
    termCreditsMap,
    creditViolations,
    impacts,
    prereqViolations,
    warnings,
    yearPathSummary,
    currentYear: effectiveCurrentTerm ? effectiveCurrentTerm.year : null,
    projectedGraduationTerm: yearPathSummary?.projectedGraduationTerm || null,
    effectiveCurrentTerm: effectiveCurrentTerm
      ? {
          year: effectiveCurrentTerm.year,
          term: effectiveCurrentTerm.term,
          label: termKeyOf(effectiveCurrentTerm.year, effectiveCurrentTerm.term),
          source: effectiveCurrentTerm.source || null,
        }
      : null,
  };
};

module.exports = {
  runSimulation,
  getDependents,
  getRetakeOptions,
  checkTermCreditLimits,
};
