// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:tutorial_coach_mark/src/target/target_position.dart';
//
// class LightTappablePaintRect extends CustomPainter {
//   final double progress;
//   final TargetPosition? tappableTarget;
//   final double offset;
//   final double tappableRadius;
//   final BorderSide? tappableBorderSide;
//   final double staticProgress;
//
//   LightTappablePaintRect({
//     required this.progress,
//     required this.staticProgress,
//     required this.tappableTarget,
//     this.offset = 10,
//     this.tappableRadius = 10,
//     this.tappableBorderSide,
//   });
//
//   static Path _drawJustHole(
//     Size canvasSize,
//     double x,
//     double y,
//     double w,
//     double h,
//   ) {
//     return Path()
//       ..moveTo(x + w, y)
//       ..lineTo(x + w, y + h)
//       ..lineTo(x, y + h)
//       ..lineTo(x, y)
//       ..close();
//   }
//
//   static Path _drawJustRHole(
//     Size canvasSize,
//     double x,
//     double y,
//     double w,
//     double h,
//     double radius,
//   ) {
//     double diameter = radius * 2;
//
//     return Path()
//       ..moveTo(x, y + radius)
//       ..arcTo(
//         Rect.fromLTWH(x, y, diameter, diameter),
//         pi,
//         pi / 2,
//         false,
//       )
//       ..arcTo(
//         Rect.fromLTWH(x + w - diameter, y, diameter, diameter),
//         3 * pi / 2,
//         pi / 2,
//         false,
//       )
//       ..arcTo(
//         Rect.fromLTWH(x + w - diameter, y + h - diameter, diameter, diameter),
//         0,
//         pi / 2,
//         false,
//       )
//       ..arcTo(
//         Rect.fromLTWH(x, y + h - diameter, diameter, diameter),
//         pi / 2,
//         pi / 2,
//         false,
//       )
//       ..lineTo(x, y + radius)
//       ..close();
//   }
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (tappableTarget == null || tappableTarget!.offset == Offset.zero) return;
//
//     var maxSize = max(size.width, size.height) +
//         max(tappableTarget!.size.width, tappableTarget!.size.height) +
//         tappableTarget!.getBiggerSpaceBorder(size);
//
//     final haveTappable = tappableTarget != null &&
//         tappableBorderSide != null &&
//         tappableBorderSide?.style != BorderStyle.none;
//
//     double x, y, w, h;
//
//     x = -maxSize / 2 * (1 - progress) + tappableTarget!.offset.dx - offset;
//
//     y = -maxSize / 2 * (1 - progress) + tappableTarget!.offset.dy - offset;
//
//     w = maxSize * (1 - progress) + tappableTarget!.size.width + offset * 2;
//
//     h = maxSize * (1 - progress) + tappableTarget!.size.height + offset * 2;
//
//     if (haveTappable) {
//       canvas.drawPath(
//         tappableRadius > 0
//             ? _drawJustRHole(size, x, y, w, h, tappableRadius)
//             : _drawJustHole(size, x, y, w, h),
//         Paint()
//           ..style = PaintingStyle.stroke
//           ..color = tappableBorderSide!.color
//           ..strokeWidth = tappableBorderSide!.width,
//       );
//     }
//   }
//
//   @override
//   bool shouldRepaint(LightTappablePaintRect oldDelegate) {
//     return oldDelegate.progress != progress;
//   }
// }
