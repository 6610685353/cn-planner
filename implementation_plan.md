# Implementation Plan: Fix Backend Crash and "Used after disposed" Error

เป้าหมายคือการแก้ไขบั๊กที่ทำให้เซิร์ฟเวอร์ Backend รันไม่ขึ้น (ดูจาก Terminal Node) ซึ่งส่งผลให้ฝั่งแอปดึงข้อมูลไม่สำเร็จและเกิด Error ตามมา

## ปัญหาที่พบใน Terminal
1. **Node Terminal (`functions/server.js`)**: 
   ฟ้อง Error ขาดใจตายว่า `SyntaxError: Identifier 'gpaRoutes' has already been declared`
   **สาเหตุ:** มีการประกาศตัวแปร `const gpaRoutes` ซ้ำซ้อน 2 ครั้ง ในไฟล์ `server.js` (บรรทัดที่ 12 และ 28)

2. **DartVM Terminal (Frontend)**:
   - ฟ้อง Error ว่า `Failed to fetch` -> **สาเหตุ:** เพราะ Backend พังและหยุดทำงาน ทำให้แอปยิง HTTP ไปไม่เจอเซิร์ฟเวอร์
   - ฟ้อง Error `GPACalculatorController was used after being disposed` ดับเบิ้ลตามมา -> **สาเหตุ:** หลังจาก Backend ไม่ตอบ หรือโหลดนานจน User กดออกจากหน้าจอไปแล้ว ตัวแอปเพิ่งจะได้รับคำตอบ/Error กลับมา และพยายามสั่งให้อัปเดต UI (`notifyListeners();`) แต่หน้า UI ถูกปิด (Disposed) ไปก่อนแล้ว

## Proposed Changes

### 1. Fix Backend Syntax Error
- **ไฟล์:** `functions/server.js`
- **การแก้ไข:** ลบบรรทัดที่ซ้ำซ้อนทิ้ง
  นำโค้ด `const gpaRoutes = require("./src/routes/gpa_routes");` ที่อยู่ด้านล่างสุดบรรทัดที่ 28 ออก ให้เหลือแค่ที่ประกาศไว้ตรงตอนต้นไฟล์เพียงที่เดียว

### 2. Fix Frontend Controller Dispose Error (เพิ่มความเสถียร)
- **ไฟล์:** `lib/features/gpa_calculator/controllers/gpa_calculator_controller.dart`
- **การแก้ไข:** ในคลาส `GPACalculatorController` ควรสร้างตัวแปรเช็กสถานะการใช้งานค้างไว้:
  - เพิ่ม `bool _isDisposed = false;`
  - Override `dispose()` ให้ปรับ `_isDisposed = true;`
  - ปรับปรุงบล็อก `finally` และจุดที่มีการเรียก `notifyListeners()` ว่า: 
    `if (!_isDisposed) notifyListeners();` 
    เพื่อป้องกันไม่ให้แอปแครชเวลาคนกดออกหน้าจอกะทันหันขณะกำลังโหลด

## User Review Required
> [!IMPORTANT]
> - ทันทีที่แก้ไฟล์ `server.js` ฝั่ง Backend ตัว Firebase Emulator น่าจะกลับขึ้นมาทำงานได้เอง (Auto-restart) 
> - การแก้ `notifyListeners` ในข้อ 2 เป็นการอุดรอยรั่วทั่วไปของ Flutter คอร์สนี้เห็นควรทำไว้ครับ
>
> **โอเคกับแผนทั้ง 2 ส่วนนี้ไหมครับ? ถ้ายืนยันแล้วผมจะเริ่มแก้ไฟล์ให้เลยครับ**
