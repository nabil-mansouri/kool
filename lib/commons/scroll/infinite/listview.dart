import 'package:flutter/material.dart';
import 'controller.dart';
import 'base.dart';

class InfiniteScrollListViewOptions implements InfiniteScrollBaseOptions {
  final InfiniteScrollController controller;
  final double distance;
  //
  final Axis scrollDirection;
  final bool reverse;
  final bool primary;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry padding;
  final double itemExtent;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double cacheExtent;
  final int semanticChildCount;
  InfiniteScrollListViewOptions(
      {@required this.distance,
      @required this.controller,
      @required this.itemBuilder,
      @required this.itemCount,
      this.scrollDirection = Axis.vertical,
      this.reverse = false,
      this.primary,
      this.physics,
      this.shrinkWrap = false,
      this.padding,
      this.itemExtent,
      this.addAutomaticKeepAlives = true,
      this.addRepaintBoundaries = true,
      this.addSemanticIndexes = true,
      this.cacheExtent,
      this.semanticChildCount});
}

class InfiniteScrollListViewStateful
    extends InfiniteScrollViewBaseWidget<InfiniteScrollListViewOptions> {
  InfiniteScrollListViewStateful(InfiniteScrollListViewOptions options)
      : super(options);
  @override
  State<StatefulWidget> createState() {
    return InfiniteScrollListViewState();
  }
}

class InfiniteScrollListViewState
    extends State<InfiniteScrollViewBaseWidget<InfiniteScrollListViewOptions>>
    with InifiniteScrollViewStateMixins<InfiniteScrollListViewOptions> {
  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void didUpdateWidget(InfiniteScrollViewBaseWidget oldWidget) {
    if (widget != oldWidget) init();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  buildList(int itemCount) {
    //print("is loading $isLoading : ${widget.itemCount} / $itemCount");
    return ListView.builder(
        itemBuilder: (context, index) {
          if (isIndicatorVisible(index)) {
            return InfiniteScrollViewIndicator();
          }
          return widgetOptions.itemBuilder(context, index);
        },
        scrollDirection: widgetOptions.scrollDirection,
        reverse: widgetOptions.reverse,
        primary: widgetOptions.primary,
        physics: widgetOptions.physics,
        shrinkWrap: widgetOptions.shrinkWrap,
        padding: widgetOptions.padding,
        itemExtent: widgetOptions.itemExtent,
        itemCount: itemCount,
        addAutomaticKeepAlives: widgetOptions.addAutomaticKeepAlives,
        addRepaintBoundaries: widgetOptions.addRepaintBoundaries,
        addSemanticIndexes: widgetOptions.addSemanticIndexes,
        cacheExtent: widgetOptions.cacheExtent,
        semanticChildCount: widgetOptions.semanticChildCount);
  }
}
