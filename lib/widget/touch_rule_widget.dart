import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 點擊規則
enum TouchRule {
  /// 全部穿透
  allThrough,

  /// 檢測範圍穿透, 其餘攔截
  otherIntercept,

  /// 檢測範圍攔截, 其餘範圍穿透
  detectIntercept,

  /// 完全不穿透, 點擊事件完全攔截
  allIntercept,
}

/// 可套用觸摸規則的元件
/// [rule] - 觸摸規則, 當是 [HitRule.childIntercept] 時, 需要搭配子元件[TouchDetectWidget]使用
class TouchRuleWidget extends SingleChildRenderObjectWidget {
  final TouchRule rule;

  const TouchRuleWidget({
    Key? key,
    Widget? child,
    required this.rule,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TouchRuleBox(rule: rule);
  }
}

class TouchRuleBox extends RenderShiftedBox {
  final TouchRule rule;

  TouchRuleBox({
    RenderBox? child,
    required this.rule,
  }) : super(child);

  @override
  void performLayout() {
    child?.layout(constraints, parentUsesSize: false);
    size = Size(
      constraints.maxWidth,
      constraints.maxHeight,
    );
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!hasSize) {
      // 如果尚未有 size, 依照正常會拋出錯誤
      // 這邊不處理直接往上丟
      return super.hitTest(result, position: position);
    }

    // 我們要處理除了目標之外的所有點擊, 目標是點擊穿透
//    print('是否接受點擊: $position');

    switch (rule) {
      case TouchRule.allThrough:
        // 完全穿透
        return false;
      case TouchRule.otherIntercept:
        // 檢測範圍穿透, 其餘攔截
        if (child!.size.contains(position)) {
          // 在子元件範圍
          // 檢查結果列表是否包含 TouchDetectBox
          super.hitTest(result, position: position);
          final isDetected = result.path
              .whereType<BoxHitTestEntry>()
              .any((e) => e.target is TouchDetectBox);
//          print("是否包含需要檢測的子元件: $isDetected");
          if (isDetected) {
            // 檢測範圍抓到了, 但因為需要穿透, 因此需要清除並回傳不處理
            (result.path as List).clear();
            return false;
          } else {
            return true;
          }
        }
        return false;
      case TouchRule.detectIntercept:
        // 檢測範圍攔截, 其餘穿透
        if (child!.size.contains(position)) {
          // 在子元件範圍
          // 檢查結果列表是否包含 TouchDetectBox
          final resultHandle = super.hitTest(result, position: position);
          final isDetected = result.path
              .whereType<BoxHitTestEntry>()
              .any((e) => e.target is TouchDetectBox);
//          print("是否包含需要檢測的元件: $isDetected");
          if (isDetected) {
            return resultHandle;
          } else {
            (result.path as List).clear();
//            print("清除結果: ${result.path.length}");
            return false;
          }
        }
        return false;
      case TouchRule.allIntercept:
        // 完全攔截
        return super.hitTest(result, position: position);
    }
  }
}

/// 觸摸範圍檢測
class TouchDetectWidget extends SingleChildRenderObjectWidget {
  const TouchDetectWidget({
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return TouchDetectBox(null);
  }
}

class TouchDetectBox extends RenderShiftedBox {
  TouchDetectBox(RenderBox? child) : super(child);

  @override
  void performLayout() {
    child?.layout(constraints, parentUsesSize: false);
    size = Size(
      constraints.maxWidth,
      constraints.maxHeight,
    );
  }
}
