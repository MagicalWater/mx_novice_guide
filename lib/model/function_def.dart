import 'package:flutter/material.dart';

import '../widget/novice_guide.dart';
import 'controller.dart';

/// 單個target的說明元件構建
/// [targetRect] - 此Target的區塊, 且目標target的rect已經可以獲取到
/// [allRect] - 此步驟中, 所有target的區塊, 其餘target的rect可能尚未獲取到
typedef SingleDescContentBuilder = Widget Function(
  BuildContext context,
  NoviceGuideController controller,
  TargetRectGetter targetRect,
  List<TargetRectGetter> allRect,
);

/// 綜合target的說明元件構建
/// [allRect] - 此步驟中, 所有target的區塊, 且所有target的rect已經可以獲取到
typedef MultiDescContentBuilder = Widget Function(
  BuildContext context,
  NoviceGuideController controller,
  List<TargetRectGetter> allRect,
);

/// 目標佔位構建 (放置於目標的上方)
typedef TargetPlaceBuilder = Widget Function(
  BuildContext context,
  NoviceGuideController controller,
  TargetRectGetter targetRect,
);
