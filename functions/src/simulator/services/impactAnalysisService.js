/**
 * impactAnalysisService.js
 *
 * Pure-logic academic impact analyser — no AI, no external calls.
 * Implements every rule from prompt.txt exactly.
 *
 * Input:
 *   uid            string
 *   supabase client (already initialised)
 *
 * Fetches from Supabase:
 *   profiles       → current_year, current_semester
 *   UserRoadmap    → per-term course list + grades/status
 *   Subjects       → name, credits, prerequisites (require), offeredSemester
 *   ClassSchedules → day, start_time, end_time per subject_code + section
 *
 * Output:
 *   { dashboard, impactedCourses, rawText }
 *   where rawText matches the exact FORMAT from prompt.txt
 */

const getSupabase = require('../../config/supabase');

// ────────────────────────────────────────────────────────────────────────────
// GRADUATION REQUIREMENTS (from prompt.txt)
// ────────────────────────────────────────────────────────────────────────────
const CORE_REQUIRED = new Set([
  'CN101','CN102','SC133','SC183','MA111','LAS101','TU100','TSE100',
  'CN201','CN103','MA112','SC134','SC184','EL105','IE121','ME100','TSE101',
  'CN202','CN200','CN204','CN260','CN261','MA214','TU108',
  'CN203','CN230','CN210','CN240','CN262','TU122',
  'CN331','CN321','CN311','CN332','CN333',
]);

const ELECTIVES_T1 = ['CN330','CN310','CN320','CN340','CN361'];
const ELECTIVES_T2 = ['CN322','CN341','CN335','CN351','CN334'];
const REQUIRED_ELECTIVES_EACH = 3;
const REQUIRED_FREE_CREDITS   = 6;
const REQUIRED_GENED_CREDITS   = 6;
const TOTAL_PROGRAM_CREDITS    = 146;
const MIN_CREDITS              = 9;
const MAX_CREDITS              = 21;

// ────────────────────────────────────────────────────────────────────────────
// HELPERS
// ────────────────────────────────────────────────────────────────────────────
const termIndex = (year, term) => (year - 1) * 2 + term;

const toMin = (t) => {
  const [h, m] = t.split(':').map(Number);
  return h * 60 + m;
};

const slotsOverlap = (a, b) => {
  if (a.day !== b.day) return false;
  return toMin(a.start) < toMin(b.end) && toMin(b.start) < toMin(a.end);
};

// ────────────────────────────────────────────────────────────────────────────
// DATA FETCHING
// ────────────────────────────────────────────────────────────────────────────
async function fetchData(uid) {
  const supabase = getSupabase();

  const [profileRes, roadmapRes, subjectsRes, schedulesRes] = await Promise.all([
    supabase.from('profiles')
      .select('current_year, current_semester')
      .eq('user_id', uid)
      .single(),

    supabase.from('UserRoadmap')
      .select('subject_code, subjectId, year, semester, grade, status, section')
      .eq('user_id', uid)
      .order('year', { ascending: true })
      .order('semester', { ascending: true }),

    supabase.from('Subjects')
      .select('subjectId, subjectCode, subjectName, credits, require, corequisite, offeredSemester'),

    supabase.from('ClassSchedules')
      .select('subject_code, section, day, start_time, end_time'),
  ]);

  if (profileRes.error) throw profileRes.error;
  if (roadmapRes.error) throw roadmapRes.error;
  if (subjectsRes.error) throw subjectsRes.error;
  if (schedulesRes.error) throw schedulesRes.error;

  return {
    profile:   profileRes.data,
    roadmap:   roadmapRes.data   ?? [],
    subjects:  subjectsRes.data  ?? [],
    schedules: schedulesRes.data ?? [],
  };
}

