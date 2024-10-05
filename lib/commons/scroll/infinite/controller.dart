import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class InfiniteScrollController {
  final bool externalScroll;
  final Subject<ScrollNotification> onNotification =
      PublishSubject<ScrollNotification>();
  final Subject<Object> onStartRefresh = PublishSubject<Object>();
  final Subject<bool> refreshStateEvent = PublishSubject<bool>();
  InfiniteScrollController({@required this.externalScroll});
  stopRefresh() {
    this.refreshStateEvent.add(false);
  }

  startRefresh() {
    this.refreshStateEvent.add(true);
  }

  dispose() {
    onNotification.close();
    onStartRefresh.close();
    refreshStateEvent.close();
  }
}
