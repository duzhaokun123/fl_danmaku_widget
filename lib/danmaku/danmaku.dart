import 'dart:ui';

import 'package:fl_danmaku_widget/model/danmaku_config.dart';

abstract class Danmaku {
  /// 偏移时间(毫秒)
  var offset = 0;

  /// 文本
  var text = "";

  /// 文本颜色
  var textColor = Color(0xFFFFFFFF);

  /// 阴影颜色
  Color? textShadowColor;

  /// 描边颜色
  Color? textStrokeColor;

  /// 下划线
  var underline = false;

  /// 字体大小
  var textSize = 25.0;

  /// 边框颜色
  Color? borderColor;

  /// 内边距
  // var padding = 0;

  /// 存活时间(毫秒)
  var duration = 5000;

  /// 绘制用缓存
  Image? cache;

  /// 透明度
  // var alpha = 1.0;

  /// 可见性
  var visible = true;

  dynamic tag;

  /// 可缓存
  bool get cacheable;

  onBuildCache(DanmakuConfig danmakuConfig);

  /// [drawWidth] 画布宽
  /// [drawHeight] 画布高
  /// [progress] 进度 [0, 1]
  /// [line] 行弹幕绘制在第几行, 从 1 开始计数, 对于非行弹幕常为 0
  /// returns [Rect] 画到哪了 null: 没画
  Rect? onDraw(
    Canvas canvas,
    double drawWidth,
    double drawHeight,
    double progress,
    DanmakuConfig danmakuConfig,
    int line,
  );

  @override
  String toString() {
    return text;
  }
}
