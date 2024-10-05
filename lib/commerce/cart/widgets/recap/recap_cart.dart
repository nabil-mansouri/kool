import 'package:flutter/material.dart';
import 'view_model.dart';
import 'recap_cart_row.dart';
import 'package:food/commons/custom_input.dart';

class RecapCartWidget extends StatelessWidget {
  final RecapViewModel model;
  RecapCartWidget(this.model);

  _buildTitle() {
    return ListTile(
        title: Text("Récapitulatif de la commande",
            style: TextStyle(color: Colors.black54, fontSize: 14)));
  }

  _buildTotal() {
    return ListTile(
      title: Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
      trailing:
          Text(model.total, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(_buildTitle());
    children.addAll(
        this.model.rows.map((row) => RecapRowWidget(model, row)).toList());
    children.add(Divider());
    children.add(CustomInputWidget(
        autocorrect: false,
        controller: model.promoController,
        hintText: 'Ajoutez un code promo...'));
    children.add(Divider());
    children.add(CustomInputWidget(
        autocorrect: true,
        maxLines: 3,
        controller: model.commentController,
        hintText: 'Ajoutez une instructions...'));
    children.add(Divider());
    children.add(_buildTotal());
    return Padding(
      child: Container(
          color: Colors.white,
          child: Column(
            children: children,
          )),
      padding: EdgeInsets.symmetric(vertical: 12),
    );
  }
}
