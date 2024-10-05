import 'package:flutter/material.dart';
import '../../domain/domain.dart';
import 'card_elements.dart';

typedef void OnTapRestaurant(RestaurantModel restau);

/*
 * restaurants
 */
class RestaurantCard extends StatelessWidget {
  final RestaurantModel model;
  final OnTapRestaurant onTap;
  RestaurantCard(this.model, [this.onTap]);
  @override
  Widget build(BuildContext context) {
    var overlayText = !this.model.available ? "INDISPONIBLE" : null;
    overlayText = this.model.closed ? "FERME" : overlayText;
    return InkWell(
        onTap: () => this.onTap(model),
        child: Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CardImage(this.model?.image, overlayText: overlayText),
                  Padding(
                      padding: EdgeInsets.only(top: 4, left: 4),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CardTitle(name: this.model.name),
                            CardChip(this.model.delayFormat)
                          ])),
                  Padding(
                      padding: EdgeInsets.only(top: 0, left: 4),
                      child: CardRating(rating: this.model.rating)),
                  Padding(
                      padding: EdgeInsets.only(top: 6, left: 4),
                      child: CardTags(tags: this.model.tags))
                ],
              ),
            )));
  }
}
