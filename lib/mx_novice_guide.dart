import 'package:flutter/material.dart';
import 'package:mx_novice_guide/model/focus_target.dart';

import 'model/controller.dart';
import 'model/focus_animation_type.dart';
import 'model/guide_step.dart';
import 'widget/novice_guide.dart';

export 'model/model.dart';
export 'widget/novice_guide.dart';

typedef GuideStepBuilder = GuideStep Function(BuildContext context, int index);

/// 教學引導
class MxNoviceGuide implements NoviceGuideController {
  /// 共有多少步驟
  final int count;

  /// 步驟構建
  final GuideStepBuilder builder;

  /// 預設[FocusTarget.targetPadding]
  final EdgeInsetsGeometry? targetPadding;

  /// 預設[FocusTarget.skip]
  final Widget? skipWidget;

  /// 預設[FocusTarget.skipAlign]
  final AlignmentGeometry skipAlign;

  /// 預設[FocusTarget.skipMargin]
  final EdgeInsetsGeometry? skipMargin;

  /// 預設[FocusTarget.maskColor]顏色遮罩
  final Color? maskColor;

  /// 鎖定target時的動畫時間
  final Duration animationDuration;

  /// 鎖定目標的方式, 預設為[FocusAnimationType.targetCenter]
  final FocusAnimationType animationType;

  /// 鎖定動畫差值器
  final Curve animationCurve;

  final bool pulseEnable;

  final NoviceGuideController? controller;

  final NoviceGuideController _usedController;

  OverlayEntry? _overlayEntry;

  MxNoviceGuide({
    required this.count,
    required this.builder,
    this.controller,
    this.targetPadding,
    this.skipWidget,
    this.skipAlign = Alignment.topRight,
    this.skipMargin,
    this.maskColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationType = FocusAnimationType.targetCenter,
    this.animationCurve = Curves.fastOutSlowIn,
    this.pulseEnable = true,
  }) : _usedController = controller ?? NoviceGuideController.create();

  OverlayEntry _buildOverlay({
    bool rootOverlay = false,
    VoidCallback? onFinish,
  }) {
    return OverlayEntry(
      builder: (context) {
        return NoviceGuide(
          count: count,
          builder: builder,
          targetPadding: targetPadding,
          skipWidget: skipWidget,
          skipAlign: skipAlign,
          skipMargin: skipMargin,
          maskColor: maskColor,
          animationDuration: animationDuration,
          animationType: animationType,
          animationCurve: animationCurve,
          pulseEnable: pulseEnable,
          rootOverlay: rootOverlay,
          controller: _usedController,
          onFinish: () {
            _removeOverlay();
            onFinish?.call();
          },
        );
      },
    );
  }

  /// 顯示教學彈窗, 若當前已有彈窗正在顯示, 則會回傳正在顯示的overlay, 不會執行其餘動作
  OverlayEntry? show({
    required BuildContext context,
    bool rootOverlay = false,
    OverlayEntry? below,
    OverlayEntry? above,
    VoidCallback? onFinish,
  }) {
    if (_overlayEntry == null) {
      _overlayEntry = _buildOverlay(
        rootOverlay: rootOverlay,
        onFinish: onFinish,
      );
      final overlay = Overlay.of(context, rootOverlay: rootOverlay);
      overlay.insert(_overlayEntry!, below: below, above: above);
    }
    return _overlayEntry;
  }

  @override
  Future<void> finish() {
    return _usedController.finish().then((value) {
      _removeOverlay();
    });
  }

  @override
  bool get isShowing => _usedController.isShowing;

  @override
  GuideStep? get currentStep => _usedController.currentStep;

  @override
  int? get currentStepIndex => _usedController.currentStepIndex;

  /// [waitCurrentEnd] - 是否等待當前步驟關閉後再跳下個步驟
  /// [currentEndWithAnimation] - 關閉當前步驟是否有動畫
  /// [onCurrentEndComplete] -
  ///         當前步驟完全關閉後回調, 若需要在此執行等待操作, 可以在此回傳Future, 當[waitCurrentEnd]為true時有效
  @override
  Future<void> next({
    bool waitCurrentEnd = true,
    bool currentEndWithAnimation = true,
    FutureCallback? onCurrentEndComplete,
  }) =>
      _usedController.next(
        waitCurrentEnd: waitCurrentEnd,
        currentEndWithAnimation: currentEndWithAnimation,
        onCurrentEndComplete: onCurrentEndComplete,
      );

  @override
  bool canNext() => _usedController.canNext();

  /// [waitCurrentEnd] - 是否等待當前步驟關閉後再跳上個步驟
  /// [currentEndWithAnimation] - 關閉當前步驟是否有動畫
  /// [onCurrentEndComplete] -
  ///         當前步驟完全關閉後回調, 若需要在此執行等待操作, 可以在此回傳Future, 當[waitCurrentEnd]為true時有效
  @override
  Future<void> previous({
    bool waitCurrentEnd = true,
    bool currentEndWithAnimation = true,
    FutureCallback? onCurrentEndComplete,
  }) =>
      _usedController.previous(
        waitCurrentEnd: waitCurrentEnd,
        currentEndWithAnimation: currentEndWithAnimation,
        onCurrentEndComplete: onCurrentEndComplete,
      );

  @override
  bool canPrevious() => _usedController.canPrevious();

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
