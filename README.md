<div align="center">
  <img src="cn_planner_app/assets/images/cn_planner_logo.png" alt="CN Planner Logo" width="150"/>

  # CN Planner

  **แอปพลิเคชันวางแผนการเรียนสำหรับนักศึกษาวิศวกรรมคอมพิวเตอร์ มหาวิทยาลัยธรรมศาสตร์**

  ![Flutter](https://img.shields.io/badge/Flutter-3.10.x-02569B?logo=flutter)
  ![Dart](https://img.shields.io/badge/Dart-3.10.8-0175C2?logo=dart)
  ![Firebase](https://img.shields.io/badge/Firebase-Auth-FFCA28?logo=firebase)
  ![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?logo=supabase)
  ![Node.js](https://img.shields.io/badge/Node.js-18.x-339933?logo=nodedotjs)

  [📥 ดาวน์โหลด APK](https://drive.google.com/drive/folders/1K38erkCC-FKqNm2170qwGXXnbzYfsPtm)

</div>

---

## เกี่ยวกับโปรเจ็กต์

CN Planner เป็นแอปพลิเคชันบนมือถือ (iOS & Android) พัฒนาด้วย Flutter สำหรับช่วยให้นักศึกษาสาขาวิศวกรรมคอมพิวเตอร์ มหาวิทยาลัยธรรมศาสตร์ สามารถ **วางแผนการเรียนตลอดหลักสูตร 4 ปี** ได้อย่างมีประสิทธิภาพ โดยระบบจะช่วยตรวจสอบเงื่อนไขวิชาบังคับก่อน (Prerequisite) คำนวณเกรดเฉลี่ย และวิเคราะห์ความเสี่ยงจากการไม่ผ่านรายวิชา

> จัดทำเป็นส่วนหนึ่งของวิชา **CN333 Mobile Application Developments**  
> ภาคเรียนที่ 2 ปีการศึกษา 2568 • คณะวิศวกรรมศาสตร์ มหาวิทยาลัยธรรมศาสตร์

---

## ฟีเจอร์หลัก

| ฟีเจอร์ | รายละเอียด |
|---|---|
| 🔐 **Authentication** | Login / Register / Forgot Password พร้อมระบบ Remember Me |
| 🏠 **Home Dashboard** | สรุป GPAX ความก้าวหน้าหน่วยกิต และตารางเรียนวันนี้ |
| 📅 **Schedule** | ตารางเรียนแบบรายสัปดาห์ (Timetable Grid) และรายวัน (Daily List) |
| 🗺️ **Roadmap** | แผนการเรียน 4 ปี แยกตาม Track (Project / Co-op / Research) พร้อมแสดงสถานะ Prerequisite |
| 📚 **Edit Academic History** | บันทึกและแก้ไขประวัติผลการเรียนแบบ Real-time |
| 🧮 **GPA Calculator** | จำลองเกรดล่วงหน้าและคำนวณ GPAX ที่คาดว่าจะได้รับ |
| ⚠️ **F/W Simulator** | จำลองผลกระทบหากติด F หรือถอนวิชา พร้อมวิเคราะห์ผลเชิงลูกโซ่ (Multi-Course Impact) |
| 📊 **Credit Breakdown** | แสดงความก้าวหน้าหน่วยกิตแยกตามหมวดหมู่ (วิชาเอก / GE / เสรี) |
| 🔔 **Notifications** | แจ้งเตือนล่วงหน้าก่อนถึงเวลาเรียน |
| 👤 **User Profile** | แก้ไขข้อมูลส่วนตัวและรูปโปรไฟล์ |

---

## เทคโนโลยีที่ใช้

```
Frontend    Flutter (Dart)         Cross-platform iOS & Android
Backend     Node.js + Express.js   API Layer และ Business Logic
Auth        Firebase Authentication ระบบยืนยันตัวตน
Database    Supabase (PostgreSQL)   จัดการข้อมูลและ Prerequisite
Storage     Firebase Storage        จัดเก็บรูปโปรไฟล์
Design      Figma                   ออกแบบ UI/UX
```

**สถาปัตยกรรม:** MVC + Feature-based Folder Structure

---

## โครงสร้างโปรเจ็กต์

```
cn-planner/
├── cn_planner_app/              # Flutter Frontend
│   └── lib/
│       ├── core/
│       │   ├── constants/       # สี, assets, ค่าคงที่
│       │   └── widgets/         # Widgets ที่ใช้ร่วมกัน
│       ├── features/            # แบ่งตาม Feature (MVC)
│       │   ├── auth/
│       │   ├── home/
│       │   ├── schedule/
│       │   ├── gpa_calculator/
│       │   ├── roadmap/
│       │   ├── simulator/
│       │   ├── impact_analysis/
│       │   └── profile/
│       ├── services/            # Firebase & Supabase API
│       └── main.dart
└── functions/                   # Node.js Backend
    └── src/
        ├── config/              # การตั้งค่าการเชื่อมต่อ Supabase
        ├── routes/              # API Endpoints
        ├── controllers/         # Business Logic
        └── simulator/           # Logic ระบบจำลองแผนการเรียน
```

---

## วิธีติดตั้งและรันโปรเจ็กต์

### สิ่งที่ต้องติดตั้งก่อน

- [Flutter SDK](https://docs.flutter.dev/get-started/install) เวอร์ชัน 3.x ขึ้นไป
- [Node.js](https://nodejs.org/) เวอร์ชัน 18.0 ขึ้นไป
- [Firebase CLI](https://firebase.google.com/docs/cli)
- IDE: VS Code หรือ Android Studio พร้อม Flutter Extension

---

### 1. Clone Repository

```bash
git clone https://github.com/6610685353/cn-planner.git
cd cn-planner
```

### 2. ตั้งค่า Environment

ไฟล์ config ที่มี API Keys **ไม่ถูก upload ขึ้น repository** ต้องสร้างเองดังนี้

**Firebase — Android:** วางไฟล์ `google-services.json` ที่:
```
cn_planner_app/android/app/
```

**Firebase — iOS:** วางไฟล์ `GoogleService-Info.plist` ที่:
```
cn_planner_app/ios/Runner/
```

> ดาวน์โหลดไฟล์ทั้งสองได้จาก [Firebase Console](https://console.firebase.google.com/)

**Frontend** — สร้างไฟล์ `.env.local` ในโฟลเดอร์ `cn_planner_app/`:

```env
EMU_HOST=192.168.x.x
```
> กำหนดเป็น IP Address ของเครื่องที่รัน Backend (สำหรับทดสอบผ่าน Emulator)

**Backend** — สร้างไฟล์ `.env.local` ในโฟลเดอร์ `functions/`:

```env
SUPABASE_URL=https://razswzgdnxwjqbyebgnj.supabase.co/
SUPABASE_ANON_KEY=<your_supabase_anon_key>
```

### 3. ติดตั้ง Dependencies และรันแอป

**Frontend (Flutter)**
```bash
cd cn_planner_app
flutter pub get
flutter run
```

**Backend (Node.js + Firebase Functions)**
```bash
cd functions
npm install
firebase login
firebase deploy --only functions
```

### 4. Build สำหรับใช้งานจริง

**Android (.apk)**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**iOS (.ipa)**
```bash
flutter build ios --release
# จากนั้นเปิดใน Xcode เพื่อทำ Archive และ Code Signing
```

---

## ดาวน์โหลด APK

สำหรับผู้ที่ต้องการทดลองใช้งานโดยไม่ต้อง build เอง

**[📥 ดาวน์โหลด CN Planner APK (Google Drive)](https://drive.google.com/drive/folders/1K38erkCC-FKqNm2170qwGXXnbzYfsPtm)**

> รองรับเฉพาะ **Android** เท่านั้น  
> ก่อนติดตั้งต้องเปิด "ติดตั้งแอปจากแหล่งที่ไม่รู้จัก" ในการตั้งค่าอุปกรณ์ก่อน

---

## ข้อจำกัดของระบบ

- รองรับเฉพาะหลักสูตรวิศวกรรมคอมพิวเตอร์ มหาวิทยาลัยธรรมศาสตร์เท่านั้น
- ข้อมูลรายวิชาและเกรดขึ้นอยู่กับการกรอกของผู้ใช้ (ไม่ได้เชื่อมต่อระบบทะเบียนจริงของมหาวิทยาลัย)
- ยังไม่รองรับรายวิชาภาคฤดูร้อน (Summer) ในส่วน Edit Academic History
- ยังไม่รองรับการแสดงผลหลายภาษา (Multi-language)

---

## ทีมผู้พัฒนา

| ชื่อ | รหัสนักศึกษา |
|---|---|
| นางสาวธนวรรณ ผ่องแผ้ว | 6610685171 |
| นางสาวเนตรชนก ยินดี | 6610685221 |
| นายปัณณวัฒน์ น้ำคำ | 6610685247 |
| นายสิรณัฏฐ์ พิมพิจารณ์ | 6610685353 |
| นางสาวอันติมาดา แสงรุ่งเรือง | 6610685387 |

**อาจารย์ที่ปรึกษา:** ผศ.ดร.ปิยะ เตชะธีราวัฒน์

---

<div align="center">
  <sub>CN Planner • CN333 Mobile Application Developments • มหาวิทยาลัยธรรมศาสตร์ 2568</sub>
</div>
