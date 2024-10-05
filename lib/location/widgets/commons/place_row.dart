import 'package:flutter/material.dart';
import '../../domain/domain.dart';
import 'current_place.dart';

class GeoPlaceRow extends StatelessWidget {
  final GeoPlace place;
  final OnSelect onSelect;
  final bool isSelected;
  GeoPlaceRow(
      {@required this.place,
      @required this.onSelect,
      @required this.isSelected});
  build(BuildContext context) {
    return ListTile(
      onTap: () => onSelect(place),
      title: Text(place.formattedAdresssPart),
      subtitle: Text(place.formattedCityPart),
      leading: Icon(Icons.location_on),
      trailing: isSelected
          ? Icon(Icons.check, color: Colors.greenAccent.shade700)
          : null,
    );
  }
}
