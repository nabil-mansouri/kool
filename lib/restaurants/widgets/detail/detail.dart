import 'package:flutter/material.dart';
import 'package:food/multiflow/multiflow.dart';
import 'dart:math';
import 'package:food/commons/indexed_listview/indexed_listview.dart';
import "package:food/commerce/commerce.dart";
import '../commons/commons.dart';
import 'header_tab.dart';
import 'body_list.dart';
import 'view_model.dart';

class RestaurantDetailBodyWidget extends StatelessWidget {
  final RestaurantDetailViewModel model;
  RestaurantDetailBodyWidget(this.model);
  build(context) {
    if (model.ready) {
      return SliverList(
          delegate: SliverChildListDelegate([
        Padding(
            padding: EdgeInsets.only(top: 12),
            child: RestaurantLocationInfo(model?.current)),
        Divider(),
        DetailProductList(this.model)
      ]));
    } else {
      return SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()));
    }
  }
}

class RestaurantDetailWidget extends StatelessWidget {
  final RestaurantDetailViewModel model;
  RestaurantDetailWidget(this.model);

  build(context) {
    var paddingTop = MediaQuery.of(context).padding.top;
    var width = MediaQuery.of(context).size.width;
    var height = width * 0.8;
    var minExtent = kToolbarHeight * 2 + paddingTop;
    var maxExtent = max(minExtent, height);
    var rowBottomPadding = 18;
    return IndexedListViewPadding(
        //add max extent to scroll offset - remove min extent (because it is still visible) and add row bottom padding
        padding: maxExtent - minExtent + rowBottomPadding,
        child: Scaffold(
            floatingActionButton: CartButtonContainer(),
            body: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notif) {
                  model.onNotification.add(notif);
                },
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverPersistentHeader(
                        floating: false,
                        pinned: true,
                        delegate: RestaurantPersistentHeader(
                            model: model?.current,
                            minExtent: minExtent,
                            maxExtent: maxExtent,
                            paddingTop: paddingTop,
                            bottom: RestaurantTabScrollView(model))),
                    RestaurantDetailBodyWidget(model)
                  ],
                ))));
  }
}

class RestaurantDetailScreen extends StatelessWidget {
  build(context) {
    return ConnectedScopedModelBuilder<RestaurantDetailViewModel>.fromModel(
      model: RestaurantDetailViewModel(),
      builder: (context, model) {
        return RestaurantDetailWidget(model);
      },
    );
  }
}
