import 'package:flutter/material.dart';
import '../domains/domain.dart';

//TODO use themedata
class _TextStyles {
  static final title16Overlay = TextStyle(fontSize: 16, color: Colors.white);
  static final title16 = TextStyle(fontSize: 16, color: Colors.black);
  static final title14 = TextStyle(fontSize: 14, color: Colors.black);
  static final subTitle14 = TextStyle(fontSize: 14, color: Colors.black54);
}

class ProductRowImage extends StatelessWidget {
  final String url;
  final String overlayText;
  ProductRowImage(this.url, {this.overlayText});
  build(context) {
    var colorFilter = this.overlayText != null
        ? ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.srcOver)
        : null;
    var temp = AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  colorFilter: colorFilter,
                  image: NetworkImage(this.url),
                  fit: BoxFit.fitHeight)),
        ));
    if (this.overlayText != null) {
      return Stack(alignment: Alignment.center, children: [
        temp,
        Text(this.overlayText,
            textAlign: TextAlign.center, style: _TextStyles.title16Overlay)
      ]);
    } else {
      return temp;
    }
  }
}

class ProductRowDescription extends StatelessWidget {
  final ProductModel product;
  ProductRowDescription(this.product);
  build(context) {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(product.name,
            style: _TextStyles.title16,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        Padding(
            child: Text(product.description ?? "",
                overflow: TextOverflow.ellipsis,
                style: _TextStyles.subTitle14,
                maxLines: 2),
            padding: EdgeInsets.only(top: 12, bottom: 8)),
        Text(product.price, style: _TextStyles.title14),
      ],
    ));
  }
}

class ProductRowWidget extends StatelessWidget {
  final ProductModel product;
  ProductRowWidget(this.product, {Key key}) : super(key: key);

  List<Widget> buildChildren() {
    List<Widget> widgets = [];
    var overlayText = !product.available ? "INDISPONIBLE" : null;
    var showImage = this.product.hasImage || overlayText != null;
    //TODO asset image
    var url = this.product.hasImage
        ? this.product.image
        : "https://herschel.com/content/dam/herschel/swatches/0796.png";
    //IF OVERLAY => DISPLAY BLACK IMAGE
    if (showImage) {
      widgets.add(Expanded(
          flex: 4,
          child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: ProductRowDescription(product))));
      widgets.add(Expanded(
          flex: 1, child: ProductRowImage(url, overlayText: overlayText)));
    } else {
      widgets.add(Expanded(flex: 1, child: ProductRowDescription(product)));
    }
    return widgets;
  }

  build(context) {
    return Container(
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: IntrinsicHeight(
                child: Flex(
              crossAxisAlignment: CrossAxisAlignment.center,
              direction: Axis.horizontal,
              children: this.buildChildren(),
            ))));
  }
}
