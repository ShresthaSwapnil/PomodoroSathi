// lib/screens/timer_screen.dart
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pomo_app/models/session_model.dart';
import 'package:pomo_app/screens/break_screen.dart';
import 'package:pomo_app/screens/main_screen.dart'; 
import 'package:pomo_app/utils/colors.dart';
import 'package:pomo_app/utils/animations.dart';
import 'package:pomo_app/widgets/linear_seconds_painter.dart';
import 'package:animations/animations.dart';


class TimerScreen extends StatefulWidget {
  final SessionModel session;

  const TimerScreen({super.key, required this.session});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  Timer? _timer;
  late int _currentSeconds;
  late int _totalWorkSeconds; // To calculate progress for new painter
  // Remove _animationController if it was only for the arc painter
  // late AnimationController _animationController;
  bool _isPaused = false;

  String _currentAffirmation = "You can do it! 😊"; // Initial affirmation

  final List<String> _affirmationsList = [
    "Keep going! 💪",
    "Almost there!",
    "Stay focused.",
    "You've got this!",
    "Deep breath and carry on.",
    "One step at a time.",
    "Progress, not perfection.",
    "Make it happen.",
    "Stay strong and steady.",
    "Believe in your effort.",
    "Embrace the focus.",
    "Great work!",
    "Small steps, big results."
  ];

  @override
  void initState() {
    super.initState();
    _totalWorkSeconds = widget.session.workDurationMinutes ;
    _currentSeconds = _totalWorkSeconds;

    _startWorkTimer();
    _setRandomAffirmation(); 
  }

  void _setRandomAffirmation() {
    if (!mounted) return;
    final random = Random();
    setState(() {
      _currentAffirmation = _affirmationsList[random.nextInt(_affirmationsList.length)];
    });
  }

  void _startWorkTimer() {
    _isPaused = false;
    // _animationController.forward(from: 1.0 - (_currentSeconds / _totalWorkSeconds.clamp(1, double.infinity)));

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_currentSeconds > 0) {
        if (mounted) {
          setState(() {
            _currentSeconds--;
            // Change affirmation every 15 seconds for example
            if (_currentSeconds % 15 == 0 && _currentSeconds < _totalWorkSeconds - 5) { 
              _setRandomAffirmation();
            }
          });
        }
      } else {
        _timer?.cancel();
        // _animationController.stop();
        // ... (save session logic from previous step)
        if (mounted) {
          Navigator.of(context).pushReplacement(
            AppScreenTransitions.sharedAxis(BreakScreen(session: widget.session), SharedAxisTransitionType.horizontal),
          );
        }
      }
    });
  }

  void _pauseResumeTimer() {
    if (!mounted) return;
    setState(() {
      if (_isPaused) {
        _isPaused = false;
        _startWorkTimer();
      } else {
        _timer?.cancel();
        // _animationController.stop();
        _isPaused = true;
      }
    });
  }

  void _stopSessionAndGoBack() {
    _timer?.cancel();
    // _animationController.stop();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        AppScreenTransitions.sharedAxis(MainScreen(), SharedAxisTransitionType.scaled, duration: Duration(milliseconds: 400)), // Go back to MainScreen
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    // _animationController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    String greetingName = widget.session.userName.isNotEmpty ? widget.session.userName.split(" ")[0] : "User";
    double screenHeight = MediaQuery.of(context).size.height;
    // double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.secondary, // Deep purple background
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.05), // Space from top

                // Attractive Session Title Chip
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    // gradient: LinearGradient(
                    //   colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.1)],
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    // ),
                    color: Colors.white.withOpacity(0.18), // Solid color as per screenshot
                    borderRadius: BorderRadius.circular(25), // More rounded
                    // border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1)
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // So chip doesn't take full width
                    children: [
                      Icon(Icons.topic_outlined, color: Colors.white.withOpacity(0.8), size: 18), // Optional Icon
                      SizedBox(width: 8),
                      Flexible( // To prevent overflow if title is long
                        child: Text(
                          widget.session.title,
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      InkWell(
                        onTap: _stopSessionAndGoBack,
                        child: Icon(Icons.close, color: Colors.white.withOpacity(0.8), size: 20),
                      )
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.06),

                // Main Affirmation
                Text(
                  'Focus on a process',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: Colors.white.withOpacity(0.9)),
                ),
                Text(
                  '$greetingName!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenHeight * 0.05),

                // Big Timer Display
                GestureDetector(
                  onTap: _pauseResumeTimer, // Tappable timer for pause/resume
                  child: Text(
                    _formatTime(_currentSeconds),
                    style: TextStyle(fontSize: 100, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2.0),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),

                // Dynamic Affirmation Bubble (replaces "You can do it!")
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    _isPaused ? "Paused. Take a moment. 🧘" : _currentAffirmation, // Show random or paused message
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),

                Spacer(), // Pushes elements above and below

                // New Ticking Animation - Vertical Lines
                SizedBox(
                  height: 40, // Adjust height as desired for the animation area
                  width: MediaQuery.of(context).size.width * 0.85, // Control width if needed
                  // margin: EdgeInsets.symmetric(vertical: 10), // Add vertical margin if needed
                  child: CustomPaint(
                    painter: LinearSecondsPainter(
                      currentSecondTick: _totalWorkSeconds - _currentSeconds, // Elapsed seconds
                      totalTicksInCycle: 60,
                      baseLineColor: Colors.white.withOpacity(0.3),    // Dimmer base lines
                      highlightColor: AppColors.primary.withOpacity(1.0), // Fully opaque highlight
                      displayLineCount: 35, // e.g., 35 lines (odd number)
                      lineToSpacingRatio: 0.2, // Thinner lines
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03), // Space below painter

                // Pause/Resume Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: IconButton(
                    icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.white, size: 45),
                    onPressed: _pauseResumeTimer,
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.12),
                        padding: EdgeInsets.all(18)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}