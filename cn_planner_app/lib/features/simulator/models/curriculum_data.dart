import '../models/course_model.dart';
import '../models/term_model.dart';

class CurriculumData {
  static const String programName = 'Computer Engineering';
  static const int totalProgramCredits = 146;
  static const int minCreditsPerTerm = 9;
  static const int maxCreditsPerTerm = 21;
  static const int maxSupportedYear = 8;

  static CourseModel _course({
    required String code,
    required String name,
    required int credits,
    List<String> prerequisites = const [],
    List<int> availableTerms = const [1, 2],
    CourseStatus status = CourseStatus.upcoming,
    CourseOutcome outcome = CourseOutcome.notSet,
    String? grade,
    String? category,
  }) {
    return CourseModel(
      code: code,
      name: name,
      credits: credits,
      prerequisites: prerequisites,
      availableTerms: availableTerms,
      status: status,
      outcome: outcome,
      grade: grade,
      category: category,
    );
  }

  static List<TermModel> getTerms() {
    return [
      TermModel(
        year: 1,
        term: 1,
        status: TermStatus.passed,
        courses: [
          _course(
            code: 'CN101',
            name: 'Programming',
            credits: 3,
            availableTerms: [1],
            status: CourseStatus.passed,
            outcome: CourseOutcome.pass,
            grade: 'A',
          ),
          _course(
            code: 'CN102',
            name: 'Practice',
            credits: 1,
            availableTerms: [1],
            status: CourseStatus.passed,
            outcome: CourseOutcome.pass,
            grade: 'A',
          ),
          _course(
            code: 'SC133',
            name: 'Physics 1',
            credits: 3,
            status: CourseStatus.passed,
            outcome: CourseOutcome.pass,
            grade: 'B+',
          ),
          _course(
            code: 'SC183',
            name: 'Physics Lab 1',
            credits: 1,
            status: CourseStatus.passed,
            outcome: CourseOutcome.pass,
            grade: 'A',
          ),
          _course(
            code: 'MA111',
            name: 'Calculus 1',
            credits: 3,
            status: CourseStatus.passed,
            outcome: CourseOutcome.pass,
            grade: 'B',
          ),
          _course(
            code: 'LAS101',
            name: 'LAS101',
            credits: 3,
            status: CourseStatus.passed,
            outcome: CourseOutcome.pass,
          ),
          _course(
            code: 'TU100',
            name: 'TU100',
            credits: 1,
            status: CourseStatus.passed,
            outcome: CourseOutcome.pass,
          ),
          _course(
            code: 'TSE100',
            name: 'TSE100',
            credits: 0,
            status: CourseStatus.passed,
            outcome: CourseOutcome.pass,
          ),
        ],
      ),
      TermModel(
        year: 1,
        term: 2,
        status: TermStatus.current,
        courses: [
          _course(
            code: 'CN201',
            name: 'OOP',
            credits: 3,
            prerequisites: ['CN101'],
            availableTerms: [2],
            status: CourseStatus.current,
          ),
          _course(
            code: 'CN103',
            name: 'Practice 2',
            credits: 1,
            availableTerms: [2],
            status: CourseStatus.current,
          ),
          _course(
            code: 'MA112',
            name: 'Calculus 2',
            credits: 3,
            prerequisites: ['MA111'],
            status: CourseStatus.current,
          ),
          _course(
            code: 'SC134',
            name: 'Physics 2',
            credits: 3,
            status: CourseStatus.current,
          ),
          _course(
            code: 'SC184',
            name: 'Physics Lab 2',
            credits: 1,
            status: CourseStatus.current,
          ),
          _course(
            code: 'EL105',
            name: 'EL105',
            credits: 3,
            status: CourseStatus.current,
          ),
          _course(
            code: 'IE121',
            name: 'IE121',
            credits: 3,
            status: CourseStatus.current,
          ),
          _course(
            code: 'ME100',
            name: 'ME100',
            credits: 3,
            status: CourseStatus.current,
          ),
          _course(
            code: 'TSE101',
            name: 'TSE101',
            credits: 1,
            status: CourseStatus.current,
          ),
        ],
      ),
      TermModel(
        year: 2,
        term: 1,
        courses: [
          _course(
            code: 'CN202',
            name: 'Data Structures & Algo 1',
            credits: 3,
            prerequisites: ['CN101', 'CN201'],
            availableTerms: [1],
          ),
          _course(
            code: 'CN200',
            name: 'Discrete Math',
            credits: 3,
            availableTerms: [1],
          ),
          _course(
            code: 'CN204',
            name: 'Probability & Statistics',
            credits: 3,
            prerequisites: ['MA111'],
            availableTerms: [1],
          ),
          _course(
            code: 'CN260',
            name: 'Circuit Theory',
            credits: 3,
            availableTerms: [1],
          ),
          _course(
            code: 'CN261',
            name: 'Circuit Lab',
            credits: 1,
            prerequisites: ['CN260'],
            availableTerms: [1],
          ),
          _course(
            code: 'MA214',
            name: 'Differential Equations',
            credits: 3,
            prerequisites: ['MA111', 'MA112'],
          ),
          _course(code: 'TU108', name: 'TU108', credits: 1),
        ],
      ),
      TermModel(
        year: 2,
        term: 2,
        courses: [
          _course(
            code: 'CN203',
            name: 'Data Structures & Algo 2',
            credits: 3,
            prerequisites: ['CN202', 'CN201', 'CN101'],
            availableTerms: [2],
          ),
          _course(
            code: 'CN230',
            name: 'Database Systems',
            credits: 3,
            availableTerms: [2],
          ),
          _course(
            code: 'CN210',
            name: 'Computer Architecture',
            credits: 3,
            availableTerms: [2],
          ),
          _course(
            code: 'CN240',
            name: 'Data Science',
            credits: 3,
            prerequisites: ['CN204', 'MA111'],
            availableTerms: [2],
          ),
          _course(code: 'CN262', name: 'Digital Systems', credits: 3),
          _course(code: 'TU122', name: 'TU122', credits: 1),
        ],
      ),
      TermModel(
        year: 3,
        term: 1,
        courses: [
          _course(
            code: 'CN331',
            name: 'Software Engineering',
            credits: 3,
            prerequisites: ['CN101'],
            availableTerms: [1],
          ),
          _course(
            code: 'CN361',
            name: 'CN361',
            credits: 3,
            prerequisites: ['CN262'],
            availableTerms: [1],
            category: 'Major Elective',
          ),
          _course(
            code: 'CN321',
            name: 'Data Communications',
            credits: 3,
            availableTerms: [1],
          ),
          _course(
            code: 'CN330',
            name: 'App Development',
            credits: 3,
            prerequisites: ['CN101'],
            availableTerms: [1],
            category: 'Major Elective',
          ),
          _course(
            code: 'CN310',
            name: 'Server Technology',
            credits: 3,
            availableTerms: [1],
            category: 'Major Elective',
          ),
          _course(
            code: 'CN320',
            name: 'Network',
            credits: 3,
            availableTerms: [1],
            category: 'Major Elective',
          ),
          _course(
            code: 'CN340',
            name: 'Machine Learning',
            credits: 3,
            prerequisites: ['CN240'],
            availableTerms: [1],
            category: 'Major Elective',
          ),
        ],
      ),
      TermModel(
        year: 3,
        term: 2,
        courses: [
          _course(
            code: 'CN311',
            name: 'Operating Systems',
            credits: 3,
            availableTerms: [2],
          ),
          _course(
            code: 'CN332',
            name: 'OOAD',
            credits: 3,
            prerequisites: ['CN201'],
            availableTerms: [2],
          ),
          _course(
            code: 'CN333',
            name: 'Mobile App Dev',
            credits: 3,
            availableTerms: [2],
          ),
          _course(
            code: 'CN322',
            name: 'Network Security',
            credits: 3,
            prerequisites: ['CN320'],
            availableTerms: [2],
            category: 'Major Elective',
          ),
          _course(
            code: 'CN341',
            name: 'Deep Learning',
            credits: 3,
            prerequisites: ['CN340'],
            availableTerms: [2],
            category: 'Major Elective',
          ),
          _course(
            code: 'CN335',
            name: 'Animation',
            credits: 3,
            availableTerms: [2],
            category: 'Major Elective',
          ),
          _course(
            code: 'CN351',
            name: 'Web Security',
            credits: 3,
            availableTerms: [2],
            category: 'Major Elective',
          ),
          _course(
            code: 'CN334',
            name: 'Web Development',
            credits: 3,
            prerequisites: ['CN101'],
            availableTerms: [2],
            category: 'Major Elective',
          ),
        ],
      ),
      TermModel(year: 4, term: 1, courses: []),
      TermModel(year: 4, term: 2, courses: []),
    ];
  }

