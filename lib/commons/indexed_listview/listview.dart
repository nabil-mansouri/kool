import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'layout_listener.dart';
import 'controller.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'padding.dart';
import 'options.dart';

class IndexedListView extends StatefulWidget {
  final IndexedListPosition position;
  final IndexedListViewOptions options;
  //
  final ScrollController scrollController;
  final IndexedListController controller;
  final Subject<int> onJumpToIndex;
  IndexedListView._internal(
      {Key key,
      this.position = IndexedListPosition.start,
      @required this.options,
      @required this.scrollController,
      @required this.onJumpToIndex,
      this.controller})
      : assert(onJumpToIndex != null, "missing onJumpToIndex"),
        super(key: key);
  factory IndexedListView.builder(
      {Key key,
      IndexedListPosition position = IndexedListPosition.start,
      ScrollController scrollController,
      IndexedListController controller,
      @required IndexedListViewOptions options,
      @required Subject<int> onJumpToIndex}) {
    return IndexedListView._internal(
      options: options,
      scrollController: scrollController,
      key: key,
      position: position,
      controller: controller,
      onJumpToIndex: onJumpToIndex,
    );
  }
  @override
  State<StatefulWidget> createState() {
    if (controller != null) {
      return IndexedListViewState.fromController(controller);
    }
    return IndexedListViewState.fromWidget(this);
  }
}

class IndexedListViewState extends State<IndexedListView> {
  final ScrollController scrollController;
  final bool customScrollController;
  final IndexedListController controller;
  IndexedListViewState._internal(
      {@required this.scrollController,
      @required this.customScrollController,
      @required this.controller})
      : assert(scrollController != null, "missing ScrollController"),
        assert(customScrollController != null, "is it a custom controller"),
        assert(controller != null, "missing IndexedListController");
  factory IndexedListViewState.fromWidget(IndexedListView widget) {
    var customScrollController = false;
    var scrollController = widget.scrollController;
    if (scrollController == null) {
      customScrollController = true;
      scrollController = new ScrollController();
    }
    var controller = widget.controller;
    if (controller == null) {
      controller = IndexedListController.build(widget.options.scrollDirection,
          widget.position, widget.options.itemCount, scrollController, 0);
    }
    return IndexedListViewState._internal(
        scrollController: scrollController,
        customScrollController: customScrollController,
        controller: controller);
  }
  factory IndexedListViewState.fromController(
      IndexedListController controller) {
    return IndexedListViewState._internal(
        scrollController: controller.controller,
        customScrollController: false,
        controller: controller);
  }
  initState() {
    super.initState();
    _init();
  }

  jumpTo(int index) {
    this.controller.jumpToIndex(index);
  }

  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != this.widget) {
      //reset listeners
      _init();
    }
  }

  StreamSubscription sub;
  _init() {
    sub?.cancel();
    sub = widget.onJumpToIndex.listen((index) {
      controller.jumpToIndex(index);
    });
  }

  IndexedListViewOptions get widgetOptions => widget.options;
  dispose() {
    if (customScrollController) {
      scrollController.dispose();
    }
    sub?.cancel();
    super.dispose();
  }

  _buildList(context) {
    var scrollController = controller.controller;
    return ListView.builder(
        //dont need to put controller if already attached to ancestor
        controller: customScrollController ? scrollController : null,
        itemBuilder: (context, index) {
          return LayoutListener(
              controller: this.controller,
              index: index,
              child: widgetOptions.itemBuilder(context, index));
        },
        scrollDirection: widgetOptions.scrollDirection,
        reverse: widgetOptions.reverse,
        primary: widgetOptions.primary,
        physics: widgetOptions.physics,
        shrinkWrap: widgetOptions.shrinkWrap,
        padding: widgetOptions.padding,
        itemExtent: widgetOptions.itemExtent,
        itemCount: widgetOptions.itemCount,
        addAutomaticKeepAlives: widgetOptions.addAutomaticKeepAlives,
        addRepaintBoundaries: widgetOptions.addRepaintBoundaries,
        addSemanticIndexes: widgetOptions.addSemanticIndexes,
        cacheExtent: widgetOptions.cacheExtent,
        semanticChildCount: widgetOptions.semanticChildCount);
  }

  build(context) {
    var padding = IndexedListViewPadding.of(context);
    if (padding != null) {
      controller.paddingStart = padding.padding;
    }
    return _buildList(context);
  }
}