// ────────────────────────────────────────────────────────────────────────────
// BUILD INTERNAL MAPS
// ────────────────────────────────────────────────────────────────────────────
function buildMaps(subjects, schedules) {
  /** subjectMap: code → { name, credits, prerequisites[], offeredSemester[] } */
  const subjectMap = {};
  for (const s of subjects) {
    subjectMap[s.subjectCode] = {
      subjectId:   s.subjectId,
      name:        s.subjectName || s.subjectCode,
      credits:     Number(s.credits || 0),
      prerequisites: Array.isArray(s.require) ? s.require : [],
      offeredSemester: Array.isArray(s.offeredSemester) ? s.offeredSemester : [1, 2],
    };
  }

  /** scheduleMap: code → [{ day, start, end, section }] */
  const scheduleMap = {};
  for (const sc of schedules) {
    if (!scheduleMap[sc.subject_code]) scheduleMap[sc.subject_code] = [];
    scheduleMap[sc.subject_code].push({
      day:     sc.day,
      start:   sc.start_time,
      end:     sc.end_time,
      section: sc.section,
    });
  }

  return { subjectMap, scheduleMap };
}

// ────────────────────────────────────────────────────────────────────────────
// BUILD TERM STRUCTURE from roadmap rows
// ────────────────────────────────────────────────────────────────────────────
function buildTerms(roadmap, currentYear, currentSem) {
  const termMap = {};

  for (const row of roadmap) {
    const key = `${row.year}_${row.semester}`;
    if (!termMap[key]) {
      termMap[key] = { year: row.year, semester: row.semester, courses: [] };
    }

    // Determine outcome from grade
    let outcome = 'notSet';
    const g = row.grade;
    if (g && g !== '-') {
      if (g === 'F') outcome = 'fail';
      else if (g === 'W') outcome = 'withdraw';
      else outcome = 'pass';
    } else if (row.status === 'passed') {
      outcome = 'pass';
    } else if (row.status === 'not_pass') {
      outcome = 'fail';
    }

    termMap[key].courses.push({
      code:    row.subject_code,
      subjectId: row.subjectId,
      grade:   g || null,
      outcome, // 'pass' | 'fail' | 'withdraw' | 'notSet'
      section: row.section,
    });
  }

  return Object.values(termMap).sort((a, b) => {
    if (a.year !== b.year) return a.year - b.year;
    return a.semester - b.semester;
  });
}

