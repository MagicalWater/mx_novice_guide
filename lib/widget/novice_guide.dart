import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mx_novice_guide/paint/focus_painter.dart';

import '../mx_novice_guide.dart';

part 'target_rect_getter.dart';

const _tag = '[MxNoviceGuide]';

class NoviceGuide extends StatefulWidget {
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

  final bool rootOverlay;

  final NoviceGuideController controller;

  /// 流程結束
  final VoidCallback? onFinish;

  const NoviceGuide({
    super.key,
    required this.count,
    required this.builder,
    required this.controller,
    this.targetPadding,
    this.skipWidget,
    this.skipAlign = Alignment.topRight,
    this.skipMargin,
    this.maskColor,
    this.pulseEnable = true,
    this.rootOverlay = false,
    this.onFinish,
  });

  @override
  State<NoviceGuide> createState() => NoviceGuideState();
}

class NoviceGuideState extends State<NoviceGuide>
    with TickerProviderStateMixin
    implements NoviceGuideController {
  /// 當前步驟, 當-1時代表沒有正在顯示的步驟
  int _currentStepIndex = -1;

  /// 是否為首次進入
  bool _isFirstShow = true;

  /// 當前步驟的相關參數
  GuideStep? _currentStep;

  /// 高亮的區塊Rect獲取
  final _focusRect = <TargetRectGetter>[];

  /// 實際展示的target與Rect
  // final displayRect = <FocusTarget, FocusRect>{};

  /// 脈衝動畫控制
  // late AnimationController _pulseController;
  // late Animation _tweenPulse;

  @override
  void initState() {
    super.initState();
    _currentStepIndex = -1;
    _bindController(
      oldController: null,
      currentController: widget.controller,
    );
    next();
  }

  @override
  void didUpdateWidget(covariant NoviceGuide oldWidget) {
    _bindController(
      oldController: oldWidget.controller,
      currentController: widget.controller,
    );
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    (widget.controller as NoviceGuideControllerImpl).dispose();
    super.dispose();
  }

  void _bindController({
    required NoviceGuideController? oldController,
    required NoviceGuideController currentController,
  }) {
    if (oldController != currentController) {
      if (oldController != null) {
        (oldController as NoviceGuideControllerImpl).dispose();
      }
      (currentController as NoviceGuideControllerImpl).attach(this);
    }
  }

  /// 同步需要展示的元件
  void _syncDisplay() {
    // 取得當下index對應的區塊
    _currentStep = widget.builder(context, _currentStepIndex);
    final targetsRect = _currentStep!.targets.map((e) {
      return TargetRectGetter(
        target: e,
        animationVsync: this,
        onRectGet: (rect) {
          if (mounted) {
            setState(() {});
          }
          // displayRect[e] = rect;
        },
        rootOverlay: widget.rootOverlay,
      );
    });
    _focusRect.addAll(targetsRect);

    for (var element in _focusRect) {
      element._startGetRect();
    }
  }

  /// 關閉當前高亮區塊
  Future<void> _endFocus() async {
    final endRectFuture = _focusRect.map((e) => e.endRect());
    await Future.wait(endRectFuture);

    for (var element in _focusRect) {
      element.endRect();
    }

    _focusRect.clear();
  }

  @override
  Widget build(BuildContext context) {
    final stepDesc = _currentStep?.descBuilder;
    final skipWidget = _currentStep?.skip ?? widget.skipWidget;
    final skipMargin = _currentStep?.skipMargin ?? widget.skipMargin;
    final skipShow = _currentStep?.skipEnable ?? false;
    final skipAlign = _currentStep?.skipAlign ?? widget.skipAlign;
    final effectiveTarget =
        _focusRect.where((element) => element.displayRect != null);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          // 顯示高亮區塊
          SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: CustomPaint(
              painter: FocusPainter(
                targets: effectiveTarget,
                maskColor: _currentStep?.maskColor ?? widget.maskColor,
              ),
            ),
          ),

          if (_currentStep?.onTapSpace != null)
            GestureDetector(
              onTap: () {
                _currentStep?.onTapSpace?.call(widget.controller);
              },
            ),

          // 若高亮區塊展示出來, 也需要構建content
          if (stepDesc != null)
            AnimatedOpacity(
              opacity: _focusRect.isEmpty
                  ? 0
                  : _focusRect.map((e) => e.progress).reduce(min),
              duration: const Duration(milliseconds: 300),
              child: _buildMultiDesc(stepDesc),
            )
          else
            ..._focusRect.map((element) {
              return AnimatedOpacity(
                opacity: element.progress,
                duration: const Duration(milliseconds: 300),
                child: _buildSingleDesc(element),
              );
            }),

          // 高亮區塊加入隱形的點擊範圍
          ...effectiveTarget
              .where((element) => element.target.targetPlaceBuilder != null)
              .map((element) {
            return element.target.targetPlaceBuilder!(
              context,
              widget.controller,
              element,
            );
          }),

          if (skipShow)
            _buildSkip(
              align: skipAlign,
              skipWidget: skipWidget,
              skipMargin: skipMargin,
            ),
        ],
      ),
    );
  }

  Widget _buildMultiDesc(MultiDescContentBuilder builder) {
    // 所有內容的元件是否皆以構建好
    final isAllTargetReady =
        !_focusRect.any((element) => element.oriRect == null);

    // print('混合desc是否已經準備好 => $isAllTargetReady');

    if (!isAllTargetReady) {
      return const SizedBox.shrink();
    }

    return builder(context, widget.controller, _focusRect);
  }

  Widget _buildSingleDesc(TargetRectGetter targetRect) {
    if (targetRect.target.descBuilder == null || targetRect.oriRect == null) {
      return const SizedBox.shrink();
    }

    return targetRect.target.descBuilder!(
        context, widget.controller, targetRect, _focusRect);
  }

  Widget _buildSkip({
    required AlignmentGeometry align,
    required Widget? skipWidget,
    required EdgeInsetsGeometry? skipMargin,
  }) {
    return SafeArea(
      child: Align(
        alignment: align,
        child: Padding(
          padding: skipMargin ?? EdgeInsets.zero,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              finish();
            },
            child: skipWidget,
          ),
        ),
      ),
    );
  }

  @override
  Future<void> next() async {
    await _endFocus();

    if (!canNext()) {
      if (kDebugMode) {
        print('$_tag - 教學結束');
      }
      finish();
      return;
    }

    _currentStepIndex++;

    if (_currentStepIndex != 0 && _isFirstShow) {
      _isFirstShow = false;
    }

    if (!mounted) {
      return;
    }

    _syncDisplay();
  }

  @override
  Future<void> previous() async {
    if (!canPrevious()) {
      if (kDebugMode) {
        print('$_tag - 沒有上一步了');
      }
      return;
    }

    await _endFocus();
    _currentStepIndex--;

    if (!mounted) {
      return;
    }

    _syncDisplay();
  }

  @override
  bool canNext() {
    return _currentStepIndex < widget.count - 1;
  }

  @override
  bool canPrevious() {
    return _currentStepIndex > 0;
  }

  @override
  Future<void> finish() async {
    _currentStepIndex = -1;
    await _endFocus();
    widget.onFinish?.call();
  }

  /// 是否正在顯示教學中
  @override
  bool get isShowing => _currentStepIndex != -1;

  @override
  GuideStep? get currentStep => _currentStep;

  @override
  int? get currentStepIndex =>
      _currentStepIndex != -1 ? _currentStepIndex : null;
}
