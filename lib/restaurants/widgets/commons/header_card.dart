import 'package:flutter/material.dart';
import '../../domain/domain.dart';
import '../styles.dart';
import '../list/card_elements.dart';

class RestaurantDetailHeaderCard extends StatelessWidget {
  final RestaurantModel current;
  final double horizontalMargin;
  RestaurantDetailHeaderCard(this.current, {this.horizontalMargin});
  build(context) {
    return IntrinsicHeight(
        child: Card(
            elevation: 1,
            margin: EdgeInsets.only(
                left: this.horizontalMargin, right: this.horizontalMargin),
            child: Padding(
                padding:
                    EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(this.current.name, style: TextStyles.title24),
                            CardChip(this.current.delayFormat)
                          ]),
                      CardRating(rating: this.current.rating),
                      Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: CardTags(tags: this.current.tags))
                    ]))));
  }
}

class RestaurantDetailHeaderImage extends StatelessWidget {
  final RestaurantModel current;
  final bool heightLessThanWidth;
  RestaurantDetailHeaderImage(this.current,
      {@required this.heightLessThanWidth});
  build(context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          image: DecorationImage(
              alignment: AlignmentDirectional.topCenter,
              image: NetworkImage(this.current?.image),
              fit: this.heightLessThanWidth
                  ? BoxFit.fitWidth
                  : BoxFit.fitHeight)),
    );
  }
}
