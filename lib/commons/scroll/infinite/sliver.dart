import 'package:flutter/material.dart';
import 'controller.dart';
import 'base.dart';

int _kDefaultSemanticIndexCallback(Widget _, int localIndex) => localIndex;

class InfiniteScrollSliverOptions implements InfiniteScrollBaseOptions {
  final InfiniteScrollController controller;
  final double distance;
  //
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final int semanticIndexOffset;
  final SemanticIndexCallback semanticIndexCallback;
  InfiniteScrollSliverOptions(
      {@required this.distance,
      @required this.controller,
      @required this.itemBuilder,
      @required this.itemCount,
      this.addAutomaticKeepAlives = true,
      this.addRepaintBoundaries = true,
      this.addSemanticIndexes = true,
      this.semanticIndexOffset = 0,
      this.semanticIndexCallback = _kDefaultSemanticIndexCallback});
}

class InfiniteScrollViewStateful
    extends InfiniteScrollViewBaseWidget<InfiniteScrollSliverOptions> {
  InfiniteScrollViewStateful(InfiniteScrollSliverOptions options)
      : super(options);
  @override
  State<StatefulWidget> createState() {
    return InfiniteScrollSliverListState();
  }
}

class InfiniteScrollSliverListState
    extends State<InfiniteScrollViewBaseWidget<InfiniteScrollSliverOptions>>
    with InifiniteScrollViewStateMixins<InfiniteScrollSliverOptions> {
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
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      if (isIndicatorVisible(index)) {
        return InfiniteScrollViewIndicator();
      }
      return widgetOptions.itemBuilder(context, index);
    },
            addAutomaticKeepAlives: widgetOptions.addAutomaticKeepAlives,
            addRepaintBoundaries: widgetOptions.addRepaintBoundaries,
            addSemanticIndexes: widgetOptions.addSemanticIndexes,
            childCount: itemCount,
            semanticIndexCallback: widgetOptions.semanticIndexCallback,
            semanticIndexOffset: widgetOptions.semanticIndexOffset));
  }
}