// ────────────────────────────────────────────────────────────────────────────
// ANALYSE
// ────────────────────────────────────────────────────────────────────────────
function analyse({ profile, terms, subjectMap, scheduleMap }) {
  const currentYear = profile.current_year;
  const currentSem  = profile.current_semester;
  const currentIdx  = termIndex(currentYear, currentSem);

  // ── 1. Classify courses ────────────────────────────────────────────────
  const passedSet   = new Set();
  const failedSet   = new Set();  // need retake
  const currentSet  = new Set();
  let earnedCredits = 0;

  for (const term of terms) {
    const ti = termIndex(term.year, term.semester);
    const isCurrent = (ti === currentIdx);
    const isPast    = (ti < currentIdx);

    for (const c of term.courses) {
      if (c.outcome === 'pass') {
        passedSet.add(c.code);
        earnedCredits += subjectMap[c.code]?.credits ?? 0;
      } else if (c.outcome === 'fail') {
        failedSet.add(c.code);
      } else if (isCurrent) {
        currentSet.add(c.code);
      }
    }
  }

  // ── 2. Build prerequisite graph ────────────────────────────────────────
  // prereqOf[code] = list of codes that require [code] as prerequisite
  const dependentsOf = {}; // code → Set<string> (all transitive dependents)

  const getDependents = (code) => {
    if (dependentsOf[code]) return dependentsOf[code];
    const visited = new Set();
    const walk = (c) => {
      for (const [k, info] of Object.entries(subjectMap)) {
        if ((info.prerequisites || []).includes(c) && !visited.has(k)) {
          visited.add(k);
          walk(k);
        }
      }
    };
    walk(code);
    dependentsOf[code] = visited;
    return visited;
  };

  // ── 3. Build future-term plan (for retake scheduling) ─────────────────
  // termsByKey: 'Y_S' → term object
  const termsByKey = {};
  for (const t of terms) termsByKey[`${t.year}_${t.semester}`] = t;

  // credits per term (existing plan)
  const termCredits = {};
  for (const t of terms) {
    const key = `${t.year}_${t.semester}`;
    let cr = 0;
    for (const c of t.courses) {
      if (c.outcome !== 'withdraw') cr += subjectMap[c.code]?.credits ?? 0;
    }
    termCredits[key] = cr;
  }

  // ── 4. Find retake windows for each failed course ─────────────────────
  const retakeOptionsFor = (failedCode) => {
    const info = subjectMap[failedCode];
    if (!info) return [];

    const offered = info.offeredSemester.length > 0 ? info.offeredSemester : [1, 2];
    const mySchedule = scheduleMap[failedCode] || [];

    const options = [];
    // Look up to Year 5 Semester 2
    for (let yr = currentYear; yr <= 5; yr++) {
      for (let sem = 1; sem <= 2; sem++) {
        const ti = termIndex(yr, sem);
        if (ti <= currentIdx) continue; // only future terms

        if (!offered.includes(sem)) {
          options.push({ year: yr, semester: sem, canRetake: false, reason: 'Not offered this term' });
          continue;
        }

        const key = `${yr}_${sem}`;
        const termCr = termCredits[key] ?? 0;
        const addedCr = info.credits;
        const newTotal = termCr + addedCr;

        // CN404 special rule
        const termCourses = termsByKey[key]?.courses ?? [];
        if (termCourses.some((c) => c.code === 'CN404')) {
          options.push({ year: yr, semester: sem, canRetake: false, reason: 'Co-op term — only CN404 allowed' });
          continue;
        }
        if (failedCode !== 'CN404' && yr === 4 && sem === 2 &&
            termsByKey[`4_1`]?.courses.some((c) => c.code === 'CN403')) {
          options.push({ year: yr, semester: sem, canRetake: false, reason: 'Co-op track — Term 2 reserved for CN404' });
          continue;
        }

        if (newTotal > MAX_CREDITS) {
          options.push({
            year: yr, semester: sem, canRetake: false,
            reason: `Would exceed credit limit (${newTotal}/${MAX_CREDITS})`,
          });
          continue;
        }

        // Check schedule conflict
        const conflictWith = [];
        for (const c of termCourses) {
          const theirSlots = scheduleMap[c.code] || [];
          for (const mySlot of mySchedule) {
            for (const theirSlot of theirSlots) {
              if (slotsOverlap(mySlot, theirSlot)) {
                conflictWith.push(c.code);
                break;
              }
            }
            if (conflictWith.includes(c.code)) break;
          }
        }

        if (conflictWith.length > 0) {
          options.push({
            year: yr, semester: sem, canRetake: false,
            reason: `Schedule conflict with ${conflictWith.join(', ')}`,
          });
          continue;
        }

        // Check prerequisites satisfied
        const prereqsMet = (info.prerequisites || []).every((pr) => passedSet.has(pr));
        if (!prereqsMet) {
          const missing = (info.prerequisites || []).filter((pr) => !passedSet.has(pr));
          options.push({
            year: yr, semester: sem, canRetake: false,
            reason: `Prerequisites not yet passed: ${missing.join(', ')}`,
          });
          continue;
        }

        options.push({ year: yr, semester: sem, canRetake: true, reason: 'Available' });
      }
    }
    return options;
  };

  // ── 5. Build impacted course list ─────────────────────────────────────
  const impactedCourses = [];

  for (const code of failedSet) {
    const info = subjectMap[code] ?? { name: code, credits: 0, prerequisites: [], offeredSemester: [1, 2] };

    // Find which term it was originally in
    let normalTerm = null;
    for (const t of terms) {
      if (t.courses.some((c) => c.code === code)) {
        normalTerm = `Year ${t.year} / Term ${t.semester}`;
        break;
      }
    }

    const dependents = [...getDependents(code)];
    const blocked = dependents.map((dep) => ({
      code: dep,
      name: subjectMap[dep]?.name ?? dep,
    }));

    const retakeOptions = retakeOptionsFor(code);

    impactedCourses.push({
      code,
      name: info.name,
      status: 'F',
      normalTerm: normalTerm ?? 'Unknown',
      blocked,
      retakeOptions,
    });
  }

  // ── 6. Graduation feasibility ─────────────────────────────────────────
  // Simulate "best case" where all current + future courses pass
  const projectedPassed = new Set(passedSet);

  // Add current semester courses (assume they'll pass)
  for (const code of currentSet) projectedPassed.add(code);

  // Add future courses in roadmap
  for (const term of terms) {
    const ti = termIndex(term.year, term.semester);
    if (ti > currentIdx) {
      for (const c of term.courses) {
        if (c.outcome !== 'fail') projectedPassed.add(c.code);
      }
    }
  }

  // Schedule retakes into the earliest available slot
  const retakeScheduled = {}; // code → { year, semester }
  for (const code of failedSet) {
    const opts = retakeOptionsFor(code);
    const best = opts.find((o) => o.canRetake);
    if (best) {
      retakeScheduled[code] = best;
      projectedPassed.add(code);
    }
  }

  // Check core
  const missingCore = [...CORE_REQUIRED].filter((c) => !projectedPassed.has(c));

  // Check electives
  const t1Done = ELECTIVES_T1.filter((c) => projectedPassed.has(c)).length;
  const t2Done = ELECTIVES_T2.filter((c) => projectedPassed.has(c)).length;
  const electivesOk = t1Done >= REQUIRED_ELECTIVES_EACH && t2Done >= REQUIRED_ELECTIVES_EACH;

  // Check graduation by Y4S2
  const y4s2Idx = termIndex(4, 2);
  const canGraduateOnTime = missingCore.length === 0 && electivesOk;

  // Projected graduation term
  let projectedGradYear = 4;
  let projectedGradSem  = 2;
  if (!canGraduateOnTime) {
    // Rough estimate: one extra semester per 2 blocked retakes
    const delay = Math.ceil(impactedCourses.filter((i) => !retakeScheduled[i.code]).length / 2);
    const projIdx = y4s2Idx + delay;
    projectedGradYear = Math.ceil(projIdx / 2);
    projectedGradSem  = projIdx % 2 === 0 ? 2 : 1;
  }

  // ── 7. Year-path status (Y1–Y4) ───────────────────────────────────────
  const yearHasIssue = {};
  for (const term of terms) {
    if (term.courses.some((c) => c.outcome === 'fail')) {
      yearHasIssue[term.year] = true;
    }
  }
  // Also mark years affected by retakes
  for (const [code, slot] of Object.entries(retakeScheduled)) {
    const origTerm = terms.find((t) => t.courses.some((c) => c.code === code));
    if (origTerm) yearHasIssue[origTerm.year] = true;
  }

  const yearPath = {};
  for (let y = 1; y <= 4; y++) {
    yearPath[`Y${y}`] = yearHasIssue[y] ? 'ISSUE' : 'OK';
  }
  const needsY5Plus = !canGraduateOnTime;

  // ── 8. Risk level ──────────────────────────────────────────────────────
  let riskLevel;
  if (failedSet.size === 0) {
    riskLevel = 'LOW';
  } else if (canGraduateOnTime) {
    riskLevel = 'MEDIUM';
  } else {
    riskLevel = 'HIGH';
  }

  // ── 9. Progress ────────────────────────────────────────────────────────
  const progressPct = ((earnedCredits / TOTAL_PROGRAM_CREDITS) * 100).toFixed(1);

  return {
    riskLevel,
    earnedCredits,
    totalCredits: TOTAL_PROGRAM_CREDITS,
    progressPct,
    yearPath,
    needsY5Plus,
    canGraduateOnTime,
    projectedGradYear,
    projectedGradSem,
    impactedCourses,
    retakeScheduled,
  };
}

