import 'package:flutter/material.dart';
import '../../domain/domain.dart';

class RestaurantLocationInfo extends StatelessWidget {
  final RestaurantModel model;
  RestaurantLocationInfo(this.model);
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(this.model.address), leading: Icon(Icons.location_on));
  }
}
