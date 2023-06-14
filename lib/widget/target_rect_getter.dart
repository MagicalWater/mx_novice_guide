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

  /// 顯示進度
  double get progress => _progress;

  final ValueChanged<FocusRect> onRectGet;

  late Animation _animation;

  TargetRectGetter({
    required this.target,
    required TickerProvider animationVsync,
    required this.onRectGet,
    this.rootOverlay = false,
  }) {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: animationVsync,
    );

    final curveAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastLinearToSlowEaseIn,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(curveAnimation);
    _animation.addListener(_syncRect);
  }

  /// 同步_oriRect到displayRect
  void _syncRect() {
    if (_oriRect != null) {
      _progress = _controller.value;
      final width = _oriRect!.width * _animation.value;
      final height = _oriRect!.height * _animation.value;
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
  void _startGetRect() {
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
  TickerFuture endRect({
    bool withAnimation = true,
  }) {
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
        if (rect != null) {
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
    _animation.removeListener(_syncRect);
    _controller.dispose();
  }
}
