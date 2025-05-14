// lib/widgets/timer_painter.dart
import 'dart:math' as math; // Ensure math is imported as math
import 'package:flutter/material.dart';

class TimerPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color color;
  final bool isDashed;
  final double strokeWidth;
  final int dashCount;
  final bool isArcPartial; // New: Is it a partial arc for the progress?
  final double arcAngleCoverage; // New: How much angle the partial arc should cover (e.g., pi for semicircle)
  final bool isFixedCircle; // New: Is it a static, full dashed circle?

  TimerPainter({
    required this.progress,
    required this.backgroundColor,
    required this.color,
    this.isDashed = false,
    this.strokeWidth = 6.0,
    this.dashCount = 30,
    this.isArcPartial = false, // Default to false
    this.arcAngleCoverage = 2 * math.pi, // Default to full circle if partial
    this.isFixedCircle = false, // Default to false
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2.0;
    final Offset center = size.center(Offset.zero);
    double baseStartAngle = -math.pi / 2; // Top of the circle

    // Adjust start angle if it's a partial arc to center it
    if (isArcPartial) {
      baseStartAngle = -math.pi / 2 - (arcAngleCoverage / 2) + (math.pi /2); // This centers the arc at the bottom
      // If you want the arc to start from one side and go around:
      // baseStartAngle = -math.pi / 2 - (arcAngleCoverage / 2) + (math.pi - arcAngleCoverage)/2 ;
      // A common way for bottom arc:
      baseStartAngle = math.pi - (arcAngleCoverage / 2);

    }


    // Draw background track (only if specified and not a fixed dashed circle)
    if (backgroundColor != Colors.transparent && !isFixedCircle) {
      paint.color = backgroundColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        baseStartAngle,
        isArcPartial ? arcAngleCoverage : 2 * math.pi,
        false,
        paint);
    }

    paint.color = color;
    double currentSweepAngle = isFixedCircle ? 2 * math.pi : (isArcPartial ? progress * arcAngleCoverage : progress * 2 * math.pi);


    if (isDashed) {
      paint.strokeCap = StrokeCap.butt;
      int effectiveDashCount = isArcPartial ? (dashCount * (arcAngleCoverage / (2*math.pi))).round() : dashCount;
      if (effectiveDashCount == 0) effectiveDashCount = 1;


      double segmentLengthOnCircumference = (isArcPartial ? arcAngleCoverage : 2 * math.pi) * radius / effectiveDashCount;
      double dashAngle = (segmentLengthOnCircumference * 0.6) / radius;
      double spaceAngle = (segmentLengthOnCircumference * 0.4) / radius;
      double totalDashAndSpaceAngle = dashAngle + spaceAngle;
      if (totalDashAndSpaceAngle <= 0) totalDashAndSpaceAngle = 0.01; // Prevent division by zero

      for (double angleOffset = 0; angleOffset < currentSweepAngle; angleOffset += totalDashAndSpaceAngle) {
        double actualDashSweep = math.min(dashAngle, currentSweepAngle - angleOffset);
        if (actualDashSweep <= 0.001) break;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          baseStartAngle + angleOffset,
          actualDashSweep,
          false,
          paint,
        );
      }
    } else {
      paint.strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        baseStartAngle,
        currentSweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    return progress != oldDelegate.progress ||
           color != oldDelegate.color ||
           backgroundColor != oldDelegate.backgroundColor ||
           isDashed != oldDelegate.isDashed ||
           strokeWidth != oldDelegate.strokeWidth ||
           dashCount != oldDelegate.dashCount ||
           isArcPartial != oldDelegate.isArcPartial ||
           arcAngleCoverage != oldDelegate.arcAngleCoverage ||
           isFixedCircle != oldDelegate.isFixedCircle;
  }
}