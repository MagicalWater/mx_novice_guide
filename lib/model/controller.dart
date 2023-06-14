import 'dart:async';

import 'package:mx_novice_guide/model/guide_step.dart';
import 'package:mx_novice_guide/widget/novice_guide.dart';

typedef FutureCallback = FutureOr Function();

abstract class NoviceGuideController {
  static NoviceGuideController create() => NoviceGuideControllerImpl();

  /// 是否正在顯示中
  bool get isShowing;

  /// 當前的步驟index
  int? get currentStepIndex;

  /// 當前的步驟
  GuideStep? get currentStep;

  Future<void> finish();

  /// [waitCurrentEnd] - 是否等待當前步驟關閉後再跳下個步驟
  /// [currentEndWithAnimation] - 關閉當前步驟是否有動畫
  /// [onCurrentEndComplete] -
  ///         當前步驟完全關閉後回調, 若需要在此執行等待操作, 可以在此回傳Future, 當[waitCurrentEnd]為true時有效
  Future<void> next({
    bool waitCurrentEnd = true,
    bool currentEndWithAnimation = true,
    FutureCallback? onCurrentEndComplete,
  });

  /// [waitCurrentEnd] - 是否等待當前步驟關閉後再跳上個步驟
  /// [currentEndWithAnimation] - 關閉當前步驟是否有動畫
  /// [onCurrentEndComplete] -
  ///         當前步驟完全關閉後回調, 若需要在此執行等待操作, 可以在此回傳Future, 當[waitCurrentEnd]為true時有效
  Future<void> previous({
    bool waitCurrentEnd = true,
    bool currentEndWithAnimation = true,
    FutureCallback? onCurrentEndComplete,
  });

  bool canNext();

  bool canPrevious();
}

class NoviceGuideControllerImpl implements NoviceGuideController {
  NoviceGuideState? _client;

  void attach(NoviceGuideState state) {
    _client = state;
  }

  @override
  bool get isShowing => _client?.isShowing ?? false;

  /// 當前的步驟index
  @override
  int? get currentStepIndex => _client?.currentStepIndex;

  /// 當前的步驟
  @override
  GuideStep? get currentStep => _client?.currentStep;

  @override
  Future<void> finish() async {
    if (_client == null) {
      return;
    }
    return _client!.finish();
  }

  @override
  Future<void> next({
    bool waitCurrentEnd = true,
    bool currentEndWithAnimation = true,
    FutureCallback? onCurrentEndComplete,
  }) async {
    if (_client == null) {
      return;
    }
    return _client!.next(
      waitCurrentEnd: waitCurrentEnd,
      currentEndWithAnimation: currentEndWithAnimation,
      onCurrentEndComplete: onCurrentEndComplete,
    );
  }

  @override
  Future<void> previous({
    bool waitCurrentEnd = true,
    bool currentEndWithAnimation = true,
    FutureCallback? onCurrentEndComplete,
  }) async {
    if (_client == null) {
      return;
    }
    return _client!.previous(
      waitCurrentEnd: waitCurrentEnd,
      currentEndWithAnimation: currentEndWithAnimation,
      onCurrentEndComplete: onCurrentEndComplete,
    );
  }

  @override
  bool canNext() => _client?.canNext() ?? false;

  @override
  bool canPrevious() => _client?.canPrevious() ?? false;

  void dispose() {
    _client = null;
  }
}
