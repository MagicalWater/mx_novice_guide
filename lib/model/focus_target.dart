import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mx_novice_guide/model/controller.dart';
import 'package:mx_novice_guide/widget/touch_rule_widget.dart';

import '../widget/novice_guide.dart';
import 'function_def.dart';

/// 需要鎖定的目標
class FocusTarget {
  final dynamic identify;

  /// 目標元件, 優先於[targetPosition]
  final GlobalKey? targetKey;

  /// 目標區塊
  final RRect? targetRect;

  /// 觸摸規則
  final TouchRule touchRule;

  /// 針對此target單獨構建的說明元件
  /// 與[GuideStep.descBuilder]差異在於當接收到構建請求時, 只能確定此target的rect已經獲取完成
  /// 其餘target的rect有可能尚未獲取完成
  /// 此值優先度小於[FocusTarget.descBuilder], 當[FocusTarget.descBuilder]給定值時, 此值將會失效
  final SingleDescContentBuilder? descBuilder;

  /// 鎖定區塊的樣式
  final BoxShape shape;

  /// 若[shape]是[BoxShape.circle]時 或目標使用[targetRect]時無效
  final BorderRadius? borderRadius;

  /// 區塊外框
  final BorderSide? borderSide;

  /// target顯示的目標區塊間距
  final EdgeInsets? targetPadding;

  /// 鎖定target時的動畫時間
  final Duration? focusAnimationDuration;

  /// 解除鎖定target時的動畫時間
  final Duration? unFocusAnimationDuration;

  /// 目標外框顫動動畫
  final Tween<double>? pulseVariation;

  /// 目標區塊上方佔位元件
  /// 會在目標區塊上方構建一個元件
  /// 通常可放置[InkWell]或者[GestureDetector]檢測點擊以及手勢
  /// 參數內會傳入目標區塊[RRect], 用以方便自行調整
  final TargetPlaceBuilder? targetPlaceBuilder;

  FocusTarget({
    this.identify,
    this.targetKey,
    this.targetRect,
    this.descBuilder,
    this.touchRule = TouchRule.allIntercept,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.borderSide,
    this.targetPadding,
    this.focusAnimationDuration,
    this.unFocusAnimationDuration,
    this.pulseVariation,
    this.targetPlaceBuilder = _defaultTargetPlaceBuilder,
  }) : assert(targetKey != null || targetRect != null);

  /// 預設的目標點擊佔位
  static Widget _defaultTargetPlaceBuilder(
    BuildContext context,
    NoviceGuideController controller,
    TargetRectGetter target,
  ) {
    final rect = target.oriRect!;
    final focusTarget = target.target;
    switch (focusTarget.shape) {
      case BoxShape.rectangle:
        return Positioned(
          left: rect.left,
          top: rect.top,
          child: InkWell(
            onTap: () {
              controller.next();
            },
            borderRadius: focusTarget.borderRadius,
            child: SizedBox(width: rect.width, height: rect.height),
          ),
        );
      case BoxShape.circle:
        final size = max(rect.width, rect.height);
        final radius = size / 2;
        final leftTop = rect.center.translate(-radius, -radius);
        return Positioned(
          left: leftTop.dx,
          top: leftTop.dy,
          child: InkWell(
            onTap: () {
              controller.next();
            },
            borderRadius: BorderRadius.circular(radius),
            child: SizedBox(width: size, height: size),
          ),
        );
    }
  }

  /// 取得當下的index需要高亮的目標
  RRect? getTargetRect({
    bool rootOverlay = false,
  }) {
    if (targetKey != null) {
      var key = targetKey!;

      final keyContext = key.currentContext;
      if (keyContext == null) {
        return null;
      }
      final renderBox = keyContext.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        return null;
      }
      final size = renderBox.size;

      BuildContext? parentContext;
      if (rootOverlay) {
        parentContext =
            keyContext.findRootAncestorStateOfType<OverlayState>()?.context;
      } else {
        parentContext =
            keyContext.findAncestorStateOfType<NavigatorState>()?.context;
      }
      Offset offset;
      if (parentContext != null) {
        offset = renderBox.localToGlobal(
          Offset.zero,
          ancestor: parentContext.findRenderObject(),
        );
      } else {
        offset = renderBox.localToGlobal(Offset.zero);
      }

      final endOffset = offset.translate(size.width, size.height);
      Rect rect;
      if (targetPadding != null) {
        final paddingStartOffset = offset.translate(
          -targetPadding!.left,
          -targetPadding!.top,
        );
        final paddingEndOffset = endOffset.translate(
          targetPadding!.right,
          targetPadding!.bottom,
        );
        rect = Rect.fromPoints(paddingStartOffset, paddingEndOffset);
      } else {
        rect = Rect.fromPoints(offset, endOffset);
      }
      if (borderRadius != null) {
        return RRect.fromRectAndCorners(
          rect,
          topLeft: borderRadius!.topLeft,
          topRight: borderRadius!.topRight,
          bottomLeft: borderRadius!.bottomLeft,
          bottomRight: borderRadius!.bottomRight,
        );
      } else {
        return RRect.fromRectXY(rect, 0, 0);
      }
    } else {
      return targetRect;
    }
  }
}
