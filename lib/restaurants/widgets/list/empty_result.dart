import 'package:flutter/material.dart';

typedef void RestaurantListEmptyAction();

class RestaurantListEmptyResultWidget extends StatelessWidget {
  final RestaurantListEmptyAction onSell;
  RestaurantListEmptyResultWidget({@required this.onSell});

  Widget build(BuildContext context) {
    final MaterialColor mainColor = Theme.of(context).primaryColor;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: viewportConstraints.maxHeight * 0.8,
          ),
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 64),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Icon(Icons.search, color: mainColor.shade400, size: 108),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Oups...",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      Padding(padding: EdgeInsets.only(top: 12)),
                      Text(
                        """Nous n'avons rien trouvé près de chez vous.""",
                        style: TextStyle(
                            height: 1.25, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        """Vous avez un restaurant ou êtes amateur? Vendez des produits c'est simple et rapide!""",
                        style: TextStyle(
                            height: 1.25, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                  RaisedButton(
                      color: mainColor.shade500,
                      child: Text(
                        "VENDRE DES PRODUITS",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        onSell();
                      })
                ],
              )));
    });
  }
}
