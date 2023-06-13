// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:tutorial_coach_mark/src/target/target_position.dart';
//
// class LightPaintRect extends CustomPainter {
//   final double progress;
//   final TargetPosition target;
//   final TargetPosition? tappableTarget;
//   final Color colorShadow;
//   final double opacityShadow;
//   final double offset;
//   final double radius;
//   final double tappableRadius;
//   final BorderSide? borderSide;
//   final BorderSide? tappableBorderSide;
//   final double staticProgress;
//
//   LightPaintRect({
//     required this.progress,
//     required this.staticProgress,
//     required this.target,
//     required this.tappableTarget,
//     this.colorShadow = Colors.black,
//     this.opacityShadow = 0.8,
//     this.offset = 10,
//     this.radius = 10,
//     this.tappableRadius = 10,
//     this.borderSide,
//     this.tappableBorderSide,
//   }) : assert(opacityShadow >= 0 && opacityShadow <= 1);
//
//   static Path _drawRectHole(
//     Size canvasSize,
//     double x,
//     double y,
//     double w,
//     double h,
//   ) {
//     return Path()
//       ..moveTo(0, 0)
//       ..lineTo(0, y)
//       ..lineTo(x + w, y)
//       ..lineTo(x + w, y + h)
//       ..lineTo(x, y + h)
//       ..lineTo(x, y)
//       ..lineTo(0, y)
//       ..lineTo(0, canvasSize.height)
//       ..lineTo(canvasSize.width, canvasSize.height)
//       ..lineTo(canvasSize.width, 0)
//       ..close();
//   }
//
//   static Path _drawRRectHole(
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
//       ..moveTo(0, 0)
//       ..lineTo(0, y + radius)
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
//       ..lineTo(0, y + radius)
//       ..lineTo(0, canvasSize.height)
//       ..lineTo(canvasSize.width, canvasSize.height)
//       ..lineTo(canvasSize.width, 0)
//       ..close();
//   }
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
//     if (target.offset == Offset.zero) return;
//
//     var maxSize = max(size.width, size.height) +
//         max(target.size.width, target.size.height) +
//         target.getBiggerSpaceBorder(size);
//
//     final haveTappable = tappableTarget != null &&
//         tappableBorderSide != null &&
//         tappableBorderSide?.style != BorderStyle.none;
//
//     double x, y, w, h;
//
//     if (haveTappable) {
//       x = -maxSize / 2 * (1 - staticProgress) + target.offset.dx - offset;
//
//       y = -maxSize / 2 * (1 - staticProgress) + target.offset.dy - offset;
//
//       w = maxSize * (1 - staticProgress) + target.size.width + offset * 2;
//
//       h = maxSize * (1 - staticProgress) + target.size.height + offset * 2;
//     } else {
//       x = -maxSize / 2 * (1 - progress) + target.offset.dx - offset;
//
//       y = -maxSize / 2 * (1 - progress) + target.offset.dy - offset;
//
//       w = maxSize * (1 - progress) + target.size.width + offset * 2;
//
//       h = maxSize * (1 - progress) + target.size.height + offset * 2;
//     }
//
//     canvas.drawPath(
//       radius > 0
//           ? _drawRRectHole(size, x, y, w, h, radius)
//           : _drawRectHole(size, x, y, w, h),
//       Paint()
//         ..style = PaintingStyle.fill
//         ..color = colorShadow.withOpacity(opacityShadow)
//         ..strokeWidth = 4,
//     );
//     if (borderSide != null && borderSide?.style != BorderStyle.none) {
//       canvas.drawPath(
//         radius > 0
//             ? _drawJustRHole(size, x, y, w, h, radius)
//             : _drawJustHole(size, x, y, w, h),
//         Paint()
//           ..style = PaintingStyle.stroke
//           ..color = borderSide!.color
//           ..strokeWidth = borderSide!.width,
//       );
//     }
//   }
//
//   @override
//   bool shouldRepaint(LightPaintRect oldDelegate) {
//     return oldDelegate.progress != progress;
//   }
// }