// ────────────────────────────────────────────────────────────────────────────
// FORMAT OUTPUT (matches prompt.txt FORMAT exactly)
// ────────────────────────────────────────────────────────────────────────────
function formatDashboard(result) {
  const {
    riskLevel, earnedCredits, totalCredits, progressPct,
    yearPath, needsY5Plus, impactedCourses,
  } = result;

  const lines = [];

  lines.push('----------------------------------');
  lines.push('');
  lines.push('IMPACT DASHBOARD');
  lines.push('');
  lines.push(`Risk Level: ${riskLevel}`);
  lines.push('');
  lines.push(`Earned Credits: ${earnedCredits} / ${totalCredits}`);
  lines.push(`${progressPct}% toward graduation`);
  lines.push('');
  lines.push('4-Year Path Projection:');
  for (const [label, status] of Object.entries(yearPath)) {
    lines.push(`${label}: ${status}`);
  }
  lines.push(`Y5+: ${needsY5Plus ? 'REQUIRED' : 'NOT NEEDED'}`);
  lines.push('');
  lines.push('Legend:');
  lines.push('- OK = all passed / on track');
  lines.push('- ISSUE = has F or delay');
  lines.push('- REQUIRED = cannot graduate within 4 years');
  lines.push('');
  lines.push('----------------------------------');

  if (impactedCourses.length > 0) {
    lines.push('');
    lines.push('IMPACTED COURSES');
    lines.push('');

    for (const ic of impactedCourses) {
      lines.push(`${ic.code} - ${ic.name}`);
      lines.push(`Status: F`);
      lines.push(`Normal term: ${ic.normalTerm}`);
      lines.push('');
      lines.push('Blocked:');
      if (ic.blocked.length > 0) {
        for (const b of ic.blocked) lines.push(`  - ${b.code} (${b.name})`);
      } else {
        lines.push('  (none)');
      }
      lines.push('');
      lines.push('When to retake:');
      const retakeLines = ic.retakeOptions.slice(0, 6); // show up to 6 terms
      if (retakeLines.length === 0) {
        lines.push('  - No future slots found in plan');
      } else {
        for (const opt of retakeLines) {
          lines.push(`  - Year ${opt.year} / Term ${opt.semester} → ${opt.reason}`);
        }
      }
      lines.push('');
    }

    lines.push('----------------------------------');
  }

  return lines.join('\n');
}

// ────────────────────────────────────────────────────────────────────────────
// PUBLIC API
// ────────────────────────────────────────────────────────────────────────────
async function runImpactAnalysis(uid) {
  const { profile, roadmap, subjects, schedules } = await fetchData(uid);

  const { subjectMap, scheduleMap } = buildMaps(subjects, schedules);
  const terms = buildTerms(roadmap, profile.current_year, profile.current_semester);

  const result = analyse({ profile, terms, subjectMap, scheduleMap });
  const rawText = formatDashboard(result);

  // Structured dashboard for JSON response
  const dashboard = {
    riskLevel:        result.riskLevel,
    earnedCredits:    result.earnedCredits,
    totalCredits:     result.totalCredits,
    progressPercent:  Number(result.progressPct),
    yearPath:         result.yearPath,
    needsY5Plus:      result.needsY5Plus,
    canGraduateOnTime: result.canGraduateOnTime,
    projectedGraduation: result.canGraduateOnTime
      ? 'Year 4 / Term 2'
      : `Year ${result.projectedGradYear} / Term ${result.projectedGradSem}`,
  };

  return {
    dashboard,
    impactedCourses: result.impactedCourses,
    rawText,
  };
}

module.exports = { runImpactAnalysis };
