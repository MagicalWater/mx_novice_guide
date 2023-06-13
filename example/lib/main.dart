import 'package:flutter/material.dart';
import 'package:mx_novice_guide/mx_novice_guide.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final globalKey = GlobalKey();
  final globalKey2 = GlobalKey();
  late MxNoviceGuide guide;

  bool add = false;

  @override
  void initState() {
    super.initState();

    guide = MxNoviceGuide(
      count: 2,
      builder: (context, index) {
        if (index == 0) {
          return GuideStep(
            maskColor: Colors.black.withOpacity(0.6),
            onTapSpace: (controller) {
              controller.next();
            },
            targets: [
              FocusTarget(
                identify: globalKey,
                targetKey: globalKey,
                descBuilder: (context, controller, targetRect, allRect) {
                  return Stack(
                    children: [
                      Positioned(
                        top: targetRect.oriRect!.bottom,
                        left: targetRect.oriRect!.left,
                        child: const Text(
                          '這是說明文字',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                shape: BoxShape.circle,
                targetPadding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
              ),
            ],
          );
        } else {
          return GuideStep(
            maskColor: Colors.black.withOpacity(0.6),
            onTapSpace: (controller) {
              controller.next();
            },
            targets: [
              FocusTarget(
                identify: globalKey2,
                targetKey: globalKey2,
                shape: BoxShape.rectangle,
              ),
            ],
          );
        }
      },
      skipWidget: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white, width: 1),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        child: const Center(
          heightFactor: 1,
          child: Text('跳過'),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2)).then((value) {
      guide.show(context: globalKey.currentContext!, rootOverlay: false);

      // Future.delayed(Duration(seconds: 4)).then((value) {
      add = true;
      setState(() {});
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Test Guide', key: globalKey),
            const SizedBox(height: 40),
            const Text('=================='),
            const SizedBox(height: 40),
            Text('Two', key: add ? globalKey2 : null),
          ],
        ),
      ),
    );
  }

  void guideTarget() {}
}
