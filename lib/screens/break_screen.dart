// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pomo_app/models/session_model.dart';
import 'package:pomo_app/screens/main_screen.dart';
import 'package:pomo_app/utils/colors.dart';
// import 'package:pomo_app/utils/animations.dart';

class BreakScreen extends StatefulWidget {
  final SessionModel session;

  const BreakScreen({super.key, required this.session});

  @override
  _BreakScreenState createState() => _BreakScreenState();
}

class _BreakScreenState extends State<BreakScreen> with TickerProviderStateMixin {
  Timer? _timer;
  late int _currentBreakSeconds;
  late AnimationController _blobAnimationController;

  @override
  void initState() {
    super.initState();
    _currentBreakSeconds = widget.session.breakDurationMinutes * 60;
    _startBreakTimer();

    _blobAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  void _startBreakTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_currentBreakSeconds > 0) {
        setState(() {
          _currentBreakSeconds--;
        });
      } else {
        _timer?.cancel();
        _blobAnimationController.stop();
        _navigateToInputScreen();
      }
    });
  }

  void _navigateToInputScreen() {
    _timer?.cancel(); // Ensure timer is cancelled
    _blobAnimationController.stop();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MainScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _blobAnimationController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    String greetingName = widget.session.userName.isNotEmpty ? widget.session.userName.split(" ")[0] : "User";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea( // Added SafeArea
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _blobAnimationController,
                builder: (context, child) {
                  final sizeFactor = 0.7 + (_blobAnimationController.value * 0.25);
                  final borderRadiusFactor = 0.3 + (_blobAnimationController.value * 0.4);
                  return Transform.scale(
                    scale: sizeFactor,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.85),
                        // shape: BoxShape.circle,
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(
                            MediaQuery.of(context).size.width * 0.9 * (0.8 + borderRadiusFactor * 0.2),
                            MediaQuery.of(context).size.width * 0.9 * (0.8 - borderRadiusFactor * 0.2)
                          )
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.25 - (_blobAnimationController.value * 20), // Dynamic positioning
                left: MediaQuery.of(context).size.width * 0.2 + (_blobAnimationController.value * 30),
                child: Container(
                  width: MediaQuery.of(context).size.width * (0.20 + _blobAnimationController.value * 0.1),
                  height: MediaQuery.of(context).size.width * (0.15 + _blobAnimationController.value * 0.08),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15 + (_blobAnimationController.value * 0.1)),
                    borderRadius: BorderRadius.all(Radius.elliptical(90, 60 + _blobAnimationController.value * 20)),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(_currentBreakSeconds),
                    style: TextStyle(
                      fontSize: 90,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black,
                          offset: Offset(-2, -2),
                        ),
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black,
                          offset: Offset(2, -2),
                        ),
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black,
                          offset: Offset(-2, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Take a break,',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textColor.withOpacity(0.8)),
                  ),
                  Text(
                    '$greetingName!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.white),
                  ),
                  SizedBox(height: 50),
                  ElevatedButton.icon(
                    icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
                    label: Text('Skip & Setup New', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    onPressed: _navigateToInputScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: AppColors.primary, width: 1.5)
                      ),
                      elevation: 3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}