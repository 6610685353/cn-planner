import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  // ชี้ไปที่ Collection ชื่อ 'schedules' ใน Firebase
  final CollectionReference _scheduleCollection = FirebaseFirestore.instance
      .collection('schedules');

  // 1. CREATE: เพิ่มวิชาเรียนใหม่
  Future<void> addSchedule(ScheduleModel schedule) async {
    try {
      await _scheduleCollection.add(schedule.toMap());
      print("✅ เพิ่มวิชา ${schedule.subjectCode} สำเร็จ!");
    } catch (e) {
      print("❌ เกิดข้อผิดพลาดในการเพิ่มวิชา: $e");
    }
  }

  // 2. READ: ดึงข้อมูลวิชาเรียนตามวัน (ใส่เลข 1-7)
  Stream<List<ScheduleModel>> getSchedulesByDay(int dayOfWeek) {
    return _scheduleCollection
        .where('dayOfWeek', isEqualTo: dayOfWeek)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ScheduleModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // 3. UPDATE: แก้ไขข้อมูลวิชา
  Future<void> updateSchedule(ScheduleModel schedule) async {
    try {
      await _scheduleCollection.doc(schedule.id).update(schedule.toMap());
      print("✅ อัปเดตวิชาสำเร็จ!");
    } catch (e) {
      print("❌ เกิดข้อผิดพลาดในการอัปเดต: $e");
    }
  }

  // 4. DELETE: ลบวิชาทิ้ง
  Future<void> deleteSchedule(String id) async {
    try {
      await _scheduleCollection.doc(id).delete();
      print("✅ ลบวิชาสำเร็จ!");
    } catch (e) {
      print("❌ เกิดข้อผิดพลาดในการลบ: $e");
    }
  }
}
