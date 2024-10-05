import 'package:flutter/widgets.dart';
import 'package:food/commons/indexed_listview/indexed_listview.dart';
import 'package:rxdart/rxdart.dart';
import 'controller.dart';

class IndexedListViewTracked extends StatefulWidget {
  final IndexedListPosition position;
  final ScrollController scrollController;
  final IndexedListViewOptions options;
  //
  final bool externalNotification;
  final Observable<ScrollNotification> onNotification;
  final OnReachedCallback onIndexReached;
  final Subject<int> onJumpToIndex;
  IndexedListViewTracked._internal(
      {Key key,
      this.position = IndexedListPosition.start,
      this.options,
      this.scrollController,
      this.externalNotification,
      this.onNotification,
      this.onIndexReached,
      this.onJumpToIndex})
      : assert(externalNotification != null, "is it external notification"),
        assert(!externalNotification || onNotification != null,
            "missing notification emitter"),
        assert(onIndexReached != null, "missing index reached callback"),
        assert(onJumpToIndex != null, "missing onJumpToIndex"),
        super(key: key);
  factory IndexedListViewTracked.builder(
      {Key key,
      IndexedListPosition position = IndexedListPosition.start,
      ScrollController scrollController,
      Subject<ScrollNotification> onNotification,
      OnReachedCallback onIndexReached,
      @required IndexedListViewOptions options,
      @required Subject<int> onJumpToIndex}) {
    return IndexedListViewTracked._internal(
        scrollController: scrollController,
        key: key,
        position: position,
        options: options,
        externalNotification: onNotification != null,
        onNotification: onNotification,
        onIndexReached: onIndexReached,
        onJumpToIndex: onJumpToIndex);
  }
  createState() => IndexedListViewTrackedState.fromWidget(this);
}

class IndexedListViewTrackedState extends State<IndexedListViewTracked> {
  final IndexedListTrackedController trackController;
  final bool customScrollController;
  final bool customNotification;
  IndexedListViewTrackedState._internal(
      {@required this.trackController,
      @required this.customScrollController,
      @required this.customNotification})
      : assert(customNotification != null, "is it custom notification?"),
        assert(
            customScrollController != null, "is it a custom scroll controller");
  factory IndexedListViewTrackedState.fromWidget(
      IndexedListViewTracked widget) {
    var customScrollController = false;
    var scrollController = widget.scrollController;
    if (scrollController == null) {
      customScrollController = true;
      scrollController = new ScrollController();
    }
    var onNotification = widget.onNotification;
    var customNotification = false;
    if (onNotification == null) {
      onNotification = PublishSubject();
      customNotification = true;
    }
    return IndexedListViewTrackedState._internal(
        customScrollController: customScrollController,
        customNotification: customNotification,
        trackController: IndexedListTrackedController.build(
            reachedIndex: widget.onIndexReached,
            onNotification: onNotification,
            axis: widget.options.scrollDirection,
            pos: widget.position,
            count: widget.options.itemCount,
            controller: scrollController,
            paddingStart: 0));
  }
  Widget buildList(BuildContext context) {
    return IndexedListView.builder(
        onJumpToIndex: widget.onJumpToIndex,
        controller: trackController,
        scrollController: widget.scrollController,
        key: widget.key,
        position: widget.position,
        options: widget.options);
  }

  Widget build(BuildContext context) {
    if (widget.externalNotification) {
      return this.buildList(context);
    } else {
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          trackController.onNotification.add(notification);
        },
        child: this.buildList(context),
      );
    }
  }

  initState() {
    super.initState();
    trackController.startListen();
  }

  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (this.widget != oldWidget) {
      trackController.stopListen();
      trackController.startListen();
    }
  }

  dispose() {
    super.dispose();
    trackController.stopListen();
    if (customNotification) {
      trackController.onNotification.close();
    }
  }
}
