// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/subject_model.dart';
// import '../services/subject_service.dart';
// import '../services/profile_service.dart';
// import '../services/roadmap_service.dart';
// import '../widgets/term_column.dart';
// import '../widgets/progress_header.dart';
// import 'roadmap_page.dart';
// import 'academic_history_page.dart';

// class SimulatorPage extends StatefulWidget {
//   const SimulatorPage({super.key});

//   @override
//   State<SimulatorPage> createState() => _SimulatorPageState();
// }

// class _SimulatorPageState extends State<SimulatorPage> {
//   final SubjectService _subjectService = SubjectService();
//   final ProfileService _profileService = ProfileService();
//   final RoadmapService _roadmapService = RoadmapService();

//   List<SubjectModel> allSubjects = [];
//   Map<String, dynamic>? userProfile;

//   // 🔥 ข้อมูลจำลองที่จัดการในหน้านี้เท่านั้น (ไม่ลง DB ทันที)
//   List<Map<String, dynamic>> simulatedWorkInProgress = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     setState(() => isLoading = true);
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final subjects = await _subjectService.fetchSubjects();
//       final profile = await _profileService.getProfile(user.uid);
//       // ดึงประวัติจริงมาเป็น "ฐาน" เริ่มต้นในการจำลอง
//       final history = await _roadmapService.getUserRoadmap(user.uid);

//       setState(() {
//         allSubjects = subjects;
//         userProfile = profile;
//         // Copy ข้อมูลมาเก็บไว้ในตัวแปร local
//         simulatedWorkInProgress = List<Map<String, dynamic>>.from(history);
//         isLoading = false;
//       });
//     }
//   }

//   // 🔥 ฟังก์ชันเพิ่มวิชาแบบ Local (ส่งให้ TermColumn)
//   void _onAddSimulated(SubjectModel subject, int year, int term) {
//     setState(() {
//       // TODO: [เพื่อน] - ใส่ Logic เงื่อนไขการ Simulate (เช่น Prerequisite)
//       simulatedWorkInProgress.add({
//         'id':
//             'temp_${DateTime.now().millisecondsSinceEpoch}', // สร้าง ID ปลอมไว้ลบ
//         'subject_code': subject.subjectCode,
//         'year': year,
//         'semester': term,
//         'status': 'simulated',
//         'grade': null,
//       });
//     });
//   }

//   // 🔥 ฟังก์ชันลบวิชาแบบ Local (ส่งให้ TermColumn)
//   void _onDeleteSimulated(dynamic id) {
//     setState(() {
//       simulatedWorkInProgress.removeWhere((item) => item['id'] == id);
//     });
//   }

//   // 🔥 ฟังก์ชัน Save และ Redirect
//   Future<void> handleSaveSimulation() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     // TODO: [เพื่อน] - เขียนคำสั่งลบแผนเก่าใน simulated_plans และ insert simulatedWorkInProgress ชุดนี้ลงไปแทน

//     if (mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Simulation Plan Saved!")));
//       // ย้อนกลับไปหน้า Roadmap โดยบังคับให้เปิดแท็บที่ 1 (My Saved Plan)
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(
//           builder: (_) =>
//               const RoadmapPage(mode: RoadmapMode.view, initialTabIndex: 1),
//         ),
//         (route) => false,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final terms = List.generate(8, (index) {
//       int year = (index ~/ 2) + 1;
//       int term = (index % 2) + 1;
//       return {"title": "Year $year / Term $term", "year": year, "term": term};
//     });

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text("Simulator"),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       floatingActionButton: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _buildActionFab(
//             "Simulate",
//             Icons.play_arrow,
//             Colors.white,
//             Colors.blue,
//             () {
//               // TODO: [เพื่อน] - ใส่ Logic คำนวณภาพรวม (เช่น GPA จำลอง)
//               print("Calculating simulation...");
//             },
//           ),
//           const SizedBox(height: 12),
//           _buildActionFab(
//             "Save Plan",
//             Icons.save,
//             Colors.greenAccent[700]!,
//             Colors.white,
//             handleSaveSimulation,
//           ),
//         ],
//       ),

//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 ProgressHeader(currentCredits: 0),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.all(16),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: terms.map((term) {
//                         final termCourses = simulatedWorkInProgress
//                             .where(
//                               (item) =>
//                                   item['year'] == term['year'] &&
//                                   item['semester'] == term['term'],
//                             )
//                             .toList();

//                         return TermColumn(
//                           title: term["title"] as String,
//                           allSubjects: allSubjects,
//                           mode: RoadmapMode.simulate,
//                           userProfile: userProfile,
//                           initialCourses: termCourses,
//                           allPlanCourses: simulatedWorkInProgress,
//                           onRefresh:
//                               () {}, // ในโหมดจำลองเราใช้ setState จัดการ UI เอง
//                           isSelected:
//                               userProfile?['current_year'] == term['year'] &&
//                               userProfile?['current_semester'] == term['term'],
//                           onSelect: () {},
//                           // 🔥 ส่ง Callback ไปให้ TermColumn
//                           // onAddPressed: _onAddSimulated,
//                           // onDeletePressed: _onDeleteSimulated,
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildActionFab(
//     String text,
//     IconData icon,
//     Color bg,
//     Color fg,
//     VoidCallback onTap,
//   ) {
//     return FloatingActionButton.extended(
//       heroTag: text,
//       onPressed: onTap,
//       backgroundColor: bg,
//       foregroundColor: fg,
//       label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
//       icon: Icon(icon),
//     );
//   }
// }
