// import 'dart:math';
//
// import 'package:flutter/material.dart';
//
// class LightTappablePaint extends CustomPainter {
//   final double progress;
//   final Offset? tappablePositioned;
//   final double? tappableSizeCircle;
//   final BorderSide? tappableBorderSide;
//
//   LightTappablePaint({
//     required this.progress,
//     required this.tappablePositioned,
//     required this.tappableSizeCircle,
//     this.tappableBorderSide,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (tappablePositioned == Offset.zero) return;
//     var maxSize = max(size.width, size.height);
//     // print('progress = $progress');
//
//     final haveTappable = tappableSizeCircle != null &&
//         tappablePositioned != null &&
//         tappableBorderSide != null &&
//         tappableBorderSide?.style != BorderStyle.none;
//
//     if (haveTappable) {
//       final tappableRadius = maxSize * (1 - progress) + tappableSizeCircle!;
//       final tappableCircleHole = Path()
//         ..moveTo(
//             tappablePositioned!.dx - tappableRadius, tappablePositioned!.dy)
//         ..arcTo(
//           Rect.fromCircle(center: tappablePositioned!, radius: tappableRadius),
//           pi,
//           pi,
//           false,
//         )
//         ..arcTo(
//           Rect.fromCircle(center: tappablePositioned!, radius: tappableRadius),
//           0,
//           pi,
//           false,
//         )
//         ..close();
//       canvas.drawPath(
//           tappableCircleHole,
//           Paint()
//             ..style = PaintingStyle.stroke
//             ..color = tappableBorderSide!.color
//             ..strokeWidth = tappableBorderSide!.width);
//     }
//   }
//
//   @override
//   bool shouldRepaint(LightTappablePaint oldDelegate) {
//     return oldDelegate.progress != progress;
//   }
// }
