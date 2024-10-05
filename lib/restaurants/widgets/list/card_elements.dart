import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:flutter/material.dart';
import '../styles.dart';

/*
 * Cards
 */
class CardImage extends StatelessWidget {
  final String url;
  final String overlayText;
  CardImage(this.url, {this.overlayText});
  @override
  Widget build(BuildContext context) {
    var colorFilter = this.overlayText != null
        ? ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.srcOver)
        : null;
    var temp = AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              image: DecorationImage(
                  colorFilter: colorFilter,
                  image: this.url != null ? NetworkImage(this.url) : null,
                  fit: BoxFit.fitWidth)),
        ));
    if (this.overlayText != null) {
      return Stack(alignment: Alignment.center, children: [
        temp,
        Text(this.overlayText, style: TextStyles.title18Overlay)
      ]);
    } else {
      return temp;
    }
  }
}

class CardTags extends StatelessWidget {
  final List<String> tags;
  CardTags({List<String> tags}) : this.tags = tags ?? [];
  Widget build(BuildContext context) {
    List<Widget> texts = this
        .tags
        .map((tag) => [
              Text(tag, style: TextStyles.subTitle12),
              Text("\u26AB", style: TextStyles.textChipsCard)
            ])
        .reduce((a1, a2) {
      a1.addAll(a2);
      return a1;
    }).toList();
    texts.removeLast();
    return Wrap(
      alignment: WrapAlignment.center,
      direction: Axis.horizontal,
      spacing: 8,
      children: texts,
    );
  }
}

class CardTitle extends StatelessWidget {
  final String name;
  CardTitle({this.name});
  @override
  Widget build(BuildContext context) {
    return Text(this.name, style: TextStyles.title16);
  }
}

class CardRating extends StatelessWidget {
  final double rating;
  CardRating({this.rating});
  @override
  Widget build(BuildContext context) {
    return SmoothStarRating(
      allowHalfRating: true,
      starCount: 5,
      rating: rating,
      size: 12.0,
      color: Theme.of(context).primaryColor,
      borderColor: Theme.of(context).primaryColor,
    );
  }
}

class CardChip extends StatelessWidget {
  final String label;
  CardChip(this.label);
  build(context) {
    return Chip(
      backgroundColor: Colors.grey.shade200,
      label:
          Text(this.label, style: TextStyle(color: Colors.black, fontSize: 14)),
    );
  }
}
