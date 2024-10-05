import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food/multiflow/multiflow.dart';
import 'package:food/commons/scroll/scroll.dart';
import '../../domain/domain.dart';
import 'header.dart';
import 'card.dart';
import 'view_model.dart';
import 'empty_result.dart';

class RestaurantListWidget extends StatelessWidget {
  final List<RestaurantModel> restaurants;
  final OnTapRestaurant onTap;
  final InfiniteScrollController controller;
  RestaurantListWidget(this.restaurants,
      {@required this.onTap, @required this.controller});

  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var count = this.restaurants.length;
    return SliverPadding(
        padding: EdgeInsets.symmetric(vertical: 16),
        sliver: InfiniteScrollView.sliverList(InfiniteScrollSliverOptions(
          addSemanticIndexes: false,
          controller: this.controller,
          distance: height * 0.75, //distance to trigger refresh
          itemBuilder: (context, index) {
            return RestaurantCard(this.restaurants[index], this.onTap);
          },
          itemCount: count,
        )));
  }
}

class RestaurantListContainer extends StatefulWidget {
  RestaurantListContainerState createState() => RestaurantListContainerState();
}

class RestaurantListContainerState extends State<RestaurantListContainer> {
  StreamSubscription subcription;
  StreamSubscription subcriptionLoadMoreStopped;
  final InfiniteScrollController infiniteController =
      new InfiniteScrollController(externalScroll: true);
  final RestaurantListViewModel listModel = RestaurantListViewModel();

  _onRefresh(data) {
    if (listModel.loadMoreReady) {
      listModel.loadMore(context);
    } else if (listModel.loadingMore) {
//DO NOTHING
    } else {
      infiniteController.stopRefresh();
    }
  }

  Widget _buildList(BuildContext context, RestaurantListViewModel model) {
    if (model.loadingFirst) {
      return SliverFillRemaining(
          child: Center(child: Center(child: CircularProgressIndicator())));
    } else if (model.hasRestaurants) {
      return RestaurantListWidget(model.restaurants,
          controller: infiniteController, onTap: (restau) {
        model.seeRestaurantDetails(context, restau);
      });
    } else {
      return SliverFillRemaining(child: RestaurantListEmptyResultWidget(
        onSell: () {
          //TODO
        },
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectedScopedModelBuilder<RestaurantListViewModel>.fromModel(
        model: listModel,
        builder: (context, model) {
          return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notif) {
                infiniteController.onNotification.add(notif);
              },
              child: CustomScrollView(
                slivers: <Widget>[
                  RestaurantListAppBarContainer(),
                  _buildList(context, model)
                ],
              ));
        });
  }

  _listenLoadMore(bool isLoadingMore) {
    if (!isLoadingMore) {
      infiniteController.stopRefresh();
    }
  }

  _init() {
    _cancel();
    subcriptionLoadMoreStopped =
        listModel.onLoadMoreChanged.listen(_listenLoadMore);
    subcription = infiniteController.onStartRefresh.listen(_onRefresh);
  }

  _cancel() {
    subcription?.cancel();
    subcriptionLoadMoreStopped?.cancel();
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    _cancel();
    this.infiniteController.dispose();
    super.dispose();
  }
}
