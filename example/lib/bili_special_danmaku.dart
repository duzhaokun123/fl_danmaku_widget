import 'dart:math';
import 'dart:ui';

import 'package:fl_danmaku_widget/danmaku/danmaku.dart';
import 'package:fl_danmaku_widget/model/danmaku_config.dart';
import 'package:flutter/cupertino.dart';

/// 随便写的 不要抄
class BiliSpecialDanmaku extends Danmaku {
  static const biliPlayerWidth = 682.0;
  static const biliPlayerHeight = 438.0;

  var rotationY = 0.0;

  var beginX = 0.0;
  var beginY = 0.0;

  var endX = 0.0;
  var endY = 0.0;

  get deltaX => endX - beginX;
  get deltaY => endY - beginY;

  var beginAlpha = 0.0;
  var endAlpha = 0.0;
  get deltaAlpha => endAlpha - beginAlpha;

  @override
  bool get cacheable => true;

  @override
  onBuildCache(DanmakuConfig danmakuConfig) {
    var textStyle = TextStyle(
      color: textColor,
      fontSize: textSize,
    );
    if (underline) {
      textStyle = textStyle.copyWith(decoration: TextDecoration.underline);
    }
    textStyle = textStyle.copyWith(
      shadows: [
        Shadow(
          color: textShadowColor ?? danmakuConfig.shadowColor,
          offset: Offset(danmakuConfig.shadowDx, danmakuConfig.shadowDy),
          blurRadius: danmakuConfig.shadowRadius,
        ),
      ],
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    textPainter.paint(canvas, const Offset(0, 0));
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

  final _imagePaint = Paint();

  @override
  Rect? onDraw(Canvas canvas, double drawWidth, double drawHeight, double progress, DanmakuConfig danmakuConfig, int line) {
    if (cache == null) onBuildCache(danmakuConfig);
    final image = cache;
    if (image == null) return null;
    _imagePaint.color = Color.fromRGBO(0, 0, 0, beginAlpha + deltaAlpha * progress);
    final x = beginX + deltaX * progress;
    final y = beginY + deltaY * progress;
    final (drawX, drawY) = getDrawXY(x, y, drawWidth, drawHeight);
    canvas.save();
    canvas.rotate(rotationY * pi / 180);
    canvas.translate(drawX, drawY);
    canvas.drawImage(image, Offset.zero, _imagePaint);
    canvas.restore();
    return Rect.zero;
  }

  (double, double) getDrawXY(double x, double y, double drawWidth, double drawHeight) {
    var drawX = x * biliPlayerWidth / drawWidth;
    var drawY = y * biliPlayerHeight / drawHeight;
    return (drawX, drawY);
  }

  void fillText() {
    text = text.replaceAll("/n", "\n");
  }
}