// lib/screens/timer_screen.dart
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:async';
import 'dart:math'; // For random affirmations
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pomo_app/models/session_model.dart';
import 'package:pomo_app/screens/break_screen.dart';
import 'package:pomo_app/screens/main_screen.dart';
import 'package:pomo_app/utils/colors.dart';
import 'package:pomo_app/utils/animations.dart';
import 'package:pomo_app/widgets/timer_painter.dart';
import 'package:pomo_app/services/history_service.dart';

class TimerScreen extends StatefulWidget {
  final SessionModel session;

  const TimerScreen({super.key, required this.session});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  Timer? _timer;
  late int _currentSeconds;
  late AnimationController _animationController;
  bool _isPaused = false;

  final HistoryService _historyService = HistoryService();

  String _currentBottomAffirmation1 = "";
  String _currentBottomAffirmation2 = "";

  final List<String> _bottomAffirmations = [
    "Keep going! 💪",
    "Almost there!",
    "Stay focused.",
    "You've got this!",
    "Deep breath.",
    "One step at a time.",
    "Progress, not perfection.",
    "Make it happen.",
    "Stay strong.",
    "Believe in yourself."
  ];

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.session.workDurationMinutes *60;

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _currentSeconds),
    );
    _animationController.value = 0.0; // Start from beginning

    _startWorkTimer();
    _setRandomBottomAffirmations();
  }

  void _setRandomBottomAffirmations() {
    final random = Random();
    _currentBottomAffirmation1 = _bottomAffirmations[random.nextInt(_bottomAffirmations.length)];
    // Ensure second affirmation is different if possible and list is long enough
    if (_bottomAffirmations.length > 1) {
      do {
        _currentBottomAffirmation2 = _bottomAffirmations[random.nextInt(_bottomAffirmations.length)];
      } while (_currentBottomAffirmation2 == _currentBottomAffirmation1 && _bottomAffirmations.length > 1);
    } else {
        _currentBottomAffirmation2 = ""; // No second affirmation if list is too short
    }
  }


  void _updateAnimationControllerDuration() {
    _animationController.duration = Duration(seconds: widget.session.workDurationMinutes * 60);
  }

  void _startWorkTimer() {
    _isPaused = false;
    _updateAnimationControllerDuration();
    _animationController.forward(from: 1.0 - (_currentSeconds / (widget.session.workDurationMinutes * 60).clamp(1, double.infinity))); // Ensure non-zero divisor

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_currentSeconds > 0) {
        if (mounted) { // Check if widget is still in the tree
          setState(() {
            _currentSeconds--;
            if (_currentSeconds % 15 == 0) { // Change bottom affirmations periodically
                _setRandomBottomAffirmations();
            }
          });
        }
      } else {
        _timer?.cancel();
        _animationController.stop();

        // **** SAVE SESSION TO HISTORY ****
        final completedSession = widget.session; // Session details are in widget.session
        completedSession.completionDate = DateTime.now(); // Set completion time
        // Optionally assign a unique ID if not done in model's toJson
        // completedSession.id = DateTime.now().millisecondsSinceEpoch.toString();
        _historyService.addSession(completedSession).then((_) {
            print("Session saved: ${completedSession.title}");
        }).catchError((error) {
            print("Error saving session: $error");
        });
        // ********************************

        if (mounted) {
          Navigator.of(context).pushReplacement(
            Animations.fadeTransition(BreakScreen(session: widget.session)),
          );
        }
      }
    });
  }

  void _pauseResumeTimer() {
    if (!mounted) return;
    setState(() {
      if (_isPaused) { // Resume
        _isPaused = false;
        _startWorkTimer();
      } else { // Pause
        _timer?.cancel();
        _animationController.stop();
        _isPaused = true;
      }
    });
  }

  void _stopSessionAndGoBack() {
    _timer?.cancel();
    _animationController.stop();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MainScreen()
          ,
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}'; // Changed to match image "0:02"
  }

  @override
  Widget build(BuildContext context) {
    String greetingName = widget.session.userName.isNotEmpty ? widget.session.userName.split(" ")[0] : "User";
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.secondary, // Deep purple background
      body: SafeArea(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ticking Animation (Dashed Arc)
              Positioned(
                top: screenHeight * 0.48, // Adjust as needed
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(screenWidth * 0.6, screenWidth * 0.3), // Width, Height
                      painter: TimerPainter(
                        progress: 1.0 - (_currentSeconds / (widget.session.workDurationMinutes * 60).clamp(1, double.infinity)),
                        backgroundColor: Colors.transparent,
                        color: Colors.white.withOpacity(0.7),
                        isDashed: true,
                        strokeWidth: 3,
                        dashCount: 20, // Fewer dashes for this smaller arc
                        isArcPartial: true,
                        arcAngleCoverage: math.pi * 1.0, // Semicircle for example
                      ),
                    );
                  },
                ),
              ),

