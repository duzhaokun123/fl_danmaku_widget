import 'package:fl_danmaku_widget/model/showing_danmaku_info.dart';
import 'package:fl_danmaku_widget/ui/danmaku_widget.dart';
import 'package:fl_danmaku_widget/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../danmaku/danmaku.dart';
import '../model/danmakus.dart';

class DanmakuController {
  static const int poolUndefined = -1;
  final DanmakuWidget widget;
  final dynamic state;
  DanmakuController({
    required this.widget,
    required this.state,
});
  var showingDanmakus = <ShowingDanmakuInfo>[];
  double get conductedTimeMs => conductedTimeUs / 1_000;
  var conductedTimeUs = 0;
  final danmakus = <int, Danmakus>{};
  var drawDebugInfo = false;
  var debugStyle = TextStyle(
    color: const Color(0xFFFFFFFF),
    fontSize: 20,
  );
  var speed = 1.0;
  var drawPaused = true;
  var _period = 16;
  int get period => _period;
  set period(int value) {
    _period = value;
    state.launcherTimer(period: value);
  }
  var shouldDrawOneTime = false;
void pause() {
  drawPaused = true;
}
void resume() {
  drawPaused = false;
}
void seekTo(int timeMs) {
  conductedTimeUs = timeMs * 1_000;
  drawOneTime();
}

void start({int timeMs = 0}) {
  conductedTimeUs = timeMs * 1_000;
  resume();
}

void drawOneTime() {
  state.setState(() {});
}

void addDanmakus(Danmakus danmakus, {int pool = DanmakuController.poolUndefined}) {
  if (this.danmakus[pool] == null) {
    this.danmakus[pool] = danmakus;
  } else {
    this.danmakus[pool]!.addAll(danmakus);
  }
}

void addDanmaku(Danmaku danmaku, {int pool = DanmakuController.poolUndefined}) {
  if (danmakus[pool] == null) {
    danmakus[pool] = Danmakus();
  }
  danmakus[pool]!.add(danmaku);}

  void removeAllDanmakus() {
    danmakus.clear();
  }

  Future<void> buildCache({bool recache = false}) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    var count = 0;
    danmakus.forEachDanmaku((danmaku) {
      if (danmaku.cacheable && (danmaku.cache == null || recache)) {
        danmaku.onBuildCache(widget.danmakuConfig);
        if (danmaku.cache != null) count += 1;
      }
    });
    if (kDebugMode) {
      print("buildCache: $count, ${DateTime.now().millisecondsSinceEpoch - startTime}ms");
    }
  }

  Future<void> cleanCache() async {
    danmakus.forEachDanmaku((danmaku) {
      danmaku.cache = null;
    });
  }
}