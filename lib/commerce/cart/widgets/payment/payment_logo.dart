import 'package:flutter/material.dart';
import 'view_model.dart';

class PaymentLogo extends StatelessWidget {
  final String type;
  final PaymentViewModel model;
  PaymentLogo({@required this.type, @required this.model});
  _buildContainer() {
    return OutlineButton(
        onPressed: () {
          model.selectType(type);
        },
        borderSide: BorderSide(
            color: model.isSelectedType(type)
                ? Colors.green
                : Colors.grey.shade400,
            width: 1.0),
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(6.0)),
        padding: new EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        color: Colors.white,
        child: SizedBox(
            height: 30,
            child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(model.getImgUrl(type)))));
  }

  @override
  Widget build(BuildContext context) {
    if (!model.isSelectedType(type)) {
      return _buildContainer();
    }
    return Stack(
      overflow: Overflow.visible,
      alignment: AlignmentDirectional.topEnd,
      children: <Widget>[
        _buildContainer(),
        Positioned(
            top: -4.0,
            right: -4.0,
            child: Container(
              child: Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 16.0,
              ),
              color: Colors.white,
            ))
      ],
    );
  }
}
