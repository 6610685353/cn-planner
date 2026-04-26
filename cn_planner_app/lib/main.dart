import 'package:cn_planner_app/route.dart';
import 'package:cn_planner_app/services/api_config.dart';
import 'package:cn_planner_app/services/emulator_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'package:cn_planner_app/core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();
  await NotificationService.requestPermission();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://razswzgdnxwjqbyebgnj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJhenN3emdkbnh3anFieWViZ25qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzExMjAxOTAsImV4cCI6MjA4NjY5NjE5MH0.jxPnFZB8tY0Wqsm4wn8GBC_Kj6F5acZD6IqtY-6F83c',
  );

  if (kDebugMode) {
    try {
      await dotenv.load(fileName: ".env.local");
      await Config.init();
    } catch (e) {
      print("Config Error: $e");
    }
  }

  final currentUser = FirebaseAuth.instance.currentUser;

  final String initialRoute = currentUser == null
      ? AppRoutes.login
      : AppRoutes.main;

  runApp(MyApp(startRoute: initialRoute));
}

const Color bg = Color(0xFFF8F9FA);

class MyApp extends StatelessWidget {
  final String startRoute;

  const MyApp({super.key, required this.startRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        fontFamily: 'OpenSans',
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          titleTextStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      initialRoute: startRoute,
      routes: AppRoutes.routes,
    );
  }
}
