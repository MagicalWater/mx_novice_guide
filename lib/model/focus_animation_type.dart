/// 鎖定焦點的過渡動畫類型
enum FocusAnimationType {
  /// 由目標中心點逐漸放大
  targetCenter,

  /// 由整個視窗逐漸縮小
  screen,
}

extension FocusAnimationTypeValue on FocusAnimationType {
  bool get isTargetCenter => this == FocusAnimationType.targetCenter;

  bool get isScreen => this == FocusAnimationType.screen;
}
