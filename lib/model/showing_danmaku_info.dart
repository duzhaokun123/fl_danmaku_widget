import 'dart:ui';

import 'package:fl_danmaku_widget/danmaku/danmaku.dart';

class ShowingDanmakuInfo {
  final Danmaku danmaku;
  final Rect rect;
  final int line;
  final double progress;
  final int pool;

  const ShowingDanmakuInfo({
    required this.danmaku,
    required this.rect,
    required this.line,
    required this.progress,
    required this.pool,
  });
}
