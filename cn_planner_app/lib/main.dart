import 'package:cn_planner_app/route.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://razswzgdnxwjqbyebgnj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJhenN3emdkbnh3anFieWViZ25qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzExMjAxOTAsImV4cCI6MjA4NjY5NjE5MH0.jxPnFZB8tY0Wqsm4wn8GBC_Kj6F5acZD6IqtY-6F83c'
  );
  runApp(const MyApp());
}

const Color bg = Color(0xFFF8F9FA);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application
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
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
