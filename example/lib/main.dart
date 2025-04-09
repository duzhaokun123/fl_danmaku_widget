import 'dart:math';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:fl_danmaku_example/bili_special_danmaku.dart';
import 'package:fl_danmaku_widget/danmaku/bottom_danmaku.dart';
import 'package:fl_danmaku_widget/danmaku/danmaku.dart';
import 'package:fl_danmaku_widget/danmaku/l2r_danmaku.dart';
import 'package:fl_danmaku_widget/danmaku/special_danmaku.dart';
import 'package:fl_danmaku_widget/danmaku/top_danmaku.dart';
import 'package:fl_danmaku_widget/model/danmaku_config.dart';
import 'package:fl_danmaku_widget/model/danmakus.dart';
import 'package:fl_danmaku_widget/ui/danmaku_controller.dart';
import 'package:flutter/material.dart';
import 'package:fl_danmaku_widget/ui/danmaku_widget.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_danmaku_widget/danmaku/r2l_danmaku.dart';
import 'package:fl_danmaku_widget/value.dart';
import 'package:platform_info/platform_info.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fl_danmaku_example',
      theme: _buildTheme(),
      home: const MyHomePage(title: 'fl_danmaku_example'),
    );
  }

  ThemeData _buildTheme() {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    );
    return baseTheme;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DanmakuController _danmakuController;
  var danmakuConfig = DanmakuConfig();

  var _allowOverlap = false;
  var _speed = 1.0;
  var _durationScale = 1.0;
  var _textSizeScale = 1.0;
  var _lineHeight = 40;
  var _marginTop = 0.0;
  var _marginBottom = 0.0;
  var _maxRelativeHeight = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          DanmakuWidget(
            createdController: (c) {
              _danmakuController = c;
              _danmakuController.drawDebugInfo = true;
              _danmakuController.debugStyle = GoogleFonts.robotoMono(
                textStyle: _danmakuController.debugStyle,
              );
            },
            danmakuConfig: danmakuConfig,
          ),
          Container(
            margin: EdgeInsets.only(bottom: 100),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Wrap(
                direction: Axis.horizontal,
                children: [
                  TextButton(
                    onPressed: () {
                      _danmakuController.addDanmaku(
                        R2LDanmaku()
                          ..offset = _danmakuController.conductedTimeMs.toInt()
                          ..text = "Danmaku"
                          ..borderColor = Colors.green,
                      );
                    },
                    child: const Text(
                      "send",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      parseDanmakuDialog();
                    },
                    child: const Text(
                      "parse",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _danmakuController.pause();
                    },
                    child: const Text(
                      "pause",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _danmakuController.resume();
                    },
                    child: const Text(
                      "resume",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _danmakuController.start();
                    },
                    child: const Text(
                      "start",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _danmakuController.buildCache();
                    },
                    child: const Text(
                      "build cache",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _danmakuController.cleanCache();
                    },
                    child: const Text(
                      "clear cache",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _danmakuController.drawOneTime();
                    },
                    child: const Text(
                      "draw one-time",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      print("font family");
                    },
                    child: const Text(
                      "font family",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      print("style");
                    },
                    child: const Text(
                      "style",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      print("background");
                    },
                    child: const Text(
                      "background",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "allow overlap",
                        style: TextStyle(color: Colors.green),
                      ),
                      Switch(
                        value: _allowOverlap,
                        onChanged: (value) {
                          setState(() {
                            _allowOverlap = value;
                            danmakuConfig.allowOverlap = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "speed ${_speed.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.green),
                      ),
                      Slider(
                        value: _speed,
                        onChanged: (value) {
                          setState(() {
                            _speed = value;
                            _danmakuController.speed = value;
                          });
                        },
                        min: -2.0,
                        max: 2.0,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "duration scale ${_durationScale.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.green),
                      ),
                      Slider(
                        value: _durationScale,
                        onChanged: (value) {
                          setState(() {
                            _durationScale = value;
                            danmakuConfig.durationScale = value;
                          });
                        },
                        min: 0.1,
                        max: 2.0,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "textSize scale ${_textSizeScale.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.green),
                      ),
                      Slider(
                        value: _textSizeScale,
                        onChanged: (value) {
                          setState(() {
                            _textSizeScale = value;
                            danmakuConfig.textSizeScale = value;
                          });
                        },
                        min: 0.1,
                        max: 2.0,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "line height ${_lineHeight.toString()}",
                        style: const TextStyle(color: Colors.green),
                      ),
                      Slider(
                        value: _lineHeight.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            _lineHeight = value.toInt();
                            danmakuConfig.lineHeight = value.toInt();
                          });
                        },
                        min: 20,
                        max: 60,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "margin top ${_marginTop.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.green),
                      ),
                      Slider(
                        value: _marginTop,
                        onChanged: (value) {
                          setState(() {
                            _marginTop = value;
                            danmakuConfig.marginTop = value;
                          });
                        },
                        min: 0.0,
                        max: 50,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "margin bottom ${_marginBottom.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.green),
                      ),
                      Slider(
                        value: _marginBottom,
                        onChanged: (value) {
                          setState(() {
                            _marginBottom = value;
                            danmakuConfig.marginBottom = value;
                          });
                        },
                        min: 0,
                        max: 50,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "max relative height ${_maxRelativeHeight.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.green),
                      ),
                      Slider(
                        value: _maxRelativeHeight,
                        onChanged: (value) {
                          setState(() {
                            _maxRelativeHeight = value;
                            danmakuConfig.maxRelativeHeight = value;
                          });
                        },
                        min: 0,
                        max: 1,
                      ),
                      TextButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text(
                                  "${platform.operatingSystem} ${platform.version} ${platform.type} ${platform.locale}",
                                ),
                              );
                            },
                          );
                        },
                        child: const Text("platform"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void parseDanmakuDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("parse danmaku"),
          children: [
            SimpleDialogOption(
              onPressed: () {
                parseDanmakuBiliAsset();
                Navigator.pop(context);
              },
              child: const Text("danmakuBili"),
            ),
            SimpleDialogOption(
              onPressed: () {
                parseDanmakuBiliFile();
                Navigator.pop(context);
              },
              child: const Text("file"),
            ),
            SimpleDialogOption(
              onPressed: () {
                parseTestSpecialDanmaku();
                Navigator.pop(context);
              },
              child: const Text("special"),
            ),
            SimpleDialogOption(
              onPressed: () {
                _danmakuController.pause();
                _danmakuController.removeAllDanmakus();
                _danmakuController.seekTo(0);
                Navigator.pop(context);
              },
              child: const Text("empty"),
            ),
            // SimpleDialogOption(
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            //   child: const Text("later 10s"),
            // ),
            SimpleDialogOption(
              onPressed: () {
                _danmakuController.debugStyle = _danmakuController.debugStyle
                    .copyWith(color: Colors.red);
                _danmakuController.pause();
                _danmakuController.removeAllDanmakus();
                for (var i = 0; i < 200_000; i++) {
                  _danmakuController.addDanmaku(
                    R2LDanmaku()
                      ..offset = 1 + i
                      ..duration = 2000
                      ..text = "Danmaku",
                    pool: 1,
                  );
                }
                _danmakuController.seekTo(0);
                Navigator.pop(context);
              },
              child: const Text("200k danmaku"),
            ),
          ],
        );
      },
    );
  }

  void parseTestSpecialDanmaku() {
    _danmakuController.pause();
    _danmakuController.removeAllDanmakus();
    _danmakuController.addDanmaku(
      SpecialDanmaku()
        ..keyframes = {
          0: SpecialDanmakuFrame(
            point: Point(0.5, 0.5),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
          1: SpecialDanmakuFrame(
            point: Point(0.5, 0.5),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
        }
        ..text = "高级弹幕"
        ..textSize = 25
        ..offset = 0,
    );
    _danmakuController.addDanmaku(
      SpecialDanmaku()
        ..keyframes = {
          0: SpecialDanmakuFrame(
            point: Point(0.2, 0.2),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
          1: SpecialDanmakuFrame(
            point: Point(0.2, 0.2),
            alpha: Value.alphaMax,
            rotationX: 360,
            rotationY: 0,
            rotationZ: 0,
          ),
        }
        ..text = "X 旋转 ------"
        ..textSize = 25
        ..offset = 0,
    );
    _danmakuController.addDanmaku(
      SpecialDanmaku()
        ..keyframes = {
          0: SpecialDanmakuFrame(
            point: Point(0.2, 0.2),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
          1: SpecialDanmakuFrame(
            point: Point(0.2, 0.2),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 360,
            rotationZ: 0,
          ),
        }
        ..text = "Y 旋转 ||||||"
        ..textSize = 25
        ..offset = 0,
    );
    _danmakuController.addDanmaku(
      SpecialDanmaku()
        ..keyframes = {
          0: SpecialDanmakuFrame(
            point: Point(0.2, 0.2),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
          1: SpecialDanmakuFrame(
            point: Point(0.2, 0.2),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 360,
          ),
        }
        ..text = "Z 旋转 ++++++"
        ..textSize = 25
        ..offset = 0,
    );
    _danmakuController.addDanmaku(
      SpecialDanmaku()
        ..keyframes = {
          0: SpecialDanmakuFrame(
            point: Point(0.2, 0.3),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
          1: SpecialDanmakuFrame(
            point: Point(0.2, 0.3),
            alpha: Value.alphaMax,
            rotationX: 360,
            rotationY: 360,
            rotationZ: 0,
          ),
        }
        ..text = "XY 旋转 -|-|-|"
        ..textSize = 25
        ..offset = 0,
    );
    _danmakuController.addDanmaku(
      SpecialDanmaku()
        ..keyframes = {
          0: SpecialDanmakuFrame(
            point: Point(0.2, 0.3),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
          1: SpecialDanmakuFrame(
            point: Point(0.2, 0.3),
            alpha: Value.alphaMax,
            rotationX: 360,
            rotationY: 0,
            rotationZ: 360,
          ),
        }
        ..text = "XZ 旋转 -+-+-+"
        ..textSize = 25
        ..offset = 0,
    );
    _danmakuController.addDanmaku(
      SpecialDanmaku()
        ..keyframes = {
          0: SpecialDanmakuFrame(
            point: Point(0.2, 0.3),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
          1: SpecialDanmakuFrame(
            point: Point(0.2, 0.3),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 360,
            rotationZ: 360,
          ),
        }
        ..text = "YZ 旋转 |+|+|+"
        ..textSize = 25
        ..offset = 0,
    );
    _danmakuController.addDanmaku(
      SpecialDanmaku()
        ..keyframes = {
          0: SpecialDanmakuFrame(
            point: Point(0.2, 0.4),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
          1: SpecialDanmakuFrame(
            point: Point(0.2, 0.4),
            alpha: Value.alphaMax,
            rotationX: 360,
            rotationY: 360,
            rotationZ: 360,
          ),
        }
        ..text = "XYZ 旋转 @@@@@@"
        ..textSize = 25
        ..offset = 0,
    );
    _danmakuController.addDanmaku(
      SpecialDanmaku()
        ..keyframes = {
          0: SpecialDanmakuFrame(
            point: Point(0.8, 0.8),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
          0.5: SpecialDanmakuFrame(
            point: Point(0.8, 0.8),
            alpha: Value.alphaMin,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
          1: SpecialDanmakuFrame(
            point: Point(0.8, 0.8),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
        }
        ..text = "变 Alpha ******"
        ..textSize = 25
        ..offset = 0,
    );
    _danmakuController.addDanmaku(
      SpecialDanmaku()
        ..keyframes = {
          0: SpecialDanmakuFrame(
            point: Point(0.0, 0.0),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
          0.2: SpecialDanmakuFrame(
            point: Point(0.3, 0.5),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
          0.4: SpecialDanmakuFrame(
            point: Point(0.9, 0.1),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
          0.6: SpecialDanmakuFrame(
            point: Point(0.9, 0.6),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
          0.8: SpecialDanmakuFrame(
            point: Point(0.44, 0.7),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
          1: SpecialDanmakuFrame(
            point: Point(1.8, 1.0),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
        }
        ..text = "===移动==="
        ..textSize = 25
        ..offset = 0,
    );
    _danmakuController.addDanmaku(
      SpecialDanmaku()
        ..keyframes = {
          0: SpecialDanmakuFrame(
            point: Point(0.2, 0.8),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
          1: SpecialDanmakuFrame(
            point: Point(0.2, 0.8),
            alpha: Value.alphaMax,
            rotationX: 0,
            rotationY: 0,
            rotationZ: 0,
          ),
        }
        ..text = "多行\n行1\n行2\n行3"
        ..textSize = 25
        ..offset = 0,
    );
    final random = Random();
    createRandomFrame() {
      return SpecialDanmakuFrame(
        point: Point(random.nextDouble(), random.nextDouble()),
        alpha: random.nextInt(Value.alphaMax),
        rotationX: random.nextDouble() * 720,
        rotationY: random.nextDouble() * 720,
        rotationZ: random.nextDouble() * 720,
      );
    }

    final keyframes = <double, SpecialDanmakuFrame>{};
    for (var i = 0; i <= 8; i++) {
      keyframes[random.nextDouble()] = createRandomFrame();
    }
    keyframes[0] = createRandomFrame();
    keyframes[1] = createRandomFrame();
    _danmakuController.addDanmaku(
      SpecialDanmaku()
        ..keyframes = keyframes
        ..text = "随机生成"
        ..textSize = 25
        ..offset = 0,
    );
    _danmakuController.seekTo(0);
  }

  void parseDanmakuBiliXml(String xml) {
    final doc = XmlDocument.parse(xml);
    final danmakus = <int, Danmakus>{};
    Danmaku createDanmaku(int type) {
      if (type == 1) {
        return R2LDanmaku();
      } else if (type == 4) {
        return BottomDanmaku();
      } else if (type == 5) {
        return TopDanmaku();
      } else if (type == 6) {
        return L2RDanmaku();
      } else if (type == 7) {
        return BiliSpecialDanmaku();
      } else {
        print("unknown danmaku type: $type, default to R2LDanmaku");
        return R2LDanmaku();
      }
    }

    doc.xpath("/i/d").forEach((d) {
      final p = d.getAttribute("p")!.split(",");
      final danmaku = createDanmaku(int.parse(p[1]));
      danmaku
        ..text = d.innerText
        ..offset = (double.parse(p[0]) * 1000).toInt()
        ..textSize = double.parse(p[2])
        ..textColor = Color(int.parse(p[3]) | 0xFF000000);
      danmakus[int.parse(p[5])] ??= Danmakus();
      danmakus[int.parse(p[5])]!.add(danmaku);
      if (danmaku is BiliSpecialDanmaku) {
        var text = danmaku.text;
        if (text.startsWith("[")) {
          final textArray = <String>[];
          dynamic jsonArray;
          try {
            jsonArray = json.decode(text);
          } catch (e) {
            try {
              jsonArray = json.decode(text + '"]');
            } catch (e) {
              try {
                jsonArray = json.decode(text + ']');
              } catch (e) {
                try {
                  jsonArray = json.decode(
                    text.substring(0, text.length - 1) + ']',
                  );
                } catch (e) {}
              }
            }
          }
          if (jsonArray != null) {
            jsonArray.forEach((i) {
              textArray.add(i.toString());
            });
          } else {
            print("parse error");
          }
          if (textArray.length >= 5 && textArray[4].isNotEmpty) {
            danmaku.text = textArray[4];
            danmaku.fillText();
            var beginX = double.tryParse(textArray[0]) ?? 0;
            var beginY = double.tryParse(textArray[1]) ?? 0;
            var endX = beginX;
            var endY = beginY;
            var alphaArray = textArray[2].split("-");
            var beginAlpha = double.tryParse(alphaArray[0]) ?? 1;
            var endAlpha = beginAlpha;
            if (alphaArray.length > 1) {
              endAlpha = double.tryParse(alphaArray[1]) ?? 1;
            }
            var rotateY = 0.0;
            if (textArray.length >= 7) {
              rotateY = double.tryParse(textArray[6]) ?? 0;
            }
            if (textArray.length >= 11) {
              endX = double.tryParse(textArray[7]) ?? 0;
              endY = double.tryParse(textArray[8]) ?? 0;
            }
            if (textArray[0].contains(".")) {
              beginX *= BiliSpecialDanmaku.biliPlayerWidth;
            }
            if (textArray[1].contains(".")) {
              beginY *= BiliSpecialDanmaku.biliPlayerHeight;
            }
            if (textArray.length >= 8 && textArray[7].contains(".")) {
              endX *= BiliSpecialDanmaku.biliPlayerWidth;
            }
            if (textArray.length >= 9 && textArray[8].contains(".")) {
              endY *= BiliSpecialDanmaku.biliPlayerHeight;
            }
            danmaku
              ..beginX = beginX
              ..beginY = beginY
              ..endX = endX
              ..endY = endY
              ..beginAlpha = beginAlpha
              ..endAlpha = endAlpha
              ..rotationY = rotateY;
            if (textArray.length >= 12) {
              if (bool.tryParse(textArray[11]) ?? false) {
                danmaku.textShadowColor = Colors.transparent;
              }
            }
          }
        }
      }
    });

    _danmakuController.pause();
    _danmakuController.removeAllDanmakus();
    _danmakuController.addAll(danmakus);
    _danmakuController.seekTo(0);
  }

  Future<void> parseDanmakuBiliAsset() async {
    final xml = await rootBundle.loadString("assets/danmaku.xml");
    parseDanmakuBiliXml(xml);
  }

  Future<void> parseDanmakuBiliFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml'],
    );
    if (result != null) {
      final xml = await result.files.first.xFile.readAsString();
      parseDanmakuBiliXml(xml);
    }
  }
}
