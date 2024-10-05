import 'package:flutter/material.dart';
import 'package:food/location/location.dart';
import 'package:flutter/cupertino.dart';
import 'view_model.dart';

class RestaurantLocationWidget extends StatelessWidget {
  final SearchViewModel model;
  RestaurantLocationWidget(this.model);
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            ListTile(
                title: Text("Lieu de livraison",
                    style: TextStyle(fontSize: 14, color: Colors.black54))),
            LocationFakeSearchInput(
                onTap: () {
                  showModalSearchContainer(context,
                      closeOnSelect: true,
                      onSelect: (place) => model.selectLocation(place));
                },
                placeholder: "Saisissez une nouvelle adresse")
          ],
        ));
  }
}
