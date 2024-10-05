import 'package:flutter/material.dart';
import 'product_row.dart';
import '../domains/domain.dart';

class ProductRowSelectable extends StatelessWidget {
  final ProductModel model;
  final GestureTapCallback onTap;
  ProductRowSelectable(this.model, {@required this.onTap, Key key})
      : super(key: key);
  build(context) {
    return InkWell(
      child: ProductRowWidget(this.model),
      onTap: this.onTap,
    );
  }
}
