import 'package:flutter/material.dart';
import 'package:pomo_app/screens/main_screen.dart';
import 'package:pomo_app/screens/welcome_screen.dart'; 
import 'package:pomo_app/services/user_prefs_service.dart';
import 'package:pomo_app/utils/colors.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  final prefsService = UserPrefsService();
  final bool welcomeSeen = await prefsService.hasSeenWelcomeScreen();

  runApp(MyApp(welcomeSeen: welcomeSeen));
}

class MyApp extends StatelessWidget {
  final bool welcomeSeen;

  const MyApp({super.key, required this.welcomeSeen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      theme: ThemeData(
        primarySwatch: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: TextTheme(
          headlineLarge: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: AppColors.textColor),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textColor),
          titleTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      home: welcomeSeen ? MainScreen() : WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}