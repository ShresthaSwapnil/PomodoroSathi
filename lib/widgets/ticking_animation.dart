// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';

class TickingAnimation extends StatefulWidget {
  final bool isRunning;
  final Color lineColor;
  final double width;
  final double height;
  final int numberOfLines;
  final Duration animationDuration;

  const TickingAnimation({
    super.key,
    required this.isRunning,
    this.lineColor = Colors.white,
    this.width = 200,
    this.height = 60,
    this.numberOfLines = 7,
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<TickingAnimation> createState() => _TickingAnimationState();
}

class _TickingAnimationState extends State<TickingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    if (widget.isRunning) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(TickingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: TickingPainter(
              animationValue: _animation.value,
              lineColor: widget.lineColor,
              numberOfLines: widget.numberOfLines,
            ),
            size: Size(widget.width, widget.height),
          );
        },
      ),
    );
  }
}

class TickingPainter extends CustomPainter {
  final double animationValue;
  final Color lineColor;
  final int numberOfLines;

  TickingPainter({
    required this.animationValue,
    required this.lineColor,
    required this.numberOfLines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Calculate the spacing between lines
    final spacing = size.width / (numberOfLines + 1);
    
    // Calculate the center line index
    final centerLineIndex = numberOfLines ~/ 2;

    for (int i = 0; i < numberOfLines; i++) {
      final x = spacing * (i + 1);
      
      // Calculate the height and opacity based on distance from center and animation
      double lineHeight;
      double opacity;
      
      if (i == centerLineIndex) {
        // Center line is always the tallest
        lineHeight = size.height * 0.6;
        opacity = 1.0;
      } else {
        // Other lines have animated heights and move from left to right
        final distanceFromCenter = (i - centerLineIndex).abs();
        final maxDistance = centerLineIndex + 1;
        
        // Calculate the wave position
        final wavePosition = (animationValue * 2 - 1).abs(); // Creates a wave that goes 0->1->0
        final linePosition = (i / numberOfLines) * 2 - 1; // Convert to -1 to 1 range
        
        // Calculate how close this line is to the current wave position
        final proximity = 1 - (linePosition - animationValue * 2 + 1).abs().clamp(0.0, 1.0);
        
        // Base height decreases with distance from center
        final baseHeight = size.height * (0.3 - (distanceFromCenter / maxDistance) * 0.2);
        
        // Add animated height based on proximity to the wave
        final animatedHeight = size.height * 0.3 * proximity * sin(animationValue * pi * 4);
        
        lineHeight = (baseHeight + animatedHeight).clamp(size.height * 0.1, size.height * 0.5);
        opacity = (0.3 + proximity * 0.7).clamp(0.3, 1.0);
      }
      
      paint.color = lineColor.withOpacity(opacity);
      
      final startY = centerY - lineHeight / 2;
      final endY = centerY + lineHeight / 2;
      
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}