import 'package:flutter/material.dart';
import 'dart:math' as math;

class LinearSecondsPainter extends CustomPainter {
  final int currentSecondTick;    // The actual current second of the timer (elapsed seconds)
  final int totalTicksInCycle;    // Total ticks in a full animation cycle (e.g., 60 for seconds)
  final Color baseLineColor;
  final Color highlightColor;
  final int displayLineCount;     // Number of lines to display on screen (odd number recommended)
  final double lineToSpacingRatio; // e.g., 0.2 means line width is 20% of the space allocated to it

  LinearSecondsPainter({
    required this.currentSecondTick,
    this.totalTicksInCycle = 60,
    required this.baseLineColor,
    required this.highlightColor,
    this.displayLineCount = 31, // Keep it odd for a clear visual center
    this.lineToSpacingRatio = 0.25, // Adjust for thicker/thinner lines relative to spacing
  }) : assert(displayLineCount > 0);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;
    final double availableWidth = size.width;

    // Calculate spacing and line width
    // Each line effectively has 'spacing' width dedicated to it.
    final double spacing = availableWidth / displayLineCount;
    final double lineWidth = math.max(1.5, spacing * lineToSpacingRatio);
    paint.strokeWidth = lineWidth;

    final double baseLineHeight = size.height * 0.55; // Normal height
    final double highlightLineHeight = size.height * 0.90; // Highlighted is taller

    // The visual center index of the displayed lines
    final int centerDisplayIndex = (displayLineCount / 2).floor();

    // The current actual tick in its animation cycle (e.g., if currentSecondTick is 65 and totalTicksInCycle is 60, this is 5)
    final int currentAnimationCycleTick = currentSecondTick % totalTicksInCycle;

    for (int i = 0; i < displayLineCount; i++) {
      // Calculate the offset of the current display line 'i' from the visual center
      // Positive offset means to the right of center, negative means to the left.
      int offsetFromCenter = i - centerDisplayIndex;

      // Determine which "data tick" this display line 'i' represents.
      // The center display line (offsetFromCenter = 0) represents the currentAnimationCycleTick.
      // To make data flow from RIGHT to LEFT:
      // A line to the right of center (positive offset) should show an "earlier" tick.
      // A line to the left of center (negative offset) should show a "later" tick.
      // So, dataTickForThisLine = currentAnimationCycleTick - offsetFromCenter.
      int dataTickForThisLine = currentAnimationCycleTick - offsetFromCenter;

      // Normalize dataTickForThisLine to be within [0, totalTicksInCycle - 1]
      // This handles the wrap-around effect of the cycle.
      dataTickForThisLine = dataTickForThisLine % totalTicksInCycle;
      if (dataTickForThisLine < 0) {
        dataTickForThisLine += totalTicksInCycle;
      }

      // X-coordinate for the center of the current line 'i'
      final double x = spacing / 2 + i * spacing;

      // The visual highlight is ALWAYS the line at centerDisplayIndex
      bool isVisuallyCenterHighlighted = (i == centerDisplayIndex);

      paint.color = isVisuallyCenterHighlighted ? highlightColor : baseLineColor;

      // Optional: Dim lines further from the center for a focus effect
      if (!isVisuallyCenterHighlighted) {
        double distanceFactor = (offsetFromCenter.abs() / (centerDisplayIndex.toDouble() + 1.0) ).clamp(0.0, 1.0); // Normalize distance
        paint.color = baseLineColor.withOpacity(math.max(0.2, 1.0 - distanceFactor * 0.7)); // Example: dim by up to 70%
      }

      final double lineHeight = isVisuallyCenterHighlighted ? highlightLineHeight : baseLineHeight;
      final double yStart = (size.height - lineHeight) / 2; // Centered vertically within the painter's bounds
      final double yEnd = yStart + lineHeight;

      canvas.drawLine(Offset(x, yStart), Offset(x, yEnd), paint);
    }
  }

  @override
  bool shouldRepaint(covariant LinearSecondsPainter oldDelegate) {
    return oldDelegate.currentSecondTick != currentSecondTick ||
           oldDelegate.baseLineColor != baseLineColor ||
           oldDelegate.highlightColor != highlightColor ||
           oldDelegate.displayLineCount != displayLineCount ||
           oldDelegate.totalTicksInCycle != totalTicksInCycle ||
           oldDelegate.lineToSpacingRatio != lineToSpacingRatio;
  }
}