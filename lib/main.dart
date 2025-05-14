// lib/main.dart
import 'package:flutter/material.dart';
import 'package:pomo_app/screens/main_screen.dart'; // Changed
import 'package:pomo_app/utils/colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      theme: ThemeData(
        primarySwatch: AppColors.primary, // Use the MaterialColor version
        scaffoldBackgroundColor: AppColors.background,
        textTheme: TextTheme(
          headlineLarge: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: AppColors.textColor),
        ),
        // Define global AppBarTheme if needed
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textColor), // For back buttons etc.
          titleTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      home: MainScreen(), // Changed from InputScreen
      debugShowCheckedModeBanner: false,
    );
  }
}