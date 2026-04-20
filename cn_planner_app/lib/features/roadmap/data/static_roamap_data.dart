import 'package:cn_planner_app/features/roadmap/models/subject_model.dart';

class RoadmapTemplate {
  static const String PLAN_INTERNSHIP = 'Internship'; // ฝึกงาน
  static const String PLAN_COOP = 'Coop'; //สหกิจ
  static const String PLAN_RESEARCH = 'Research'; // วิจัย

  static List<Map<String, dynamic>> getTemplate() {
    return [
      // --------------------------------------------------------------------------
      // YEAR 1 SEMESTER 1
      //---------------------------------------------------------------------------
      {
        'subject_code': 'LAS101',
        'year': 1,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN101',
        'year': 1,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'TU100',

        'year': 1,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'MA111',
        'year': 1,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'SC133',
        'year': 1,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'SC183',
        'year': 1,
        'semester': 1,
        'credit': 1,
        'plan': 'all',
      },
      {
        'subject_code': 'TSE100',
        'year': 1,
        'semester': 1,
        'credit': 0,
        'plan': 'all',
      },
      {
        'subject_code': 'CN102',
        'year': 1,
        'semester': 1,
        'credit': 1,
        'plan': 'all',
      },

      // --------------------------------------------------------------------------
      // YEAR 1 SEMESTER 2
      //---------------------------------------------------------------------------
      {
        'subject_code': 'EL105',
        'year': 1,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'MA112',
        'year': 1,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'SC134',
        'year': 1,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'SC184',
        'year': 1,
        'semester': 2,
        'credit': 1,
        'plan': 'all',
      },
      {
        'subject_code': 'ME100',
        'year': 1,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'TSE101',
        'year': 1,
        'semester': 2,
        'credit': 1,
        'plan': 'all',
      },
      {
        'subject_code': 'IE121',
        'year': 1,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN103',
        'year': 1,
        'semester': 2,
        'credit': 1,
        'plan': 'all',
      },
      {
        'subject_code': 'CN201',
        'year': 1,
        'semester': 2,
        'credit': 4,
        'plan': 'all',
      },

      // --------------------------------------------------------------------------
      // YEAR 2 SEMESTER 1
      //---------------------------------------------------------------------------
      {
        'subject_code': 'TU108',
        'year': 2,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'MA214',
        'year': 2,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN200',
        'year': 2,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN202',
        'year': 2,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN204',
        'year': 2,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN260',
        'year': 2,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN261',
        'year': 2,
        'semester': 1,
        'credit': 1,
        'plan': 'all',
      },

      // --------------------------------------------------------------------------
      // YEAR 2 SEMESTER 2
      //---------------------------------------------------------------------------
      {
        'subject_code': 'TU122',
        'year': 2,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN203',
        'year': 2,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN210',
        'year': 2,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN230',
        'year': 2,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN240',
        'year': 2,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN262',
        'year': 2,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'XXXXX',
        'subject_name': 'General Education',
        'year': 2,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },

      // --------------------------------------------------------------------------
      // YEAR 3 SEMESTER 1
      //---------------------------------------------------------------------------
      {
        'subject_code': 'CN321',
        'year': 3,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN331',
        'year': 3,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN361',
        'year': 3,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN3XX',
        'subject_name': 'Major Electives',
        'year': 3,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN3XX',
        'subject_name': 'Major Electives',
        'year': 3,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN3XX',
        'subject_name': 'Major Electives',
        'year': 3,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'XXXXX',
        'subject_name': 'General Education',
        'year': 3,
        'semester': 1,
        'credit': 3,
        'plan': 'all',
      },

      // --------------------------------------------------------------------------
      // YEAR 3 SEMESTER 2
      //---------------------------------------------------------------------------
      {
        'subject_code': 'CN311',
        'year': 3,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN332',
        'year': 3,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN333',
        'year': 3,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN3XX',
        'subject_name': 'Major Electives',
        'year': 3,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN3XX',
        'subject_name': 'Major Electives',
        'year': 3,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'CN3XX',
        'subject_name': 'Major Electives',
        'year': 3,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },
      {
        'subject_code': 'XXXXX',
        'subject_name': 'General Education',
        'year': 3,
        'semester': 2,
        'credit': 3,
        'plan': 'all',
      },

      // --------------------------------------------------------------------------
      // YEAR 3 SEMESTER 3
      //---------------------------------------------------------------------------
      {
        'subject_code': 'CN380',
        'year': 3,
        'semester': 3,
        'credit': 3,
        'plan': PLAN_INTERNSHIP,
      },
      {
        'subject_code': 'CN471',
        'year': 3,
        'semester': 3,
        'credit': 3,
        'plan': PLAN_RESEARCH,
      },
      {
        'subject_code': 'XXXXX',
        'subject_name': 'Free Electives',
        'year': 3,
        'semester': 3,
        'credit': 3,
        'plan': PLAN_RESEARCH,
      },

      // --------------------------------------------------------------------------
      // YEAR 4 SEMESTER 1
      //---------------------------------------------------------------------------

      // !!INTERNSHIP PLAN!!
      {
        'subject_code': 'CN401',
        'year': 4,
        'semester': 1,
        'credit': 1,
        'plan': PLAN_INTERNSHIP,
      },
      {
        'subject_code': 'CN4XX',
        'subject_name': 'Major Electives',
        'year': 4,
        'semester': 1,
        'credit': 3,
        'plan': PLAN_INTERNSHIP,
      },
      {
        'subject_code': 'CN4XX',
        'subject_name': 'Major Electives',
        'year': 4,
        'semester': 1,
        'credit': 3,
        'plan': PLAN_INTERNSHIP,
      },
      {
        'subject_code': 'XXXXX',
        'subject_name': 'General Education',
        'year': 4,
        'semester': 1,
        'credit': 3,
        'plan': PLAN_INTERNSHIP,
      },
      {
        'subject_code': 'XXXXX',
        'subject_name': 'Free Electives',
        'year': 4,
        'semester': 1,
        'credit': 3,
        'plan': PLAN_INTERNSHIP,
      },

      // !!COOP PLAN!!
      {
        'subject_code': 'CN403',
        'year': 4,
        'semester': 1,
        'credit': 1,
        'plan': PLAN_COOP,
      },
      {
        'subject_code': 'CN4XX',
        'subject_name': 'Major Electives',
        'year': 4,
        'semester': 1,
        'credit': 3,
        'plan': PLAN_COOP,
      },
      {
        'subject_code': 'CN4XX',
        'subject_name': 'Major Electives',
        'year': 4,
        'semester': 1,
        'credit': 3,
        'plan': PLAN_COOP,
      },
      {
        'subject_code': 'XXXXX',
        'subject_name': 'General Education',
        'year': 4,
        'semester': 1,
        'credit': 3,
        'plan': PLAN_COOP,
      },
      {
        'subject_code': 'XXXXX',
        'subject_name': 'Free Electives',
        'year': 4,
        'semester': 1,
        'credit': 3,
        'plan': PLAN_COOP,
      },
      {
        'subject_code': 'XXXXX',
        'subject_name': 'Free Electives',
        'year': 4,
        'semester': 1,
        'credit': 3,
        'plan': PLAN_COOP,
      },

      // !!RESEARCH PLAN!!
      {
        'subject_code': 'CN472',
        'year': 4,
        'semester': 1,
        'credit': 7,
        'plan': PLAN_RESEARCH,
      },
      {
        'subject_code': 'CN4XX',
        'subject_name': 'Major Electives',
        'year': 4,
        'semester': 1,
        'credit': 3,
        'plan': PLAN_RESEARCH,
      }, 
      {
        'subject_code': 'CN4XX',
        'subject_name': 'Major Electives',
        'year': 4,
        'semester': 1,
        'credit': 3,
        'plan': PLAN_RESEARCH,
      },
      {
        'subject_code': 'XXXXX',
        'subject_name': 'General Education',
        'year': 4,
        'semester': 1,
        'credit': 3,
        'plan': PLAN_RESEARCH,
      },
      {
        'subject_code': 'XXXXX',
        'subject_name': 'Free Electives',
        'year': 4,
        'semester': 1,
        'credit': 3,
        'plan': PLAN_RESEARCH,
      },

      // --------------------------------------------------------------------------
      // YEAR 4 SEMESTER 2
      //---------------------------------------------------------------------------
      // !!INTENSHIP PLAN!!
      {
        'subject_code': 'CN402',
        'year': 4,
        'semester': 2,
        'credit': 2,
        'plan': PLAN_INTERNSHIP,
      }, // โครงงาน 2
      {
        'subject_code': 'CN4XX',
        'subject_name': 'Major Electives',
        'year': 4,
        'semester': 2,
        'credit': 3,
        'plan': PLAN_INTERNSHIP,
      },
      {
        'subject_code': 'CN4XX',
        'subject_name': 'Major Electives',
        'year': 4,
        'semester': 2,
        'credit': 3,
        'plan': PLAN_INTERNSHIP,
      },
      {
        'subject_code': 'XXXXX',
        'subject_name': 'Free Electives',
        'year': 4,
        'semester': 2,
        'credit': 3,
        'plan': PLAN_INTERNSHIP,
      },

      // !!COOP PLAN!!
      {
        'subject_code': 'CN404',
        'year': 4,
        'semester': 2,
        'credit': 6,
        'plan': PLAN_COOP,
      },

      // !!RESEARCH PLAN!!
      {
        'subject_code': 'CN473',
        'year': 4,
        'semester': 2,
        'credit': 6,
        'plan': PLAN_RESEARCH,
      },
    ];
  }

