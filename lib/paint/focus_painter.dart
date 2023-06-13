import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mx_novice_guide/model/model.dart';

import '../widget/novice_guide.dart';

class FocusPainter extends CustomPainter {
  final Color? maskColor;
  final Iterable<TargetRectGetter> targets;

  FocusPainter({
    required this.targets,
    required this.maskColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // print('滿版size => $size');

    // 滿版path
    var fullPath = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    final targetPathMap = <FocusTarget, Path>{};

    // 挖掉目標rect
    for (var element in targets) {
      final target = element.target;
      final rect = element.displayRect;

      if (rect == null) {
        continue;
      }

      final targetPath = Path();
      if (target.shape == BoxShape.rectangle) {
        targetPath.addRRect(rect);
      } else {
        final maxSize = max(rect.width, rect.height);
        targetPath.addOval(Rect.fromCenter(
          center: rect.center,
          width: maxSize,
          height: maxSize,
        ));
      }
      targetPathMap[target] = targetPath;
      fullPath = Path.combine(PathOperation.difference, fullPath, targetPath);
    }

    canvas.drawPath(
      fullPath,
      Paint()
        ..style = PaintingStyle.fill
        ..color = maskColor ?? Colors.black.withOpacity(0.6),
    );

    targetPathMap.forEach((key, value) {
      final borderSide = key.borderSide;
      if (borderSide != null && borderSide.style != BorderStyle.none) {
        canvas.drawPath(
          value,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = borderSide.color
            ..strokeWidth = borderSide.width,
        );
      }
    });
    // if (borderSide != null && borderSide?.style != BorderStyle.none) {
    //   canvas.drawPath(
    //       justCircleHole,
    //       Paint()
    //         ..style = PaintingStyle.stroke
    //         ..color = borderSide!.color
    //         ..strokeWidth = borderSide!.width);
    // }
  }

  @override
  bool shouldRepaint(FocusPainter oldDelegate) {
    return true;
  }
}
