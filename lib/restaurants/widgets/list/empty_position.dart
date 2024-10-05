import 'package:flutter/material.dart';
import 'package:food/location/location.dart';
import 'package:food/multiflow/multiflow.dart';
import 'view_model.dart';

class RestaurantListEmptyPositionWidget extends StatelessWidget {
  final EmptyListViewModel model;
  RestaurantListEmptyPositionWidget(this.model);

  Widget build(BuildContext context) {
    final MaterialColor mainColor = Theme.of(context).primaryColor;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 64),
          child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: viewportConstraints.maxHeight * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Flexible(
                    child: Icon(Icons.location_on,
                        color: mainColor.shade400, size: 108),
                    fit: FlexFit.tight,
                    flex: 2,
                  ),
                  Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Votre position",
                            style: TextStyle(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 24),
                          ),
                          Text(
                            "Nous recherchons les produits et les restaurants à proximité en nous basant sur votre position.",
                            style: TextStyle(
                                height: 1.2, color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                      flex: 1),
                  Flexible(
                      child: RaisedButton(
                          color: mainColor.shade500,
                          child: Text(
                            "INDIQUER MA POSITION",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            showModalSearchContainer(context,
                                closeOnSelect: true,
                                onSelect: (place) => model.submitSearch(place));
                          }),
                      flex: 2),
                ],
              )));
    });
  }
}

class RestaurantListEmptyPositionContainer extends StatelessWidget {
  final EmptyListViewModel model = EmptyListViewModel();
  Widget build(BuildContext context) {
    return ConnectedScopedModelBuilder<EmptyListViewModel>.fromModel(
        model: model,
        builder: (context, model) {
          return RestaurantListEmptyPositionWidget(model);
        });
  }
}
