import 'package:flutter/material.dart';

import 'model.dart';

/// 引導步驟
class GuideStep {
  final dynamic identify;

  /// 引導目標
  final List<FocusTarget> targets;

  /// 綜合目標的說明元件
  /// 與[FocusTarget.descBuilder]差異在於當接收到構建請求時, 代表所有target的rect都已經獲取完成
  /// 若有多個目標且排版上有相互關聯時, 使用此值會更加方便
  /// 此值優先於[FocusTarget.descBuilder], 當給定值時, [FocusTarget.descBuilder]將會失效
  final MultiDescContentBuilder? descBuilder;

  /// 遮罩顏色
  final Color? maskColor;

  /// skip 元件
  final Widget? skip;

  /// skip 對齊位置
  final AlignmentGeometry? skipAlign;

  /// 是否啟用skip
  final bool skipEnable;

  /// skip 元件與外框距離
  final EdgeInsetsGeometry? skipMargin;

  /// 點在空白處
  final void Function(NoviceGuideController controller)? onTapSpace;

  GuideStep({
    this.identify,
    required this.targets,
    this.descBuilder,
    this.maskColor,
    this.skip,
    this.skipAlign,
    this.skipEnable = true,
    this.skipMargin,
    this.onTapSpace,
  });
}
