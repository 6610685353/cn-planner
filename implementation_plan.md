# Implementation Plan: Fix Predicted GPAX Calculation

## ปัญหาที่พบ (จากรูปภาพ)
- ค่า **PREDICTED GPAX** ออกมาเท่ากับ **PREDICTED GPA** (3.50) แทนที่จะนำเอาค่า Current GPA เดิม (2.00) มาร่วมคำนวณถ่วงน้ำหนักด้วย 
- สาเหตุเกิดจากการคำนวณ `_pastTotalPoints` และ `_pastTotalCredits` ในปัจจุบันใช้วิธีวนลูปประวัติจาก `history` (Roadmap) ซึ่งหากในระบบ Roadmap ของคนนั้นยังไม่ได้เพิ่มวิชาเทอมเก่าๆ เข้าไป ค่าอดีตจะเป็น `0` ทำให้ Predicted GPAX เท่ากับเกรดเทอมปัจจุบันเสมอ

## แนวทางการแก้ไข (Proposed Changes)

**ไฟล์ที่เกี่ยวข้อง:** `features/gpa_calculator/controllers/gpa_calculator_controller.dart`

1. **เปลี่ยนวิธีการดึงค่าอดีต (Past Baseline)**
   - แทนที่จะวนลูป `history` สำหรับเทอมเก่า ให้กลับไปใช้ Source of Truth จากตาราง `profiles` โดยตรง เพราะมีการเก็บค่า `gpax` และ `earned_credits` (หน่วยกิตสะสมที่สอบผ่านแล้ว) เอาไว้อยู่แล้ว
   - ค่าคะแนนสะสมที่ผ่านมาจะคำนวณได้จากสูตร: `_pastTotalPoints = currentGPA * _pastTotalCredits`

2. **อัปเดตโค้ดใน Method `fetchInitialData()`**
   - ดึง `earned_credits` จากผลลัพธ์ของ `profile`
   - กำหนดให้:
     ```dart
     _pastTotalCredits = (profile['earned_credits'] ?? 0.0).toDouble();
     _pastTotalPoints = currentGPA * _pastTotalCredits;
     ```
   - *หมายเหตุ: สามารถลบโค้ดส่วนที่เขียนว่า `// 2. คำนวณ GPAX สะสมในอดีต (ไม่รวมเทอมปัจจุบัน) จาก Roadmap จริงๆ` (การวนลูปหาเกรดเก่า) ออกไปได้เลย เพราะเราได้ผลรวมมาจาก `profiles` ครบถ้วนแล้ว*

## User Review Required
> [!IMPORTANT]
> วิธีนี้จะอ้างอิง `earned_credits` จากตาราง `profiles` เป็นตัวถ่วงน้ำหนักของ Current GPA ยิ่งหน่วยกิตเก่ามีมาก เกรดเทอมนี้จะมีผลต่อเกรดรวม (GPAX) น้อยลง ซึ่งเป็นไปตามหลักการคำนวณเกรดจริง
> 
> **คำถาม:** 
> หากค่า `earned_credits` ในโปรไฟล์ของคุณตอนนี้ยังเป็น `0` (เนื่องจากยังไม่ค่อยได้ไปกด Save ข้อมูลการเรียนเก่า) การแสดงผลก็ยังจะออกมาเท่ากับ PREDICTED GPA อยู่นะครับ ถือว่าถูกต้องตามหลักการ (เพราะยังไม่มีหน่วยกิตอดีตมาถ่วง) ตรงนี้โอเคไหมครับ หรือต้องการให้ Mock ค่าสะสมสมมติไปก่อน?

หากแผนนี้โอเคตามนี้แล้ว คุณสามารถยืนยันได้เลยเพื่อให้ทำการเริ่มแก้โค้ดให้ครับ
