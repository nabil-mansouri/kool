import 'package:food/multiflow/multiflow.dart';
import 'package:flutter/material.dart';
import 'package:food/location/location.dart'; 
import 'view_model.dart';
import 'search_date.dart';
import 'search_location.dart';




class SearchButtonWidget extends StatelessWidget {
  final SearchViewModel model;
  SearchButtonWidget(this.model);
  build(context) {
    return RaisedButton(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text("RECHERCHER"),
      color: Theme.of(context).accentColor,
      disabledColor: Colors.grey.shade400,
      textColor: Colors.white,
      disabledTextColor: Colors.white,
      elevation: 4.0,
      onPressed: model.canSubmit
          ? () {
              model.submitSearch(context);
            }
          : null,
    );
  }
}

class RestaurantSearchWidget extends StatelessWidget {
  final SearchViewModel model;
  RestaurantSearchWidget(this.model);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        bottomNavigationBar: SearchButtonWidget(model),
        appBar: AppBar(
          title: Text("Détails de livraison"),
        ),
        //Use singlechild scrollview to avoid overflow error when keyboard is open
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: <Widget>[
                  RestaurantLocationWidget(model),
                  Container(color: Colors.white, child: Divider()),
                  LocationRecentContainer(
                      limitRecent: 3,
                      selectedPlace: model.location.localElseState,
                      onSelect: (place) => model.selectLocation(place)),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: RestaurantSearchDateWidget(model)),
                ],
              )),
        ));
  }
}

class RestaurantSearchContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectedScopedModelBuilder<SearchViewModel>.fromFactory(
        modelFactory: () => SearchViewModel(),
        builder: (context, model) {
          return RestaurantSearchWidget(model);
        });
  }
}
