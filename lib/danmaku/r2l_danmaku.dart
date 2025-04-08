import 'dart:ui';

import 'package:fl_danmaku_widget/danmaku/danmaku.dart';
import 'package:fl_danmaku_widget/danmaku/line_danmaku.dart';
import 'package:fl_danmaku_widget/model/danmaku_config.dart';
import 'package:fl_danmaku_widget/utils.dart';
import 'package:flutter/cupertino.dart';

class R2LDanmaku extends LineDanmaku {
  @override
  Rect? onDraw(
    Canvas canvas,
    double drawWidth,
    double drawHeight,
    double progress,
    DanmakuConfig danmakuConfig,
    int line,
  ) {
    if (cache == null) onBuildCache(danmakuConfig);
    final image = cache;
    if (image == null) return null;
    final x = (drawWidth + image.width) * (1 - progress) - image.width;
    final y = (danmakuConfig.lineHeight * (line - 1)) + danmakuConfig.marginTop;
    final width = image.width;
    final height = image.height;
    canvas.drawImage(image, Offset(x, y), Paint());
    return Rect.fromLTWH(x, y, width.toDouble(), height.toDouble());
  }

  @override
  bool willHit(
    Danmaku other,
    double drawWidth,
    double drawHeight,
    DanmakuConfig danmakuConfig,
  ) => checkScrollLineDanmakuHit(other, drawWidth, danmakuConfig);
}
