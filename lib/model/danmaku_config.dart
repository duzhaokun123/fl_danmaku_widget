import 'dart:ui';

import '../danmaku/danmaku.dart';

class DanmakuConfig {
  /// 持续时间系数
  var durationScale = 1.0;

  /// 字体大小系数
  var textSizeScale = 1.0;

  /// 行高
  var lineHeight = 40;

  /// 上边距
  var marginTop = 0.0;

  /// 下边距
  var marginBottom = 0.0;

  /// 绘制模式
  var drawMode = DanmakuDrawMode.normal;

  /// 阴影半径
  var shadowRadius = 5.0;

  /// 阴影 x 偏移
  var shadowDx = 0.0;

  /// 阴影 y 偏移
  var shadowDy = 0.0;

  /// 后备阴影颜色
  var shadowColor = const Color(0xFF000000);

  /// 描边宽度
  var strokeWidth = 1.0;

  /// 允许堆叠
  var allowOverlap = false;

  /// 屏蔽器
  var blockers = <bool Function(Danmaku, int)>[];

  /// 最大行数
  /// 与 [maxRelativeHeight] 一同设置时取最小值
  var maxLine = 1000; // just some big value

  /// 最大相对高度
  /// 与 [maxLine] 一同设置时取最小值
  var maxRelativeHeight = 1.0;

  /// 也许你需要一些自己的弹幕类的特别设置
  var custom = <String, dynamic>{};
}

enum DanmakuDrawMode { normal, shadow, stroke, shadowStroke }
