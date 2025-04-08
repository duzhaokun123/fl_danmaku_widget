import 'package:fl_danmaku_widget/model/danmaku_config.dart';

import 'danmaku/danmaku.dart';
import 'danmaku/line_danmaku.dart';
import 'model/danmakus.dart';

extension MapIntDanmakusExtension on Map<int, Danmakus> {
  int get danmakuCount {
    var re = 0;
    for (var danmakus in values) {
      re += danmakus.length;
    }
    return re;
  }

  void forEachDanmaku(void Function(Danmaku) action) {
    this.forEach((_, danmakus) {
      danmakus.forEach(action);
    });
  }
}

extension LineDanmakuExtension on LineDanmaku {
  bool checkScrollLineDanmakuHit(Danmaku other, double drawWidth, DanmakuConfig danmakuConfig) {
    if (this.offset == other.offset) return true;

    if (this.cache == null) this.onBuildCache(danmakuConfig);
    final otherCache = other.cache;
    if (otherCache == null) return false;
    final otherSpeed = (drawWidth + otherCache.width) / (other.duration * danmakuConfig.durationScale);
    final otherFullShowTime = other.offset + (otherCache.width / otherSpeed);
    if (other.offset <= this.offset && this.offset <= otherFullShowTime) return true;

    if (other.cache == null) other.onBuildCache(danmakuConfig);
    final thisCache = this.cache;
    if (thisCache == null) return false;
    final thisSpeed = (drawWidth + thisCache.width) / (this.duration * danmakuConfig.durationScale);
    final thisFullShowTime = this.offset + (thisCache.width / thisSpeed);
    if (this.offset <= other.offset && other.offset <= thisFullShowTime) return true;

    if (thisSpeed == otherSpeed) return false;

    final x1 = otherSpeed * (this.offset - other.offset) - otherCache.width;
    if (x1 > 0) {
      final t1 = x1 / (thisSpeed - otherSpeed);
      if (0 <= t1 && t1 <= (drawWidth / thisSpeed)) return true;
    }

    final x2 = thisSpeed * (other.offset - this.offset) - thisCache.width;
    if (x2 > 0) {
      final t2 = x2 / (otherSpeed - thisSpeed);
      if (0 <= t2 && t2 <= (drawWidth / otherSpeed)) return true;
    }

    return false;
  }

  bool checkStaticLineDanmakuHit(Danmaku other, DanmakuConfig danmakuConfig) {
    final thisDanmakuStart = this.offset;
    final thisDanmakuEnd = this.offset + (this.duration * danmakuConfig.durationScale);
    final otherDanmakuStart = other.offset;
    final otherDanmakuEnd = other.offset + (other.duration * danmakuConfig.durationScale);
    return (otherDanmakuStart <= thisDanmakuStart && thisDanmakuStart <= otherDanmakuEnd) || (thisDanmakuStart <= otherDanmakuStart && otherDanmakuEnd <= thisDanmakuEnd);
  }
}