  static List<TermModel> getEmptyYearTerms(int year) {
    return [
      TermModel(year: year, term: 1, courses: []),
      TermModel(year: year, term: 2, courses: []),
    ];
  }

  static List<CourseModel> getAllCourses() {
    final seen = <String>{};
    final result = <CourseModel>[];

    void addIfNeeded(CourseModel course) {
      if (seen.add(course.code)) {
        result.add(course);
      }
    }

    for (final term in getTerms()) {
      for (final course in term.courses) {
        addIfNeeded(course);
      }
    }

    for (final course in [
      _course(
        code: 'CN401',
        name: 'Senior Project 1',
        credits: 1,
        availableTerms: [1],
      ),
      _course(
        code: 'CN402',
        name: 'Senior Project 2',
        credits: 1,
        prerequisites: ['CN401'],
        availableTerms: [2],
      ),
      _course(
        code: 'CN403',
        name: 'Co-op Preparation',
        credits: 1,
        availableTerms: [1],
      ),
      _course(
        code: 'CN404',
        name: 'Co-operative Education',
        credits: 6,
        prerequisites: ['CN403'],
        availableTerms: [2],
      ),
      _course(
        code: 'CN472',
        name: 'Research 1',
        credits: 1,
        availableTerms: [1],
      ),
      _course(
        code: 'CN473',
        name: 'Research 2',
        credits: 6,
        prerequisites: ['CN472'],
        availableTerms: [2],
      ),
    ]) {
      addIfNeeded(course);
    }

    return result;
  }
}
