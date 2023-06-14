import 'dart:math';

import 'package:flutter/material.dart';

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

    final targetPathMap = <TargetRectGetter, Path>{};

    Path? totalTargetPath;

    final usedMaskColor = maskColor ?? Colors.black.withOpacity(0.6);

    // 挖掉目標rect
    for (var element in targets) {
      final target = element.target;
      final oriRect = element.oriRect;
      final rect = element.displayRect;

      if (rect == null || oriRect == null) {
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
      targetPathMap[element] = targetPath;

      if (totalTargetPath == null) {
        totalTargetPath = targetPath;
      } else {
        totalTargetPath =
            Path.combine(PathOperation.union, totalTargetPath, targetPath);
      }
      fullPath = Path.combine(PathOperation.difference, fullPath, targetPath);
    }

    canvas.drawPath(
      fullPath,
      Paint()
        ..style = PaintingStyle.fill
        ..color = usedMaskColor,
    );

    if (totalTargetPath != null) {
      double? maxProgress;
      for (var element in targets) {
        maxProgress ??= element.progress;
        maxProgress = max(maxProgress, element.progress);
      }

      if (maxProgress != null) {
        final oriOpacity = usedMaskColor.opacity;
        final progressOpacity = oriOpacity * maxProgress;
        canvas.drawPath(
          totalTargetPath,
          Paint()
            ..style = PaintingStyle.fill
            ..color = usedMaskColor.withOpacity(oriOpacity - progressOpacity),
        );
      }
    }

    targetPathMap.forEach((key, value) {
      final borderSide = key.target.borderSide;
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
  }

  @override
  bool shouldRepaint(FocusPainter oldDelegate) {
    return true;
  }
}
