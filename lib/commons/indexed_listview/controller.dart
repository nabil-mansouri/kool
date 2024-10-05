import 'package:flutter/widgets.dart';
import 'dart:math';

///
enum IndexedListPosition { start, end, nearStart, nearEnd }

abstract class _AxisStratgy {
  double getValue(Size size);
}

class _AxisStratgy$Horizontal extends _AxisStratgy {
  double getValue(Size size) {
    return size.width;
  }
}

class _AxisStratgy$Vertical extends _AxisStratgy {
  double getValue(Size size) {
    return size.height;
  }
}

//
abstract class _PositionStratgy {
  int lastIndex(int index);
  double fixOffset({double offset, double size, ScrollController controller});
  bool offsetIsInRange({double offset, double min, double max});
}

class _PositionStratgy$Start extends _PositionStratgy {
  int lastIndex(int index) {
    return index - 1;
  }

  double fixOffset({double offset, double size, ScrollController controller}) {
    return offset;
  }

  bool offsetIsInRange({double offset, double min, double max}) {
    return min <= offset && offset < max;
  }
}

class _PositionStratgy$End extends _PositionStratgy {
  int lastIndex(int index) {
    return index;
  }

  double fixOffset({double offset, double size, ScrollController controller}) {
    return offset - controller.position.extentInside;
  }

  bool offsetIsInRange({double offset, double min, double max}) {
    return max <= offset;
  }
}

class _PositionStratgy$Near extends _PositionStratgy {
  _PositionStratgy inner;
  _PositionStratgy$Near(this.inner);
  int lastIndex(int index) {
    return this.inner.lastIndex(index);
  }

  double fixOffset({double offset, double size, ScrollController controller}) {
    const PADDING = 16;
    var startVisible = controller.position.extentBefore + PADDING;
    var endVisible = controller.position.extentBefore +
        controller.position.extentInside -
        PADDING;
    var startObject, endObject;
    if (inner is _PositionStratgy$End) {
      startObject = offset - size;
      endObject = offset;
    } else {
      startObject = offset;
      endObject = offset + size;
    }
    //
    if (startObject < startVisible) {
      //object is before startVisible
      var distance = startVisible - startObject;
      //print(
      //    "object is before offset=$offset start=$startObject visibleStart=$startVisible distance=$distance");
      return offset - distance;
    } else if (endVisible < endObject) {
      //object is after end visible
      var distance = endVisible - endObject;
      //print(
      //    "object is after offset=$offset end=$endObject visibleEnd=$endVisible distance=$distance");
      return offset + distance;
    } else {
      //object is contains inside visible range
      //print(
      //    "object is between offset=$offset start=$startObject visibleStart=$startVisible end=$endObject visibleEnd=$endVisible");
      return offset;
    }
  }

  bool offsetIsInRange({double offset, double min, double max}) {
    return this.inner.offsetIsInRange(offset: offset, min: min, max: max);
  }
}

///
class IndexedListController {
  final Map<int, double> _sizesByIndex = {};
  final _AxisStratgy _axisStrategy;
  final _PositionStratgy _posStrategy;
  final ValueNotifier<int> _count;
  final ScrollController controller;
  double paddingStart;
  IndexedListController._internal(this._axisStrategy, this._posStrategy,
      ValueNotifier<int> count, this.controller, this.paddingStart)
      : _count = count,
        assert(paddingStart != null, "missing paddingStart"),
        assert(_axisStrategy != null, "missing _AxisStratgy"),
        assert(_posStrategy != null, "missing _PositionStratgy"),
        assert(count != null, "missing _count"),
        assert(controller != null, "missing ScrollController");
  factory IndexedListController.build(Axis axis, IndexedListPosition pos,
      int count, ScrollController controller, double paddingStart) {
    _AxisStratgy stAxis;
    switch (axis) {
      case Axis.horizontal:
        stAxis = _AxisStratgy$Horizontal();
        break;
      case Axis.vertical:
        stAxis = _AxisStratgy$Vertical();
        break;
    }
    _PositionStratgy stPos;
    switch (pos) {
      case IndexedListPosition.start:
        stPos = _PositionStratgy$Start();
        break;
      case IndexedListPosition.nearStart:
        stPos = _PositionStratgy$Near(_PositionStratgy$Start());
        break;
      case IndexedListPosition.nearEnd:
        stPos = _PositionStratgy$Near(_PositionStratgy$End());
        break;
      case IndexedListPosition.end:
        stPos = _PositionStratgy$End();
        break;
    }
    return IndexedListController._internal(
        stAxis, stPos, ValueNotifier(count), controller, paddingStart);
  }
  setSize({Size currentSize, int index, Size previousSize}) {
    _sizesByIndex[index] = this._axisStrategy.getValue(currentSize);
  }

  double getOffsetForIndex(int index) {
    int i = 0;
    double offset = 0;
    int count = this._count.value;
    int last = this._posStrategy.lastIndex(index);
    while (i <= last && i < count) {
      offset += _sizesByIndex[i] ?? 0;
      i++;
    }
    var res = this._posStrategy.fixOffset(
        offset: offset, size: _sizesByIndex[i], controller: controller);
    //print("jump to index $index => $offset => $res ");
    return res;
  }

  void jumpToIndex(int index) {
    double offset = this.getOffsetForIndex(index);
    offset += paddingStart;
    var current = controller.position.pixels;
    double distance = (offset - current).abs();
    double maxDistance = controller.position.maxScrollExtent;
    double ratio = distance / maxDistance;
    int timeMs = (200 + 100 * ratio).toInt();
    //
    offset = min(max(offset, controller.position.minScrollExtent),
        controller.position.maxScrollExtent);
    controller.animateTo(offset,
        duration: Duration(milliseconds: timeMs), curve: Curves.easeInOut);
  }

  int indexForOffset(double offset) {
    int count = this._count.value;
    if (count > 0) {
      int i = 0;
      double min = 0;
      double max = 0;
      while (i < count) {
        min = max;
        max += _sizesByIndex[i];
        if (this
            ._posStrategy
            .offsetIsInRange(offset: offset, min: min, max: max)) {
          return i;
        }
        i++;
      }
    }
    return 0;
  }

  get count => this._count.value;
}
