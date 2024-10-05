import 'package:flutter/material.dart';
import 'base.dart';
import 'listview.dart';
import 'sliver.dart';
export 'listview.dart';
export 'sliver.dart';
export 'controller.dart';

typedef InfiniteScrollViewBaseWidget InfiniteStatefulBuilder();

class InfiniteScrollView extends StatelessWidget {
  final InfiniteStatefulBuilder widgetBuilder;
  InfiniteScrollView._internal({Key key, @required this.widgetBuilder})
      : super(key: key);
  build(context) {
    return widgetBuilder();
  }

  factory InfiniteScrollView.listView(
    InfiniteScrollListViewOptions options, {
    Key key,
  }) {
    return InfiniteScrollView._internal(
        key: key, widgetBuilder: () => InfiniteScrollListViewStateful(options));
  }

  factory InfiniteScrollView.sliverList(
    InfiniteScrollSliverOptions options, {
    Key key,
  }) {
    return InfiniteScrollView._internal(
        key: key, widgetBuilder: () => InfiniteScrollViewStateful(options));
  }
}
