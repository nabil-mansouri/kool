import 'package:flutter/material.dart';
import 'package:food/multiflow/multiflow.dart';
import 'view_model.dart';

class RestaurantListAppBarWidget extends StatelessWidget {
  final RestaurantListAppBarViewModel model;
  RestaurantListAppBarWidget(this.model);
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
        automaticallyImplyLeading: false,
        pinned: model.hasRestaurant ? false : true,
        floating: true,
        forceElevated: true,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: <Widget>[
          IconButton(
              onPressed: () {
                model.openSearchView(context);
              },
              icon: Icon(Icons.filter_list))
        ],
        title: Text(
            "${model.currentDelayFormat} \u27A1 ${model.currentLocationFormat}",
            style: TextStyle(fontSize: 14, color: Colors.white)));
  }
}

class RestaurantListAppBarContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectedScopedModelBuilder<RestaurantListAppBarViewModel>.fromModel(
        model: RestaurantListAppBarViewModel(),
        builder: (context, model) {
          return RestaurantListAppBarWidget(model);
        });
  }
}