  static List<Map<String, dynamic>> getPlanForUser({
    required String selectedPlan,
    required List<SubjectModel> allSubjects,
  }) {
    // 1. ดึง Template ดิบทั้งหมดมา
    final rawTemplate = getTemplate();

    // 2. กรองข้อมูลตาม Plan ที่ User เลือก
    final filteredPlan = rawTemplate.where((item) {
      return item['plan'] == 'all' || item['plan'] == selectedPlan;
    }).toList();

    // 3. จัดการเรื่องชื่อวิชา (Display Name)
    return filteredPlan.map((item) {
      String code = item['subject_code'];
      String displayName = "";

      // Logic: ถ้า subject code มีตัว X (เช่น CN3XX, XXXXX)
      if (code.contains('X')) {
        // ใช้ชื่อที่ระบุมาใน Template (ถ้าไม่มีให้ระบุว่า Elective)
        displayName = item['subject_name'] ?? "Elective Course";
      } else {
        // ถ้าไม่มี X ให้ไปหาข้อมูลชื่อจากรายการ allSubjects (จากตาราง subjects ใน DB)
        try {
          final matchedSubject = allSubjects.firstWhere(
            (s) => s.subjectCode == code,
          );
          displayName = matchedSubject.subjectName;
        } catch (e) {
          // กรณีหาไม่เจอจริงๆ ให้ใช้ชื่อใน Template (ถ้ามี) หรือใช้ Code แทน
          displayName = item['subject_name'] ?? code;
        }
      }

      // คืนค่า Map ใหม่ที่มีฟิลด์ display_name เพิ่มเข้าไป
      return {...item, 'display_name': displayName};
    }).toList();
  }
}
