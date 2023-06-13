import 'package:mx_novice_guide/model/guide_step.dart';
import 'package:mx_novice_guide/widget/novice_guide.dart';

abstract class NoviceGuideController {
  static NoviceGuideController create() => NoviceGuideControllerImpl();

  /// 是否正在顯示中
  bool get isShowing;

  /// 當前的步驟index
  int? get currentStepIndex;

  /// 當前的步驟
  GuideStep? get currentStep;

  Future<void> finish();

  Future<void> next();

  Future<void> previous();

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
  Future<void> next() async {
    if (_client == null) {
      return;
    }
    return _client!.next();
  }

  @override
  Future<void> previous() async {
    if (_client == null) {
      return;
    }
    return _client!.previous();
  }

  @override
  bool canNext() => _client?.canNext() ?? false;

  @override
  bool canPrevious() => _client?.canPrevious() ?? false;

  void dispose() {
    _client = null;
  }
}
