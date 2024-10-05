import 'package:flutter/material.dart';
import '../../domain/domain.dart';

typedef OnSelect = void Function(GeoPlace place);
typedef AskPerm = void Function();

class CurrentGeoPlaceRow extends StatelessWidget {
  bool get hasCurrent => this.current != null;
  final GeoPlace current;
  final OnSelect onSelect;
  final bool isSelected;
  final bool needPerms;
  final AskPerm askPerms;
  CurrentGeoPlaceRow(
      {@required this.current,
      @required this.onSelect,
      @required this.isSelected,
      @required this.needPerms,
      @required this.askPerms});
  build(BuildContext context) {
    if (hasCurrent) {
      return ListTile(
        onTap: () => onSelect(current),
        title: Text("Lieu Actuel"),
        subtitle: Text(current?.formattedAddress),
        leading: Icon(Icons.my_location),
        trailing: isSelected
            ? Icon(Icons.check, color: Colors.greenAccent.shade700)
            : null,
      );
    } else if (needPerms) {
      return ListTile(
        onTap: () => askPerms(),
        title: Text("Localisation impossible"),
        subtitle: Text("Autoriser l'application à accèder à ma position."),
        leading: Icon(Icons.my_location),
        trailing: Icon(Icons.touch_app),
      );
    } else {
      return ListTile(
          title: Text("Lieu Actuel"),
          subtitle: Text("Localisation en cours..."),
          leading: Padding(
              padding: EdgeInsets.only(top: 12),
              child: SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator())));
    }
  }
}
