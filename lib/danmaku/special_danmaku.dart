import 'dart:math';
import 'dart:ui';

import 'package:fl_danmaku_widget/danmaku/danmaku.dart';
import 'package:fl_danmaku_widget/model/danmaku_config.dart';
import 'package:flutter/cupertino.dart';

import '../value.dart';

/// 这只是一个简单的高级弹幕(关键帧弹幕)
/// 没有透视效果
/// 如果你需要一些非线性插值变换颜色缩放什么的 自己写
class SpecialDanmaku extends Danmaku {
  static const defaultStartFrame = SpecialDanmakuFrame(
    point: Point(0, 0),
    alpha: Value.alphaMax,
    rotationX: 0,
    rotationY: 0,
    rotationZ: 0,
  );
  static const defaultEndFrame = SpecialDanmakuFrame(
    point: Point(1, 1),
    alpha: Value.alphaMax,
    rotationX: 0,
    rotationY: 0,
    rotationZ: 0,
  );

  @override
  bool get cacheable => true;

  var drawMode = DanmakuDrawMode.normal;

  /// K: 进度 [0, 1]
  /// V: 帧 见 [SpecialDanmakuFrame]
  var keyframes = <double, SpecialDanmakuFrame>{};

  @override
  onBuildCache(DanmakuConfig danmakuConfig) {
    var textStyle = TextStyle(
      color: textColor,
      fontSize: textSize,
    );
    if (underline) {
      textStyle = textStyle.copyWith(decoration: TextDecoration.underline);
    }
    if (drawMode == DanmakuDrawMode.shadow || drawMode == DanmakuDrawMode.shadowStroke) {
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
    if (drawMode == DanmakuDrawMode.stroke || drawMode == DanmakuDrawMode.shadowStroke) {
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

  final _imagePaint = Paint();

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
    var lastKeyframeP = 0.0;
    var nextKeyframeP = 1.0;
    var lastFrame = defaultStartFrame;
    var nextFrame = defaultEndFrame;
    keyframes.forEach((p, frame) {
      if (lastKeyframeP <= p && p <= progress) {
        lastKeyframeP = p;
        lastFrame = frame;
      }
      if (progress <= p && p <= nextKeyframeP) {
        nextKeyframeP = p;
        nextFrame = frame;
      }
    });

    final lastPoint = lastFrame.point;
    final lastAlpha = lastFrame.alpha;
    final lastRotationX = lastFrame.rotationX;
    final lastRotationY = lastFrame.rotationY;
    final lastRotationZ = lastFrame.rotationZ;
    final lastX = lastPoint.x;
    final lastY = lastPoint.y;
    final nextPoint = nextFrame.point;
    final nextAlpha = nextFrame.alpha;
    final nextRotationX = nextFrame.rotationX;
    final nextRotationY = nextFrame.rotationY;
    final nextRotationZ = nextFrame.rotationZ;
    final nextX = nextPoint.x;
    final nextY = nextPoint.y;
    var mProgress = (progress - lastKeyframeP) / (nextKeyframeP - lastKeyframeP);
    if (mProgress.isNaN) mProgress = 1.0;

    final x = lastX + (nextX - lastX) * mProgress;
    final y = lastY + (nextY - lastY) * mProgress;
    final alpha = (lastAlpha + (nextAlpha - lastAlpha) * mProgress).toInt();
    final rotationX = lastRotationX + (nextRotationX - lastRotationX) * mProgress;
    final rotationY = lastRotationY + (nextRotationY - lastRotationY) * mProgress;
    final rotationZ = lastRotationZ + (nextRotationZ - lastRotationZ) * mProgress;

    final drawX = x * drawWidth;
    final drawY = y * drawHeight;

    _imagePaint.color = Color.fromARGB(alpha, 255, 255, 255);
    final matrix =
        Matrix4.identity()
          ..translate(drawX, drawY, 0)
          ..scale(cos(rotationX * pi / 180), cos(rotationY * pi / 180), 1)
          ..rotateZ(rotationZ * pi / 180);

    canvas.save();
    canvas.transform(matrix.storage);
    canvas.drawImage(image, Offset.zero, _imagePaint);
    canvas.restore();

    // FIXME: 计算矩形
    return Rect.zero;
  }
}

/// [point] 左上角坐标 相对位置 [0, 1]
/// [alpha] 透明度 [0, 255]
/// [rotationX], [rotationY], [rotationZ] XYZ 旋转角度
///   其中 rotationX, rotationY 是伪 3D 旋转 毕竟这不是 3D 引擎
/// TODO: 解释旋转方向
/// 屏幕坐标系
///   从左向右 +x
///   从上向下 +y
///   从内向外 +z
class SpecialDanmakuFrame {
  final Point<double> point;
  final int alpha;
  final double rotationX;
  final double rotationY;
  final double rotationZ;

  const SpecialDanmakuFrame({
    required this.point,
    required this.alpha,
    required this.rotationX,
    required this.rotationY,
    required this.rotationZ,
  });
}
