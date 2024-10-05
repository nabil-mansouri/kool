import 'package:flutter/material.dart';
import '../../domain/domain.dart';

class PaymentHeader extends StatelessWidget {
  final RestaurantModel model;
  PaymentHeader(this.model);

  Widget build(context) {
    final width = MediaQuery.of(context).size.width;
    final hasImage = model?.image != null;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final height = hasImage ? width * 9 / 16 : kToolbarHeight;
    final darkHeight = statusBarHeight + kToolbarHeight;
    //
    if (hasImage) {
      return SliverAppBar(
          backgroundColor: Theme.of(context).primaryColor,
          expandedHeight: height,
          title: Text(model?.name ?? ""),
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
                fit: StackFit.expand,
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Image.network(
                    model.image,
                    fit: BoxFit.fitWidth,
                  ),
                  Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: darkHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.6, 1],
                            colors: [Colors.black54, Colors.transparent],
                            tileMode: TileMode.clamp,
                          ),
                        ),
                      ))
                ],
              )));
    } else {
      return SliverAppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(model?.name ?? ""),
          floating: false,
          pinned: true);
    }
  }
}
