import 'dart:async';
import 'package:flutter/material.dart';
import 'controller.dart';


class InfiniteScrollBaseOptions {
  final InfiniteScrollController controller;
  final double distance;
  final int itemCount;
  InfiniteScrollBaseOptions(
      {@required this.controller,
      @required this.distance,
      @required this.itemCount});
}

class InfiniteScrollViewIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      child: CircularProgressIndicator(),
      padding: EdgeInsets.only(top: 8, bottom: 16),
    ));
  }
}

abstract class InfiniteScrollViewBaseWidget<
    OPTIONS extends InfiniteScrollBaseOptions> extends StatefulWidget {
  final OPTIONS options;
  InfiniteScrollViewBaseWidget(this.options);
}

mixin InifiniteScrollViewStateMixins<OPTIONS extends InfiniteScrollBaseOptions>
    implements State<InfiniteScrollViewBaseWidget<OPTIONS>> {
  //
  bool _isLoadingMoreBottom = false;
  int _nbRefresh = 0;
  StreamSubscription subcription;
  StreamSubscription subcriptionNotif;
  OPTIONS get widgetOptions => widget.options;
  int get nbRefresh => this._nbRefresh;
  init() {
    cancel();
    subcription = widgetOptions.controller.refreshStateEvent.listen(onData);
    subcriptionNotif =
        widgetOptions.controller.onNotification.listen(listenScrollDown);
  }

  cancel() {
    subcription?.cancel();
    subcriptionNotif?.cancel();
  }

  onData(data) {
    setState(() {
      _isLoadingMoreBottom = data;
      if (data) _nbRefresh++;
    });
  }

  listenScrollDown(ScrollNotification notif) {
    if (_isLoadingMoreBottom) {
      return;
    }
    if (notif.metrics.axisDirection != AxisDirection.down) {
      return;
    }
    if (!(notif is UserScrollNotification)) {
      return;
    }
    //
    //print("remaining scroll ${notif.metrics.extentAfter} / ${widget.distance}");
    if (notif.metrics.extentAfter <= widgetOptions.distance) {
      if (widgetOptions.controller != null) {
        _isLoadingMoreBottom = true; //force lock refresh
        //print(
        //    "start refresh scroll ${notif.metrics.extentAfter} / ${widget.distance}");
        setState(() {
          _isLoadingMoreBottom = true;
          _nbRefresh++;
        });
        widgetOptions.controller.onStartRefresh.add(true);
      }
    }
  }

  get isLoading => _isLoadingMoreBottom;
  Widget buildList(int itemCount);
  Widget build(BuildContext context) {
    var itemCount =
        isLoading ? widgetOptions.itemCount + 1 : widgetOptions.itemCount;
    if (widgetOptions.controller.externalScroll) {
      return buildList(itemCount);
    } else {
      return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notif) {
            listenScrollDown(notif);
          },
          child: buildList(itemCount));
    }
  }

  bool isIndicatorVisible(int index) {
    return isLoading && index >= widgetOptions.itemCount;
  }
}
