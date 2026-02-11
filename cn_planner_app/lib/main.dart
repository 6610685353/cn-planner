import 'package:cn_planner_app/route.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
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