// SECONDARY DECORATIVE/BACKGROUND DASHED CIRCLE (Lower on the screen)
              // Positioned(
              //   bottom: screenHeight * 0.12, // Adjusted position
              //   child: CustomPaint(
              //     size: Size(screenWidth * 0.85, screenWidth * 0.85), // Larger
              //     painter: TimerPainter(
              //       progress: 1.0, // Not used if isFixedCircle is true
              //       backgroundColor: Colors.transparent,
              //       color: Colors.white.withOpacity(0.20), // Slightly more subtle
              //       isDashed: true,
              //       strokeWidth: 2.5,
              //       dashCount: 40, // More dashes for a fuller circle
              //       isFixedCircle: true, // This makes it a static full dashed circle
              //     ),
              //   ),
              // ),

              // Main Content Column
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Session Title Chip
                    Chip(
                      backgroundColor: Colors.black, // Slightly increased opacity for better background
                        label: Text(
                          widget.session.title,
                          style: TextStyle(
                            color: Colors.white, // Explicitly white
                            fontSize: 16,
                            fontWeight: FontWeight.w600, // Slightly bolder
                          ),
                        ),
                        deleteIcon: Icon(Icons.close, color: Colors.white, size: 20), // Ensure delete icon is visible
                        onDeleted: _stopSessionAndGoBack,
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10), // Adjust padding if needed
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // Softer corners
                      ),
                    SizedBox(height: screenHeight * 0.05),

                    // Main Affirmation
                    Text(
                      'Focus on a process',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, color: Colors.white.withOpacity(0.9)),
                    ),
                    Text(
                      '$greetingName!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.bold), // Pomodoro Orange for name
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // Big Timer Display (tappable for pause/resume)
                    GestureDetector(
                      onTap: _pauseResumeTimer,
                      child: Text(
                        _formatTime(_currentSeconds),
                        style: TextStyle(fontSize: 100, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03), // Space for the ticking animation to be visible below

                    // Small Affirmation Bubble
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        _isPaused ? "Paused. Take a moment. 🧘" : "You can do it! 😊",
                        style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.08), // More space before bottom affirmations

                    // Random Smaller Affirmations at the Bottom
                    Text(
                       _isPaused ? "" : 'Come on, $greetingName 🙇', // Or _currentBottomAffirmation1
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5)),
                    ),
                    SizedBox(height: 5),
                    if (!_isPaused && _currentBottomAffirmation2.isNotEmpty) // Only show if not paused and affirmation exists
                        Text(
                        _currentBottomAffirmation2, // "Step on it! 🔥" or similar
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.35)),
                        ),

                    Spacer(), // Pushes pause button to bottom if we keep it separate
                     // Pause/Resume Button (Alternative if timer tap isn't preferred)
                     if (true) // Set to false if timer tap is enough
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: IconButton(
                            icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.white, size: 40),
                            onPressed: _pauseResumeTimer,
                            style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                padding: EdgeInsets.all(15)
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}