import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'view_model.dart';
import 'search_datepicker.dart';

class RestaurantSearchDateWidget extends StatelessWidget {
  final SearchViewModel model;
  RestaurantSearchDateWidget(this.model);
  _selectIcon(bool isSelected) {
    return isSelected
        ? Icon(Icons.check, color: Colors.greenAccent.shade700)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(ListTile(
        title: Text("Date de livraison",
            style: TextStyle(fontSize: 14, color: Colors.black54))));
    children.add(ListTile(
      onTap: () => model.selectNowDate(),
      leading: Icon(Icons.alarm),
      title: Text("Maintenant"),
      trailing: _selectIcon(model.hasNowDate),
    ));
    if (model.hasCustomDate) {
      children.add(ListTile(
        onTap: () {},
        leading: Icon(Icons.alarm),
        title: Text("${model.customDate}"),
        trailing: _selectIcon(model.hasCustomDate),
      ));
    }
    children.add(ListTile(
      onTap: () {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return RestaurantDatePickerWidget(model);
            });
      },
      leading: Icon(Icons.date_range),
      title: Text("Choisir une autre date"),
    ));
    return Container(
        color: Colors.white,
        child: Column(
          children: children,
        ));
  }
}
