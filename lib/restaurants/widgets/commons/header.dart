import 'package:flutter/material.dart';
import 'header_card.dart';
import 'package:meta/meta.dart';
import 'dart:math';
import '../../domain/domain.dart';

class RestaurantPersistentHeader implements SliverPersistentHeaderDelegate {
  RestaurantPersistentHeader(
      {@required this.model,
      @required this.minExtent,
      @required this.maxExtent,
      @required this.paddingTop,
      this.bottom});
  final Widget bottom;
  final RestaurantModel model;
  final double maxExtent;
  final double minExtent;
  final double paddingTop;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var appBarHeight = kToolbarHeight;
    var sizeOfPadding = 14.0;
    var imgPadding = 2 * sizeOfPadding;
    var horizontalMargins = 32.0;
    var distanceMax = maxExtent - minExtent;
    var distanceCurrent = shrinkOffset;
    var percentDistance = distanceCurrent / distanceMax;
    var remainingDistanceUntilEnd = maxExtent - distanceCurrent;
    var remainingDistanceUntilMin = remainingDistanceUntilEnd - minExtent;
    final Tween<double> doubleTween =
        Tween<double>(begin: horizontalMargins, end: 0.0);
    var horizontalMarginCurrent =
        max(0.0, doubleTween.transform(percentDistance));
    //OPCITY APP BAR
    var opacityAppBar = 0.0;
    var appBarStart = appBarHeight + sizeOfPadding;
    if (remainingDistanceUntilMin <= appBarStart) {
      final Tween<double> tweenAppBar = Tween<double>(begin: 1, end: 0.0);
      var ratio = remainingDistanceUntilMin / appBarStart;
      opacityAppBar = min(1, tweenAppBar.transform(ratio));
    }
    var opacityImg = 1 - opacityAppBar;
    var appBarThreshold = opacityAppBar > 0.9;
    if (model == null) {
      return Container();
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: imgPadding,
            child: Opacity(
                opacity: opacityImg,
                child: this.model.image != null
                    ? Image.network(
                        this.model.image,
                        fit: BoxFit.cover,
                      )
                    : Container())),
        Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: maxExtent - kToolbarHeight,
            child: Opacity(
                opacity: opacityImg,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                      ],
                      stops: [0.5, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      tileMode: TileMode.repeated,
                    ),
                  ),
                ))),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Opacity(
              opacity: opacityImg,
              child: RestaurantDetailHeaderCard(model,
                  horizontalMargin: horizontalMarginCurrent)),
        ),
        AppBar(
          bottom: appBarThreshold ? this.bottom : null,
          iconTheme:
              appBarThreshold ? IconThemeData(color: Colors.black) : null,
          title: Opacity(
              opacity: opacityAppBar,
              child: Text(model.name, style: TextStyle(color: Colors.black))),
          elevation: appBarThreshold ? 4 : 0,
          backgroundColor: appBarThreshold ? Colors.white : Colors.transparent,
        )
      ],
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  get snapConfiguration => null;
}
