import 'package:flutter/material.dart';
import '../styles.dart';
import '../../domain/domain.dart';
import 'view_model.dart';

class RestaurantInfoRowWidget extends StatelessWidget {
  final RestaurantModel current;
  RestaurantInfoRowWidget(this.current, {Key key}) : super(key: key);
  build(context) {
    return Column(
      children: <Widget>[
        ListTile(
            leading: Icon(Icons.info_outline, color: Colors.black54),
            title: Text("Voir les horaires du restaurant",
                style: TextStyle(color: Colors.black))),
        Divider(height: 2)
      ],
    );
  }
}

class ProductCategoryRowWidget extends StatelessWidget {
  final RestaurantDetailRowViewModel row;
  ProductCategoryRowWidget(this.row, {Key key}) : super(key: key);
  build(context) {
    var temp = Text(row.category, style: TextStyles.title20);
    if (row.firstRow || row.lastRow) {
      return Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: temp);
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Divider(),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: temp)
        ]);
  }
}
