import 'dart:async';
import 'dart:math';

import 'package:fl_danmaku_widget/danmaku/line_danmaku.dart';
import 'package:fl_danmaku_widget/model/danmaku_config.dart';
import 'package:fl_danmaku_widget/ui/danmaku_controller.dart';
import 'package:fl_danmaku_widget/utils.dart';
import 'package:flutter/cupertino.dart';

import '../danmaku/danmaku.dart';
import '../model/showing_danmaku_info.dart';

class DanmakuWidget extends StatefulWidget {
  final void Function(DanmakuController) createdController;
  final DanmakuConfig danmakuConfig;

  const DanmakuWidget({
    required this.createdController,
    required this.danmakuConfig,
    super.key,
  });

  @override
  State<DanmakuWidget> createState() => _DanmakuWidgetState();
}

class _DanmakuWidgetState extends State<DanmakuWidget> {
  late DanmakuController _danmakuController;
  Timer? timer;

  @override
  void initState() {
    _danmakuController = DanmakuController(widget: widget, state: this);
    widget.createdController(_danmakuController);
    launcherTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _DanmakuPainter(
          danmakuController: _danmakuController,
          danmakuConfig: widget.danmakuConfig,
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void launcherTimer({int period = 16}) {
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: period), (_){
      if (_danmakuController.drawPaused) return;
      _danmakuController.conductedTimeUs += (period * 1_000 * _danmakuController.speed).toInt();
      setState(() {});
    });
  }
}

class _DanmakuPainter extends CustomPainter {
  final DanmakuController danmakuController;
  final DanmakuConfig danmakuConfig;

  const _DanmakuPainter({
    required this.danmakuController,
    required this.danmakuConfig,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final drawWidth = size.width;
    final drawHeight = size.height;
    _drawDanmakus(canvas, drawWidth, drawHeight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

  void _drawDanmakus(Canvas canvas, double drawWidth, double drawHeight) {
    final start = DateTime.timestamp().microsecondsSinceEpoch;
    var maxLine = (((drawHeight - danmakuConfig.marginTop - danmakuConfig.marginBottom) * danmakuConfig.maxRelativeHeight) / danmakuConfig.lineHeight).toInt();
    if (maxLine < 1) return;
    maxLine = min(maxLine, danmakuConfig.maxLine);

    final oldShowingDanmakus = danmakuController.showingDanmakus;
    final willShowingDanmakus = <ShowingDanmakuInfo>[];
    final willDrawDanmakus = <(Danmaku, double, int)>[];
    final conductedTime = danmakuController.conductedTimeMs;

    danmakuController.danmakus.forEach((pool, danmakus) {
      for (var danmaku in danmakus) {
        if (!danmaku.visible) continue;

        final duration = danmaku.duration * danmakuConfig.durationScale;
        final start = danmaku.offset;
        final end = danmaku.offset + duration;
        if (start <= conductedTime && conductedTime <= end) {
          for (var blocker in danmakuConfig.blockers) {
            if (blocker(danmaku, pool)) continue;
          }
          final progress = (conductedTime - start) / duration;
          willDrawDanmakus.add((danmaku, progress, pool));
        }
      }
    });
    // 2025-04-06: dart 在这种情况下不能解构匿名元组?
    willDrawDanmakus.removeWhere((a) {
      final (danmaku, progress, pool) = a;

      bool re;
      final oldShowingDanmaku = _findOldShowingDanmaku(oldShowingDanmakus, danmaku, pool);
      if (oldShowingDanmaku != null) {
        _drawDanmaku(canvas, maxLine, danmaku, progress, oldShowingDanmaku.line, pool, willShowingDanmakus, drawWidth, drawHeight);
        re = true;
      } else {
        re = false;
      }
      return re;
    });
    for (var (danmaku, progress, pool) in willDrawDanmakus) {
      if (danmaku is LineDanmaku) {
        var line = 1;
        bool moved;
        do {
          moved = false;
          for (var willShowingDanmaku in willShowingDanmakus) {
            if (line == willShowingDanmaku.line && danmaku.runtimeType == willShowingDanmaku.danmaku.runtimeType && willShowingDanmaku.pool == pool) {
              if (danmaku.willHit(willShowingDanmaku.danmaku, drawWidth, drawHeight, danmakuConfig)) {
                line += 1;
                moved = true;
                break;
              }
            }
          }
        } while(moved);
        _drawDanmaku(canvas, maxLine, danmaku, progress, line, pool, willShowingDanmakus, drawWidth, drawHeight);
      } else {
        _drawDanmaku(canvas, 0, danmaku, progress, 0, pool, willShowingDanmakus, drawWidth, drawHeight);
      }
    }
    danmakuController.showingDanmakus = willShowingDanmakus;

    if (danmakuController.drawDebugInfo) {
      _drawDebug(canvas, DateTime.timestamp().microsecondsSinceEpoch - start, drawWidth, drawHeight);
    }
  }

  ShowingDanmakuInfo? _findOldShowingDanmaku(
      List<ShowingDanmakuInfo> oldShowingDanmakus, Danmaku danmaku, int pool) {
    for (var info in oldShowingDanmakus) {
      if (identical(danmaku, info.danmaku) && pool == info.pool) {
        return info;
      }
    }
    return null;
  }

  void _drawDanmaku(Canvas canvas, int maxLine, Danmaku danmaku, double progress,
      int line, int pool, List<ShowingDanmakuInfo> willShowingDanmakus,
      double drawWidth, double drawHeight) {
    if (line == 0) {
      final rect = danmaku.onDraw(canvas, drawWidth, drawHeight, progress, danmakuConfig, 0);
      if (rect != null) {
        willShowingDanmakus.add(ShowingDanmakuInfo(danmaku: danmaku, rect: rect, line: line, progress: progress, pool: pool));
      }
    } else if (line <= maxLine || danmakuConfig.allowOverlap) {
      var drawLine = line % maxLine;
      if (drawLine == 0) drawLine = maxLine;
      final rect = danmaku.onDraw(canvas, drawWidth, drawHeight, progress, danmakuConfig, drawLine);
      if (rect != null) {
        willShowingDanmakus.add(ShowingDanmakuInfo(danmaku: danmaku, rect: rect, line: line, progress: progress, pool: pool));
      }
    }
  }

  void _drawDebug(Canvas canvas, int frameTimeUs, double drawWidth, double drawHeight) {
    final info = "frameTime: ${frameTimeUs / 1_000.0} ms\n"
        "conductedTimeUs: ${danmakuController.conductedTimeUs}, speed: ${danmakuController.speed}, size: $drawWidth x $drawHeight\n"
        "showingCount: ${danmakuController.showingDanmakus.length}, pools: ${danmakuController.danmakus.length}, count: ${danmakuController.danmakus.danmakuCount}";
    final textPainter = TextPainter(
      text: TextSpan(
        text: info,
        style: danmakuController.debugStyle
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, drawHeight - 80));
  }
}