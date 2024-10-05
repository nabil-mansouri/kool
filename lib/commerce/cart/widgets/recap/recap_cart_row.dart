import 'package:flutter/material.dart';
import 'view_model.dart';

class RecapRowWidget extends StatelessWidget {
  final RecapViewModel model;
  final RecapRowViewModel row;
  RecapRowWidget(this.model, this.row);
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Text(
        row.title,
        style: TextStyle(fontSize: 16),
      )
    ];
    for (String detail in row.details) {
      children.add(Text(
        detail,
        style: TextStyle(color: Colors.black87, fontSize: 12),
      ));
    }
    return InkWell(
        splashColor: Theme.of(context).primaryColor,
        onTap: () {
          model.editCartItem(context, row.item);
        },
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 6, bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 48,
                child: Text(
                  row.quantity.toString() + " x",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children)),
              SizedBox(
                width: 64,
                child: Text(
                  row.price,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 14),
                ),
              )
            ],
          ),
        ));
  }
}
