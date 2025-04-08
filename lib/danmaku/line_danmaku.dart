import 'dart:ui';

import 'package:fl_danmaku_widget/danmaku/danmaku.dart';
import 'package:fl_danmaku_widget/model/danmaku_config.dart';
import 'package:flutter/cupertino.dart';

abstract class LineDanmaku extends Danmaku {
  @override
  bool get cacheable => true;

  @override
  onBuildCache(DanmakuConfig danmakuConfig) {
    var textStyle = TextStyle(
      color: textColor,
      fontSize: textSize * danmakuConfig.textSizeScale,
    );
    if (underline) {
      textStyle = textStyle.copyWith(decoration: TextDecoration.underline);
    }
    if (danmakuConfig.drawMode == DanmakuDrawMode.shadow || danmakuConfig.drawMode == DanmakuDrawMode.shadowStroke) {
      textStyle = textStyle.copyWith(
        shadows: [
          Shadow(
            color: textShadowColor ?? danmakuConfig.shadowColor,
            offset: Offset(danmakuConfig.shadowDx, danmakuConfig.shadowDy),
            blurRadius: danmakuConfig.shadowRadius,
          ),
        ],
      );
    }
    TextStyle? stokeStyle;
    if (danmakuConfig.drawMode == DanmakuDrawMode.stroke || danmakuConfig.drawMode == DanmakuDrawMode.shadowStroke) {
      stokeStyle = textStyle.copyWith(
        foreground: Paint()
          ..color = textStrokeColor ?? (textColor.computeLuminance() < 0.5 ? const Color(0xFFFFFFFF) : const Color(0xFF000000))
          ..style = PaintingStyle.stroke
          ..strokeWidth = danmakuConfig.strokeWidth,
        color: null,
      );
    }
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    TextPainter? stokePainter;
    if (stokeStyle != null) {
      stokePainter = TextPainter(
        text: TextSpan(
          text: text,
          style: stokeStyle
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    }
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    textPainter.paint(canvas, const Offset(0, 0));
    if (stokePainter != null) {
      stokePainter.paint(canvas, const Offset(0, 0));
    }
    if (borderColor != null) {
      final paint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, textPainter.width, textPainter.height),
        paint,
      );
    }
    final picture = pictureRecorder.endRecording();
    final image = picture.toImageSync(textPainter.width.ceil(), textPainter.height.ceil());
    cache = image;
  }

  bool willHit(
    Danmaku other,
    double drawWidth,
    double drawHeight,
    DanmakuConfig danmakuConfig,
  );
}
