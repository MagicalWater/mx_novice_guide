// import 'dart:async';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:tutorial_coach_mark/src/paint/light_paint.dart';
// import 'package:tutorial_coach_mark/src/paint/light_paint_rect.dart';
// import 'package:tutorial_coach_mark/src/target/target_focus.dart';
// import 'package:tutorial_coach_mark/src/target/target_position.dart';
// import 'package:tutorial_coach_mark/src/util.dart';
//
// import '../paint/light_tappable_paint.dart';
// import '../paint/light_tappable_paint_rect.dart';
//
// class AnimatedFocusLight extends StatefulWidget {
//   final List<TargetFocus> targets;
//   final Function(TargetFocus)? focus;
//   final FutureOr Function(TargetFocus)? clickTarget;
//   final FutureOr Function(TargetFocus, TapDownDetails)?
//       clickTargetWithTapPosition;
//   final FutureOr Function(TargetFocus)? clickOverlay;
//   final Function? removeFocus;
//   final Function()? finish;
//   final double paddingFocus;
//   final Color colorShadow;
//   final double opacityShadow;
//   final Duration? focusAnimationDuration;
//   final Duration? unFocusAnimationDuration;
//   final Duration? pulseAnimationDuration;
//   final Tween<double>? pulseVariation;
//   final bool pulseEnable;
//   final bool rootOverlay;
//
//   const AnimatedFocusLight({
//     Key? key,
//     required this.targets,
//     this.focus,
//     this.finish,
//     this.removeFocus,
//     this.clickTarget,
//     this.clickTargetWithTapPosition,
//     this.clickOverlay,
//     this.paddingFocus = 10,
//     this.colorShadow = Colors.black,
//     this.opacityShadow = 0.8,
//     this.focusAnimationDuration,
//     this.unFocusAnimationDuration,
//     this.pulseAnimationDuration,
//     this.pulseVariation,
//     this.pulseEnable = true,
//     this.rootOverlay = false,
//   })  : assert(targets.length > 0),
//         super(key: key);
//
//   @override
//   // ignore: no_logic_in_create_state
//   AnimatedFocusLightState createState() => pulseEnable
//       ? AnimatedPulseFocusLightState()
//       : AnimatedStaticFocusLightState();
// }
//
// abstract class AnimatedFocusLightState extends State<AnimatedFocusLight>
//     with TickerProviderStateMixin {
//   final borderRadiusDefault = 10.0;
//   final defaultFocusAnimationDuration = const Duration(milliseconds: 600);
//   late AnimationController _controller;
//   late CurvedAnimation _curvedAnimation;
//
//   late TargetFocus _targetFocus;
//   Offset _positioned = const Offset(0.0, 0.0);
//   Offset? _tappablePositioned;
//   TargetPosition? _targetPosition, _tappablePosition;
//
//   double _sizeCircle = 100;
//   double? _tappableSizeCircle;
//   int _currentFocus = 0;
//   double _progressAnimated = 0;
//   double _staticProgressAnimated = 0;
//   bool _goNext = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _targetFocus = widget.targets[_currentFocus];
//     _controller = AnimationController(
//       vsync: this,
//       duration: _targetFocus.focusAnimationDuration ??
//           widget.focusAnimationDuration ??
//           defaultFocusAnimationDuration,
//     )..addStatusListener(_listener);
//
//     _curvedAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.ease,
//     );
//
//     Future.delayed(Duration.zero, _runFocus);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void next() => _tapHandler();
//
//   void previous() => _tapHandler(goNext: false);
//
//   Future _tapHandler({
//     bool goNext = true,
//     bool targetTap = false,
//     bool overlayTap = false,
//   }) async {
//     if (targetTap) {
//       await widget.clickTarget?.call(_targetFocus);
//     }
//     if (overlayTap) {
//       await widget.clickOverlay?.call(_targetFocus);
//     }
//   }
//
//   Future _tapHandlerForPosition(TapDownDetails tapDetails) async {
//     await widget.clickTargetWithTapPosition?.call(_targetFocus, tapDetails);
//   }
//
//   void _runFocus() {
//     if (_currentFocus < 0) return;
//     _targetFocus = widget.targets[_currentFocus];
//
//     _controller.duration = _targetFocus.focusAnimationDuration ??
//         widget.focusAnimationDuration ??
//         defaultFocusAnimationDuration;
//
//     TargetPosition? targetPosition, tappablePosition;
//     try {
//       targetPosition = getTargetCurrent(
//         _targetFocus,
//         rootOverlay: widget.rootOverlay,
//       );
//       tappablePosition = getTappableCurrent(
//         _targetFocus,
//         rootOverlay: widget.rootOverlay,
//       );
//     } on NotFoundTargetException catch (e, s) {
//       debugPrint(e.toString());
//       debugPrintStack(stackTrace: s);
//     }
//
//     if (targetPosition == null) {
//       _finish();
//       return;
//     }
//
//     safeSetState(() {
//       _targetPosition = targetPosition!;
//       _tappablePosition = tappablePosition;
//
//       _positioned = Offset(
//         targetPosition.offset.dx + (targetPosition.size.width / 2),
//         targetPosition.offset.dy + (targetPosition.size.height / 2),
//       );
//       if (tappablePosition == null) {
//         _tappablePositioned = null;
//       } else {
//         _tappablePositioned = Offset(
//           tappablePosition.offset.dx + (tappablePosition.size.width / 2),
//           tappablePosition.offset.dy + (tappablePosition.size.height / 2),
//         );
//       }
//
//       if (targetPosition.size.height > targetPosition.size.width) {
//         _sizeCircle = targetPosition.size.height * 0.6 + _getPaddingFocus();
//         if (tappablePosition != null) {
//           _tappableSizeCircle =
//               tappablePosition.size.height * 0.6 + _getTappablePaddingFocus();
//         } else {
//           _tappableSizeCircle = null;
//         }
//       } else {
//         _sizeCircle = targetPosition.size.width * 0.6 + _getPaddingFocus();
//         if (tappablePosition != null) {
//           _tappableSizeCircle =
//               tappablePosition.size.width * 0.6 + _getTappablePaddingFocus();
//         } else {
//           _tappableSizeCircle = null;
//         }
//       }
//     });
//
//     _controller.forward();
//     _controller.duration = _targetFocus.unFocusAnimationDuration ??
//         widget.unFocusAnimationDuration ??
//         _targetFocus.focusAnimationDuration ??
//         widget.focusAnimationDuration ??
//         defaultFocusAnimationDuration;
//   }
//
//   void _nextFocus() {
//     if (_currentFocus >= widget.targets.length - 1) {
//       _finish();
//       return;
//     }
//     _currentFocus++;
//
//     _runFocus();
//   }
//
//   void _previousFocus() {
//     if (_currentFocus <= 0) {
//       _finish();
//       return;
//     }
//     _currentFocus--;
//     _runFocus();
//   }
//
//   void _finish() {
//     safeSetState(() => _currentFocus = 0);
//     widget.finish!();
//   }
//
//   void _listener(AnimationStatus status);
//
//   CustomPainter _getPainter(TargetFocus? target) {
//     if (target?.shape == ShapeLightFocus.RRect) {
//       return LightPaintRect(
//         colorShadow: target?.color ?? widget.colorShadow,
//         progress: _progressAnimated,
//         staticProgress: _staticProgressAnimated,
//         offset: _getPaddingFocus(),
//         target: _targetPosition ?? TargetPosition(Size.zero, Offset.zero),
//         tappableTarget: _tappablePosition,
//         radius: target?.radius ?? 0,
//         borderSide: target?.borderSide,
//         opacityShadow: widget.opacityShadow,
//         tappableRadius: target?.tappableRadius ?? 0,
//         tappableBorderSide: target?.tappableBorderSide,
//       );
//     } else {
//       return LightPaint(
//         progress: _progressAnimated,
//         staticProgress: _staticProgressAnimated,
//         positioned: _positioned,
//         tappablePositioned: _tappablePositioned,
//         sizeCircle: _sizeCircle,
//         tappableSizeCircle: _tappableSizeCircle,
//         colorShadow: target?.color ?? widget.colorShadow,
//         borderSide: target?.borderSide,
//         opacityShadow: widget.opacityShadow,
//         tappableBorderSide: target?.tappableBorderSide,
//       );
//     }
//   }
//
//   CustomPainter _getTappablePainter(TargetFocus? target) {
//     if (target?.tappableShape == ShapeLightFocus.RRect) {
//       return LightTappablePaintRect(
//         progress: _progressAnimated,
//         staticProgress: _staticProgressAnimated,
//         offset: _getTappablePaddingFocus(),
//         tappableTarget: _tappablePosition,
//         tappableRadius: target?.tappableRadius ?? 0,
//         tappableBorderSide: target?.tappableBorderSide,
//       );
//     } else {
//       return LightTappablePaint(
//         progress: _progressAnimated,
//         tappablePositioned: _tappablePositioned,
//         tappableSizeCircle: _tappableSizeCircle,
//         tappableBorderSide: target?.tappableBorderSide,
//       );
//     }
//   }
//
//   double _getPaddingFocus() {
//     return _targetFocus.paddingFocus ?? (widget.paddingFocus);
//   }
//
//   double _getTappablePaddingFocus() {
//     return _targetFocus.tappablePaddingFocus ?? (widget.paddingFocus);
//   }
//
//   BorderRadius _betBorderRadiusTarget() {
//     if (_tappablePosition != null) {
//       final isRect = _targetFocus.tappableShape == ShapeLightFocus.RRect;
//       final radius = isRect
//           ? _targetFocus.tappableRadius ?? borderRadiusDefault
//           : max(_tappablePosition?.size.width ?? borderRadiusDefault,
//               _tappablePosition?.size.height ?? borderRadiusDefault);
//       return BorderRadius.circular(radius);
//     } else {
//       final isRect = _targetFocus.shape == ShapeLightFocus.RRect;
//       double radius = isRect
//           ? _targetFocus.radius ?? borderRadiusDefault
//           : _targetPosition?.size.width ?? borderRadiusDefault;
//       return BorderRadius.circular(radius);
//     }
//   }
// }
//
// class AnimatedStaticFocusLightState extends AnimatedFocusLightState {
//   bool get isTappableTarget => _tappablePosition != null;
//
//   bool get isRect {
//     return isTappableTarget
//         ? _targetFocus.tappableShape == ShapeLightFocus.RRect
//         : _targetFocus.shape == ShapeLightFocus.RRect;
//   }
//
//   double get left {
//     if (isRect) {
//       if (_tappablePosition != null) {
//         return _tappablePosition!.offset.dx - _getTappablePaddingFocus();
//       } else if (_targetPosition != null) {
//         return _targetPosition!.offset.dx - _getPaddingFocus();
//       } else {
//         return 0;
//       }
//     } else {
//       if (_tappablePosition != null) {
//         var maxS = max(
//           _tappablePosition!.size.width,
//           _tappablePosition!.size.height,
//         );
//         maxS = maxS * 1.2;
//         return _tappablePosition!.center.dx -
//             (maxS / 2) -
//             _getTappablePaddingFocus();
//       } else if (_targetPosition != null) {
//         var maxS = max(
//           _targetPosition!.size.width,
//           _targetPosition!.size.height,
//         );
//         maxS = maxS * 1.2;
//         return _targetPosition!.center.dx - (maxS / 2) - _getPaddingFocus();
//       } else {
//         return 0;
//       }
//     }
//   }
//
//   double get top {
//     if (isRect) {
//       if (_tappablePosition != null) {
//         return _tappablePosition!.offset.dy - _getTappablePaddingFocus();
//       } else if (_targetPosition != null) {
//         return _targetPosition!.offset.dy - _getPaddingFocus();
//       } else {
//         return 0;
//       }
//     } else {
//       if (_tappablePosition != null) {
//         var maxS = max(
//           _tappablePosition!.size.width,
//           _tappablePosition!.size.height,
//         );
//         maxS = maxS * 1.2;
//         return _tappablePosition!.center.dy -
//             (maxS / 2) -
//             _getTappablePaddingFocus();
//       } else if (_targetPosition != null) {
//         var maxS = max(
//           _targetPosition!.size.width,
//           _targetPosition!.size.height,
//         );
//         maxS = maxS * 1.2;
//         return _targetPosition!.center.dy - (maxS / 2) - _getPaddingFocus();
//       } else {
//         return 0;
//       }
//     }
//   }
//
//   double get width {
//     if (isRect) {
//       if (_tappablePosition != null) {
//         return _tappablePosition!.size.width + _getTappablePaddingFocus() * 2;
//       } else if (_targetPosition != null) {
//         return _targetPosition!.size.width + _getPaddingFocus() * 2;
//       } else {
//         return 0;
//       }
//     } else {
//       if (_tappablePosition != null) {
//         var maxS = max(_tappablePosition?.size.width ?? 0,
//             _tappablePosition?.size.height ?? 0);
//         maxS = maxS * 1.2;
//         return maxS + _getTappablePaddingFocus() * 2;
//       } else if (_targetPosition != null) {
//         var maxS = max(
//           _targetPosition!.size.width,
//           _targetPosition!.size.height,
//         );
//         maxS = maxS * 1.2;
//         return maxS + _getPaddingFocus() * 2;
//       } else {
//         return 0;
//       }
//     }
//   }
//
//   double get height {
//     if (isRect) {
//       if (_tappablePosition != null) {
//         return _tappablePosition!.size.height + _getTappablePaddingFocus() * 2;
//       } else if (_targetPosition != null) {
//         return _targetPosition!.size.height + _getPaddingFocus() * 2;
//       } else {
//         return 0.0;
//       }
//     } else {
//       if (_tappablePosition != null) {
//         var maxS = max(_tappablePosition?.size.width ?? 0,
//             _tappablePosition?.size.height ?? 0);
//         maxS = maxS * 1.2;
//         return maxS + _getTappablePaddingFocus() * 2;
//       } else if (_targetPosition != null) {
//         var maxS = max(
//           _targetPosition!.size.width,
//           _targetPosition!.size.height,
//         );
//         maxS = maxS * 1.2;
//         return maxS + _getPaddingFocus() * 2;
//       } else {
//         return 0;
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: _targetFocus.enableOverlayTab
//           ? () => _tapHandler(overlayTap: true)
//           : null,
//       child: AnimatedBuilder(
//         animation: _controller,
//         builder: (_, child) {
//           _progressAnimated = _curvedAnimation.value;
//           _staticProgressAnimated = _progressAnimated;
//           return Stack(
//             children: <Widget>[
//               SizedBox(
//                 width: double.maxFinite,
//                 height: double.maxFinite,
//                 child: CustomPaint(
//                   painter: _getPainter(_targetFocus),
//                 ),
//               ),
//               SizedBox(
//                 width: double.maxFinite,
//                 height: double.maxFinite,
//                 child: CustomPaint(
//                   painter: _getTappablePainter(_targetFocus),
//                 ),
//               ),
//               Positioned(
//                 left: left,
//                 top: top,
//                 child: InkWell(
//                   borderRadius: _betBorderRadiusTarget(),
//                   onTapDown: _tapHandlerForPosition,
//                   onTap: _targetFocus.enableTargetTab
//                       ? () => _tapHandler(targetTap: true)
//
//                       /// Essential for collecting [TapDownDetails]. Do not make [null]
//                       : () {},
//                   child: Container(
//                     color: Colors.transparent,
//                     width: width,
//                     height: height,
//                   ),
//                 ),
//               )
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   Future _tapHandler({
//     bool goNext = true,
//     bool targetTap = false,
//     bool overlayTap = false,
//   }) async {
//     await super._tapHandler(
//       goNext: goNext,
//       targetTap: targetTap,
//       overlayTap: overlayTap,
//     );
//     safeSetState(() => _goNext = goNext);
//     _controller.reverse();
//   }
//
//   @override
//   void _listener(AnimationStatus status) {
//     if (status == AnimationStatus.completed) {
//       widget.focus?.call(_targetFocus);
//     }
//     if (status == AnimationStatus.dismissed) {
//       if (_goNext) {
//         _nextFocus();
//       } else {
//         _previousFocus();
//       }
//     }
//
//     if (status == AnimationStatus.reverse) {
//       widget.removeFocus!();
//     }
//   }
// }
//
// class AnimatedPulseFocusLightState extends AnimatedFocusLightState {
//   final defaultPulseAnimationDuration = const Duration(milliseconds: 500);
//   final defaultPulseVariation = Tween(begin: 1.0, end: 0.99);
//   late AnimationController _controllerPulse;
//   late Animation _tweenPulse;
//
//   bool _finishFocus = false;
//   bool _initReverse = false;
//
//   bool get isTappableTarget => _tappablePosition != null;
//
//   bool get isRect {
//     return isTappableTarget
//         ? _targetFocus.tappableShape == ShapeLightFocus.RRect
//         : _targetFocus.shape == ShapeLightFocus.RRect;
//   }
//
//   double get left {
//     if (isRect) {
//       if (_tappablePosition != null) {
//         return _tappablePosition!.offset.dx - _getTappablePaddingFocus();
//       } else if (_targetPosition != null) {
//         return _targetPosition!.offset.dx - _getPaddingFocus();
//       } else {
//         return 0;
//       }
//     } else {
//       if (_tappablePosition != null) {
//         var maxS = max(
//           _tappablePosition!.size.width,
//           _tappablePosition!.size.height,
//         );
//         maxS = maxS * 1.2;
//         return _tappablePosition!.center.dx -
//             (maxS / 2) -
//             _getTappablePaddingFocus();
//       } else if (_targetPosition != null) {
//         var maxS = max(
//           _targetPosition!.size.width,
//           _targetPosition!.size.height,
//         );
//         maxS = maxS * 1.2;
//         return _targetPosition!.center.dx - (maxS / 2) - _getPaddingFocus();
//       } else {
//         return 0;
//       }
//     }
//   }
//
//   double get top {
//     if (isRect) {
//       if (_tappablePosition != null) {
//         return _tappablePosition!.offset.dy - _getTappablePaddingFocus();
//       } else if (_targetPosition != null) {
//         return _targetPosition!.offset.dy - _getPaddingFocus();
//       } else {
//         return 0;
//       }
//     } else {
//       if (_tappablePosition != null) {
//         var maxS = max(
//           _tappablePosition!.size.width,
//           _tappablePosition!.size.height,
//         );
//         maxS = maxS * 1.2;
//         return _tappablePosition!.center.dy -
//             (maxS / 2) -
//             _getTappablePaddingFocus();
//       } else if (_targetPosition != null) {
//         var maxS = max(
//           _targetPosition!.size.width,
//           _targetPosition!.size.height,
//         );
//         maxS = maxS * 1.2;
//         return _targetPosition!.center.dy - (maxS / 2) - _getPaddingFocus();
//       } else {
//         return 0;
//       }
//     }
//   }
//
//   double get width {
//     if (isRect) {
//       if (_tappablePosition != null) {
//         return _tappablePosition!.size.width + _getTappablePaddingFocus() * 2;
//       } else if (_targetPosition != null) {
//         return _targetPosition!.size.width + _getPaddingFocus() * 2;
//       } else {
//         return 0;
//       }
//     } else {
//       if (_tappablePosition != null) {
//         var maxS = max(_tappablePosition?.size.width ?? 0,
//             _tappablePosition?.size.height ?? 0);
//         maxS = maxS * 1.2;
//         return maxS + _getTappablePaddingFocus() * 2;
//       } else if (_targetPosition != null) {
//         var maxS = max(
//           _targetPosition!.size.width,
//           _targetPosition!.size.height,
//         );
//         maxS = maxS * 1.2;
//         return maxS + _getPaddingFocus() * 2;
//       } else {
//         return 0;
//       }
//     }
//   }
//
//   double get height {
//     if (isRect) {
//       if (_tappablePosition != null) {
//         return _tappablePosition!.size.height + _getTappablePaddingFocus() * 2;
//       } else if (_targetPosition != null) {
//         return _targetPosition!.size.height + _getPaddingFocus() * 2;
//       } else {
//         return 0.0;
//       }
//     } else {
//       if (_tappablePosition != null) {
//         var maxS = max(_tappablePosition?.size.width ?? 0,
//             _tappablePosition?.size.height ?? 0);
//         maxS = maxS * 1.2;
//         return maxS + _getTappablePaddingFocus() * 2;
//       } else if (_targetPosition != null) {
//         var maxS = max(
//           _targetPosition!.size.width,
//           _targetPosition!.size.height,
//         );
//         maxS = maxS * 1.2;
//         return maxS + _getPaddingFocus() * 2;
//       } else {
//         return 0;
//       }
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _controllerPulse = AnimationController(
//       vsync: this,
//       duration: widget.pulseAnimationDuration ?? defaultPulseAnimationDuration,
//     );
//
//     _tweenPulse = _createTweenAnimation(_targetFocus.pulseVariation ??
//         widget.pulseVariation ??
//         defaultPulseVariation);
//
//     _controllerPulse.addStatusListener(_listenerPulse);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: _targetFocus.enableOverlayTab
//           ? () => _tapHandler(overlayTap: true)
//           : null,
//       child: AnimatedBuilder(
//         animation: _controller,
//         builder: (_, child) {
//           _progressAnimated = _curvedAnimation.value;
//           _staticProgressAnimated = _progressAnimated;
//           return AnimatedBuilder(
//             animation: _controllerPulse,
//             builder: (_, child) {
//               if (_finishFocus) {
//                 _progressAnimated = _tweenPulse.value;
//               }
//               return Stack(
//                 children: <Widget>[
//                   SizedBox(
//                     width: double.maxFinite,
//                     height: double.maxFinite,
//                     child: CustomPaint(
//                       painter: _getPainter(_targetFocus),
//                     ),
//                   ),
//                   SizedBox(
//                     width: double.maxFinite,
//                     height: double.maxFinite,
//                     child: CustomPaint(
//                       painter: _getTappablePainter(_targetFocus),
//                     ),
//                   ),
//                   Positioned(
//                     left: left,
//                     top: top,
//                     child: InkWell(
//                       borderRadius: _betBorderRadiusTarget(),
//                       onTap: _targetFocus.enableTargetTab
//                           ? () => _tapHandler(targetTap: true)
//
//                           /// Essential for collecting [TapDownDetails]. Do not make [null]
//                           : () {},
//                       onTapDown: _tapHandlerForPosition,
//                       child: SizedBox(width: width, height: height),
//                     ),
//                   )
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   void _runFocus() {
//     _tweenPulse = _createTweenAnimation(_targetFocus.pulseVariation ??
//         widget.pulseVariation ??
//         defaultPulseVariation);
//     _finishFocus = false;
//     super._runFocus();
//   }
//
//   @override
//   Future _tapHandler({
//     bool goNext = true,
//     bool targetTap = false,
//     bool overlayTap = false,
//   }) async {
//     await super._tapHandler(
//       goNext: goNext,
//       targetTap: targetTap,
//       overlayTap: overlayTap,
//     );
//     if (mounted) {
//       safeSetState(() {
//         _goNext = goNext;
//         _initReverse = true;
//       });
//     }
//
//     _controllerPulse.reverse(from: _controllerPulse.value);
//   }
//
//   @override
//   void dispose() {
//     _controllerPulse.dispose();
//     super.dispose();
//   }
//
//   @override
//   void _listener(AnimationStatus status) {
//     if (status == AnimationStatus.completed) {
//       safeSetState(() => _finishFocus = true);
//
//       widget.focus?.call(_targetFocus);
//
//       _controllerPulse.forward();
//     }
//     if (status == AnimationStatus.dismissed) {
//       safeSetState(() {
//         _finishFocus = false;
//         _initReverse = false;
//       });
//       if (_goNext) {
//         _nextFocus();
//       } else {
//         _previousFocus();
//       }
//     }
//
//     if (status == AnimationStatus.reverse) {
//       widget.removeFocus!();
//     }
//   }
//
//   void _listenerPulse(AnimationStatus status) {
//     if (status == AnimationStatus.completed) {
//       _controllerPulse.reverse();
//     }
//
//     if (status == AnimationStatus.dismissed) {
//       if (_initReverse) {
//         safeSetState(() => _finishFocus = false);
//         _controller.reverse();
//       } else if (_finishFocus) {
//         _controllerPulse.forward();
//       }
//     }
//   }
//
//   Animation _createTweenAnimation(Tween<double> tween) {
//     return tween.animate(
//       CurvedAnimation(parent: _controllerPulse, curve: Curves.ease),
//     );
//   }
// }
