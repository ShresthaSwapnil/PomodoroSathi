// lib/screens/main_screen.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:pomo_app/screens/history_screen.dart';
import 'package:pomo_app/screens/input_screen.dart';
import 'package:pomo_app/utils/colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Pages for the tabs
  static final List<Widget> _widgetOptions = <Widget>[
    InputScreen(), // Your existing input screen
    HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer),
            label: 'Pomodoro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary, // Use your app's primary color
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white, // Or AppColors.background if it's light
        type: BottomNavigationBarType.fixed, // Good for 2-3 items
        elevation: 8.0, // Add some elevation
        onTap: _onItemTapped,
      ),
    );
  }
}