import 'dart:collection';

import 'package:fl_danmaku_widget/danmaku/danmaku.dart';

class Danmakus extends SetBase<Danmaku> {
  final _danmakuSet = <Danmaku>[];

  @override
  bool add(Danmaku value) {
    _danmakuSet.add(value);
    return true;
  }

  @override
  bool contains(Object? element) => _danmakuSet.contains(element);

  @override
  Iterator<Danmaku> get iterator => _danmakuSet.iterator;

  @override
  int get length => _danmakuSet.length;

  @override
  Danmaku? lookup(Object? element) {
    // TODO: implement lookup
    throw UnimplementedError();
  }

  @override
  bool remove(Object? value) => _danmakuSet.remove(value);

  @override
  Set<Danmaku> toSet() => _danmakuSet.toSet();

  int get duration => last.offset;

  @override
  Danmaku get last {
    Danmaku? last;
    for (var danmaku in this) {
      last ??= danmaku;
      if (last.offset < danmaku.offset) {
        last = danmaku;
      }
    }
    if (last == null) {
      throw StateError("No elements");
    }
    return last;
  }

  @override
  Danmaku get first {
    Danmaku? first;
    for (var danmaku in this) {
      first ??= danmaku;
      if (first.offset > danmaku.offset) {
        first = danmaku;
      }
    }
    if (first == null) {
      throw StateError("No elements");
    }
    return first;
  }

  Danmakus sub(int start, int end) {
    var subDanmakus = Danmakus();
    for (var danmaku in this) {
      if (danmaku.offset >= start && danmaku.offset <= end) {
        subDanmakus.add(danmaku);
      }
    }
    return subDanmakus;
  }
}