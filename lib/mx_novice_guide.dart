import 'package:flutter/material.dart';
import 'package:mx_novice_guide/model/focus_target.dart';

import 'model/controller.dart';
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

  @override
  Future<void> next() => _usedController.next();

  @override
  bool canNext() => _usedController.canNext();

  @override
  Future<void> previous() => _usedController.previous();

  @override
  bool canPrevious() => _usedController.canPrevious();

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
