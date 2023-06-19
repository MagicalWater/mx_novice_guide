part of 'novice_guide.dart';

/// 獲取target的高亮區塊
class TargetRectGetter {
  final FocusTarget target;

  late AnimationController _controller;

  final bool rootOverlay;

  /// 輪詢獲取Rect
  Timer? _periodTimer;

  /// Rect
  RRect? _oriRect;

  /// 原始Rect
  RRect? get oriRect => _oriRect;

  /// 顯示的rect, 與[_oriRect]不同在於此rect有動畫過度
  RRect? _displayRect;

  /// 顯示的rect
  RRect? get displayRect => _displayRect;

  /// 顯示進度
  double _progress = 0;

  /// desc顯示進度
  double _descProgress = 0;

  /// 顯示進度
  double get progress => _progress;

  /// desc的顯示進度
  double get descProgress => _descProgress;

  final ValueChanged<FocusRect> onRectGet;

  late Animation<double> _progressCenterAnimation;

  late Animation<double> _progressScreenAnimation;

  late Animation<double> _descAnimation;

  Size? screenSize;

  /// 鎖定目標的方式, 預設為[FocusAnimationType.targetCenter]
  final FocusAnimationType animationType;

  /// 當前是否正在向前執行動畫
  bool _isAnimationForward = false;

  /// 當正在執行取消focus動畫時, 以此表明下一個步驟的過度動畫類型
  FocusAnimationType? _nextAnimationType;

  TargetRectGetter({
    required this.target,
    required TickerProvider animationVsync,
    required this.onRectGet,
    required Duration defaultAnimationDuration,
    required FocusAnimationType defaultAnimationType,
    required Curve defaultAnimationCurve,
    this.rootOverlay = false,
  }) : animationType = target.animationType ?? defaultAnimationType {
    _controller = AnimationController(
      duration: target.animationDuration ?? defaultAnimationDuration,
      vsync: animationVsync,
    );

    final curveAnimation = CurvedAnimation(
      parent: _controller,
      curve: target.animationCurve ?? defaultAnimationCurve,
    );

    _progressCenterAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(curveAnimation);

    _progressScreenAnimation = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(curveAnimation);

    _descAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInQuint,
    );

    _controller.addListener(_syncRect);
  }

  /// 同步_oriRect到displayRect
  void _syncRect() {
    if (_oriRect != null) {
      _progress = _controller.value;
      _descProgress = _descAnimation.value;

      double width, height;

      final type = _isAnimationForward
          ? animationType
          : (_nextAnimationType ?? animationType);
      switch (type) {
        case FocusAnimationType.screen:
          final maxWidthDistance = [
            oriRect!.left * 2,
            (screenSize!.width - oriRect!.right) * 2,
            screenSize!.width,
          ].reduce(max);

          final maxHeightDistance = [
            oriRect!.top * 2,
            (screenSize!.height - oriRect!.bottom) * 2,
            screenSize!.height,
          ].reduce(max);

          width = _oriRect!.width +
              (maxWidthDistance * _progressScreenAnimation.value);
          height = _oriRect!.height +
              (maxHeightDistance * _progressScreenAnimation.value);
          break;
        case FocusAnimationType.targetCenter:
          width = _oriRect!.width * _progressCenterAnimation.value;
          height = _oriRect!.height * _progressCenterAnimation.value;
          break;
      }

      final rect = Rect.fromCenter(
        center: _oriRect!.center,
        width: width,
        height: height,
      );
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: _oriRect!.tlRadius,
        topRight: _oriRect!.trRadius,
        bottomLeft: _oriRect!.blRadius,
        bottomRight: _oriRect!.brRadius,
      );
      _displayRect = rrect;
      onRectGet(FocusRect(
        real: _oriRect!,
        display: rrect,
      ));
    }
  }

  /// 開始獲取rect
  void _startGetRect(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    final rect = target.getTargetRect(rootOverlay: rootOverlay);
    if (rect != null) {
      _oriRect = rect;
      _startAnimRect();
      _startTimerGetRect();
    } else {
      _startTimerGetRect();
    }
  }

  /// 結束展示
  /// [nextAnimationType] 結束展示後, 下一個過度動畫的類型
  TickerFuture endRect({
    bool withAnimation = true,
    FocusAnimationType? nextAnimationType,
  }) {
    _isAnimationForward = false;
    _nextAnimationType = nextAnimationType;
    _stopTimer();
    if (withAnimation) {
      return _controller.reverse();
    } else {
      _controller.reset();
      return TickerFuture.complete();
    }
  }

  void _startTimerGetRect() {
    _stopTimer();
    _periodTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        final rect = target.getTargetRect(rootOverlay: rootOverlay);
        if (rect != null && _oriRect != rect) {
          _oriRect = rect;
          if (_controller.status == AnimationStatus.dismissed) {
            _startAnimRect();
          } else {
            _syncRect();
          }
        }
      },
    );
  }

  /// 啟動區塊動畫
  void _startAnimRect() {
    _isAnimationForward = true;
    _controller.forward();
  }

  void _stopTimer() {
    if (_periodTimer != null && _periodTimer!.isActive) {
      _periodTimer?.cancel();
    }
    _periodTimer = null;
  }

  void dispose() {
    _stopTimer();
    _controller.removeListener(_syncRect);
    _controller.dispose();
  }
}
