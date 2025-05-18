// lib/screens/timer_screen.dart
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pomo_app/models/session_model.dart';
import 'package:pomo_app/screens/break_screen.dart';
import 'package:pomo_app/screens/main_screen.dart'; 
import 'package:pomo_app/services/history_service.dart';
import 'package:pomo_app/utils/colors.dart';
import 'package:pomo_app/utils/animations.dart';
import 'package:pomo_app/widgets/ticking_animation.dart';
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
  late int _totalWorkSeconds;
  bool _isPaused = false;


  String _currentAffirmation = ""; 
  String _nextAffirmationInPreview = "";
  Key _affirmationBubbleKey = UniqueKey();

  final HistoryService _historyService = HistoryService();

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
    _totalWorkSeconds = widget.session.workDurationMinutes * 60; // Convert minutes to seconds
    _currentSeconds = _totalWorkSeconds;
    _initializeAffirmations();
    _startWorkTimer();
  }

  void _initializeAffirmations() {
    if (_affirmationsList.isEmpty) return;
    final random = Random();
    _currentAffirmation = _affirmationsList[random.nextInt(_affirmationsList.length)];

    if (_affirmationsList.length > 1) {
      do {
        _nextAffirmationInPreview = _affirmationsList[random.nextInt(_affirmationsList.length)];
      } while (_nextAffirmationInPreview == _currentAffirmation);
    } else {
      _nextAffirmationInPreview = _currentAffirmation; // Fallback if only one affirmation
    }
  }

  void _updateAffirmations() {
    if (!mounted || _affirmationsList.isEmpty) return;

    setState(() {
      // The current _nextAffirmationInPreview moves to the bubble
      _currentAffirmation = _nextAffirmationInPreview;
      _affirmationBubbleKey = ValueKey<String>(_currentAffirmation);

      if (_affirmationsList.length > 1) {
        String newNext;
        final random = Random();
        do {
          newNext = _affirmationsList[random.nextInt(_affirmationsList.length)];
        } while (newNext == _currentAffirmation);
        _nextAffirmationInPreview = newNext;
      } else {
        // If only one or no affirmations left to choose from that are different
        _nextAffirmationInPreview = _currentAffirmation;
      }
    });
  }

  void _startWorkTimer() {
    _isPaused = false;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_currentSeconds > 0) {
        if (mounted) {
          setState(() {
            _currentSeconds--;
            // Change affirmation every 15 seconds for example
            if (_currentSeconds % 15 == 0 && _currentSeconds < _totalWorkSeconds - 5) { 
              _updateAffirmations();
            }
          });
        }
      } else {
        _timer?.cancel();
        final completedSession = widget.session;
        completedSession.completionDate = DateTime.now();
        _historyService.addSession(completedSession);
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

                TickingAnimation(
                  isRunning: !_isPaused,
                  lineColor: Colors.white.withOpacity(0.6),
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 60,
                  numberOfLines: 9,
                  animationDuration: Duration(milliseconds: 1500),
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

                Padding(
                  padding: const EdgeInsets.only(top:12.0),
                  child: AnimatedSwitcher( // To animate changes in the next affirmation text itself
                  duration: const Duration(milliseconds: 700),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition( // Optional: add a slight slide
                          position: Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(animation),
                          child: child
                      ),
                    );
                  },
                  child: Text(
                    _isPaused ? "" : _nextAffirmationInPreview, // Show next only when not paused
                    key: ValueKey<String>(_nextAffirmationInPreview), // Key to trigger animation on text change
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5), // Less prominent
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                                ),
                ),
              SizedBox(height: screenHeight * 0.025), 

              Spacer(), // Pushes elements above and below

              SizedBox(height: screenHeight * 0.03),

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