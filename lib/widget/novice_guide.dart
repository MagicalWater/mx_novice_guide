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

  /// 預設[FocusTarget.animationDuration]鎖定target時的動畫時間
  final Duration animationDuration;

  /// 預設[FocusTarget.animationType]鎖定目標的方式
  final FocusAnimationType animationType;

  /// 預設[FocusTarget.animationCurve]鎖定動畫差值器
  final Curve animationCurve;

  final bool pulseEnable;

  final bool rootOverlay;

  final NoviceGuideController controller;

  /// 流程結束
  final VoidCallback? onFinish;

  /// 是否自動開始第一個步驟
  final bool autoStart;

  /// 自動開始延遲時間
  final Duration? autoStartDelay;

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
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationType = FocusAnimationType.targetCenter,
    this.animationCurve = Curves.fastOutSlowIn,
    this.pulseEnable = true,
    this.rootOverlay = false,
    this.onFinish,
    this.autoStart = true,
    this.autoStartDelay = const Duration(milliseconds: 300),
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

  /// 當下使用的[animationType]
  late FocusAnimationType _usedAnimationType;

  /// 實際展示的target與Rect
  // final displayRect = <FocusTarget, FocusRect>{};

  /// 脈衝動畫控制
  // late AnimationController _pulseController;
  // late Animation _tweenPulse;

  /// 當前是否為把focus釋放的時期
  /// 通常發生在呼叫next/previous的endFocus之後, 在syncDisplay之前
  /// 在此之間不會有任何的_focusRect
  bool isFocusRelease = true;

  @override
  void initState() {
    super.initState();
    _currentStepIndex = -1;
    _usedAnimationType = widget.animationType;
    _bindController(
      oldController: null,
      currentController: widget.controller,
    );
    if (widget.autoStart) {
      final delay = widget.autoStartDelay;
      if (delay != null) {
        Future.delayed(delay).then((value) {
          if (!mounted) {
            next();
          }
        });
      } else {
        next();
      }
    }
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

  /// 取得某個步驟的Rect Getter
  NextStepInfo getTargetRectGetter(
    int stepIndex,
  ) {
    final step = widget.builder(context, stepIndex);

    final rectGetter = step.targets.map((e) {
      return TargetRectGetter(
        target: e,
        animationVsync: this,
        defaultAnimationDuration: widget.animationDuration,
        defaultAnimationType: widget.animationType,
        defaultAnimationCurve: widget.animationCurve,
        onRectGet: (rect) {
          if (mounted) {
            setState(() {});
          }
          // displayRect[e] = rect;
        },
        rootOverlay: widget.rootOverlay,
      );
    });

    FocusAnimationType? animationType;

    if (rectGetter.isEmpty) {
      animationType = widget.animationType;
    } else {
      if (rectGetter.any((element) => element.animationType.isScreen)) {
        animationType = FocusAnimationType.screen;
      } else {
        animationType = FocusAnimationType.targetCenter;
      }
    }

    return NextStepInfo(
      step: step,
      rectGetter: rectGetter,
      animationType: animationType,
    );
  }

  /// 同步需要展示的元件
  void _syncDisplay(NextStepInfo stepInfo) {
    // 取得當下index對應的區塊
    _currentStep = stepInfo.step;
    _focusRect.addAll(stepInfo.rectGetter);
    _usedAnimationType = stepInfo.animationType;

    for (var element in _focusRect) {
      element._startGetRect(context);
    }

    isFocusRelease = false;
  }

  /// 關閉當前高亮區塊
  /// [nextAnimationType] 結束展示後, 下一個過度動畫的類型
  Future<void> _endFocus({
    bool withAnimation = true,
    FocusAnimationType? nextAnimationType,
  }) async {
    final endRectFuture = _focusRect.map((e) => e.endRect(
          withAnimation: withAnimation,
          nextAnimationType: nextAnimationType,
        ));
    await Future.wait(endRectFuture);
    _focusRect.clear();
    isFocusRelease = true;
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
                usedAnimationType: _usedAnimationType,
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
            Opacity(
              opacity: _focusRect.isEmpty
                  ? 0
                  : _focusRect.map((e) => e._descProgress).reduce(min),
              child: _buildMultiDesc(stepDesc),
            )
          else
            ..._focusRect.map((element) {
              return Opacity(
                opacity: element._descProgress,
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

    if (!isAllTargetReady || isFocusRelease) {
      return const SizedBox.shrink();
    }

    return builder(context, widget.controller, _focusRect);
  }

  Widget _buildSingleDesc(TargetRectGetter targetRect) {
    if (targetRect.target.descBuilder == null || targetRect.oriRect == null) {
      return const SizedBox.shrink();
    }

    return targetRect.target.descBuilder!(
      context,
      widget.controller,
      targetRect,
      _focusRect,
    );
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

  /// [waitCurrentEnd] - 是否等待當前步驟關閉後再跳下個步驟
  /// [currentEndWithAnimation] - 關閉當前步驟是否有動畫
  /// [onCurrentEndComplete] - 當前步驟完全關閉後回調
  @override
  Future<void> next({
    bool waitCurrentEnd = true,
    bool currentEndWithAnimation = true,
    FutureCallback? onCurrentEndComplete,
  }) async {
    NextStepInfo? nextStep;

    if (canNext()) {
      // 取得下一個步驟的動畫類型
      nextStep = getTargetRectGetter(_currentStepIndex + 1);
    }

    _usedAnimationType = nextStep?.animationType ?? widget.animationType;

    if (waitCurrentEnd) {
      await _endFocus(
        withAnimation: currentEndWithAnimation,
        nextAnimationType: nextStep?.animationType,
      );
      await onCurrentEndComplete?.call();
    } else {
      _endFocus(
        withAnimation: currentEndWithAnimation,
        nextAnimationType: nextStep?.animationType,
      ).then((value) {
        onCurrentEndComplete?.call();
      });
    }

    if (!canNext() || nextStep == null) {
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

    _syncDisplay(nextStep);
  }

  /// [waitCurrentEnd] - 是否等待當前步驟關閉後再跳上個步驟
  /// [currentEndWithAnimation] - 關閉當前步驟是否有動畫
  /// [onCurrentEndComplete] - 當前步驟完全關閉後回調
  @override
  Future<void> previous({
    bool waitCurrentEnd = true,
    bool currentEndWithAnimation = true,
    FutureCallback? onCurrentEndComplete,
  }) async {
    NextStepInfo? prevStep;

    if (canPrevious()) {
      // 取得下一個步驟的動畫類型
      prevStep = getTargetRectGetter(_currentStepIndex - 1);
    }

    _usedAnimationType = prevStep?.animationType ?? widget.animationType;

    if (!canPrevious() || prevStep == null) {
      if (kDebugMode) {
        print('$_tag - 沒有上一步了');
      }
      return;
    }

    if (waitCurrentEnd) {
      await _endFocus(
        withAnimation: currentEndWithAnimation,
        nextAnimationType: prevStep.animationType,
      );
      await onCurrentEndComplete?.call();
    } else {
      _endFocus(
        withAnimation: currentEndWithAnimation,
        nextAnimationType: prevStep.animationType,
      ).then((value) {
        onCurrentEndComplete?.call();
      });
    }
    _currentStepIndex--;

    if (!mounted) {
      return;
    }

    _syncDisplay(prevStep);
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

class NextStepInfo {
  final GuideStep step;
  final Iterable<TargetRectGetter> rectGetter;
  final FocusAnimationType animationType;

  NextStepInfo({
    required this.step,
    required this.rectGetter,
    required this.animationType,
  });
}
