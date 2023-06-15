import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mx_novice_guide/model/focus_animation_type.dart';

import '../widget/novice_guide.dart';

class FocusPainter extends CustomPainter {
  final Color? maskColor;
  final Iterable<TargetRectGetter> targets;
  final FocusAnimationType defaultAnimationType;

  FocusPainter({
    required this.targets,
    required this.maskColor,
    required this.defaultAnimationType,
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

    FocusAnimationType? focusAnimationType;

    double? maxProgress;

    // 挖掉目標rect
    for (var element in targets) {
      final target = element.target;
      final oriRect = element.oriRect;
      final rect = element.displayRect;
      focusAnimationType ??= element.animationType;
      maxProgress ??= element.progress;
      maxProgress = max(maxProgress, element.progress);

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

    focusAnimationType ??= defaultAnimationType;

    switch (focusAnimationType) {
      case FocusAnimationType.targetCenter:
        canvas.drawPath(
          fullPath,
          Paint()
            ..style = PaintingStyle.fill
            ..color = usedMaskColor,
        );

        if (totalTargetPath != null && maxProgress != null) {
          final oriOpacity = usedMaskColor.opacity;
          final progressOpacity = oriOpacity * maxProgress;
          canvas.drawPath(
            totalTargetPath,
            Paint()
              ..style = PaintingStyle.fill
              ..color = usedMaskColor.withOpacity(oriOpacity - progressOpacity),
          );
        }

        targetPathMap.forEach((key, value) {
          final borderSide = key.target.borderSide;
          if (borderSide != null && borderSide.style != BorderStyle.none) {
            final progress = key.progress;
            final oriOpacity = borderSide.color.opacity;
            final progressOpacity = oriOpacity * progress;
            canvas.drawPath(
              value,
              Paint()
                ..style = PaintingStyle.stroke
                ..color = borderSide.color.withOpacity(progressOpacity)
                ..strokeWidth = borderSide.width,
            );
          }
        });
        break;
      case FocusAnimationType.screen:
        if (targetPathMap.isNotEmpty && maxProgress != null) {
          final oriOpacity = usedMaskColor.opacity;
          final progressOpacity = oriOpacity * maxProgress;
          canvas.drawPath(
            fullPath,
            Paint()
              ..style = PaintingStyle.fill
              ..color = usedMaskColor.withOpacity(progressOpacity),
          );
        }

        targetPathMap.forEach((key, value) {
          final borderSide = key.target.borderSide;
          if (borderSide != null && borderSide.style != BorderStyle.none) {
            final progress = key.progress;
            final oriOpacity = borderSide.color.opacity;
            final progressOpacity = oriOpacity * progress;
            canvas.drawPath(
              value,
              Paint()
                ..style = PaintingStyle.stroke
                ..color = borderSide.color.withOpacity(progressOpacity)
                ..strokeWidth = borderSide.width,
            );
          }
        });
        break;
    }
  }

  @override
  bool shouldRepaint(FocusPainter oldDelegate) {
    return true;
  }
}
