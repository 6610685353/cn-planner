import UIKit
import Flutter
// 🌟 1. Import ตัวนี้เพิ่มสำหรับระบบ Local Notification
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
    // 🌟 2. สั่งตั้งค่าให้ Plugin Local Notification ทำงานร่วมกับระบบของ Apple
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }

    GeneratedPluginRegistrant.register(with: self)
      
    // 🌟 3. บังคับให้แจ้งเตือนเด้งโชว์เป็น Popup แม้ผู้ใช้กำลังเปิดแอปนี้อยู่ก็ตาม
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}