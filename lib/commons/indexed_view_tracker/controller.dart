import 'package:food/commons/indexed_listview/indexed_listview.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

typedef void OnReachedCallback(int index);

class IndexedListTrackedController implements IndexedListController {
  final IndexedListController _inner;
  final ValueNotifier<bool> disableJump = ValueNotifier(false);
  final Subject<ScrollNotification> onNotification;
  final OnReachedCallback reachedIndex;
  StreamSubscription subListen;
  StreamSubscription subListenUser;
  get paddingStart => _inner.paddingStart;
  set paddingStart(a) => _inner.paddingStart = a;
  IndexedListTrackedController._internal(
      {@required this.onNotification,
      @required this.reachedIndex,
      @required IndexedListController inner})
      : _inner = inner,
        assert(inner != null, "missing inner IndexedListController"),
        assert(onNotification != null, "missing onNotification emitter"),
        assert(reachedIndex != null, 'missing reached index callback');
  factory IndexedListTrackedController.build(
      {@required Axis axis,
      @required IndexedListPosition pos,
      @required int count,
      @required ScrollController controller,
      @required final Observable<ScrollNotification> onNotification,
      @required OnReachedCallback reachedIndex,
      @required double paddingStart}) {
    var inner =
        IndexedListController.build(axis, pos, count, controller, paddingStart);
    return IndexedListTrackedController._internal(
        onNotification: onNotification,
        reachedIndex: reachedIndex,
        inner: inner);
  }
  get controller => _inner.controller;
  get count => _inner.count;
  startListen() {
    this.subListen = onNotification.listen((notification) {
      if (notification is ScrollStartNotification) {
        disableJump.value = true;
      } else if (notification is ScrollEndNotification) {
        disableJump.value = false;
      }
    });
    this.subListenUser = onNotification
        .where((test) => test is UserScrollNotification)
        .debounce(Duration(microseconds: 150))
        .listen((notification) {
      _listenNotification(notification);
    });
  }

  stopListen() {
    this.subListen?.cancel();
    this.subListenUser?.cancel();
  }

  _listenNotification(ScrollNotification scroll) {
    //if max scrool reached => go to last index
    if (scroll.metrics.pixels == scroll.metrics.maxScrollExtent) {
      reachedIndex(this.count);
    } //if minextent reached => go to 0
    else if (scroll.metrics.pixels == scroll.metrics.minScrollExtent) {
      reachedIndex(0);
    } else {
      var index = _inner.indexForOffset(scroll.metrics.pixels);
      reachedIndex(index);
    }
  }

  void jumpToIndex(int index) {
    if (this.disableJump.value) {
      return;
    }
    this._inner.jumpToIndex(index);
  }

  setSize({Size currentSize, int index, Size previousSize}) {
    return _inner.setSize(
        currentSize: currentSize, index: index, previousSize: previousSize);
  }

  double getOffsetForIndex(int index) {
    return _inner.getOffsetForIndex(index);
  }

  int indexForOffset(double offset) {
    return _inner.indexForOffset(offset);
  }
}
