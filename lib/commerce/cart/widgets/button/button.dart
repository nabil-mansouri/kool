import 'package:flutter/material.dart';
import 'package:food/multiflow/multiflow.dart';
import 'view_model.dart';

class CartButtonWidget extends StatelessWidget {
  final CartButtonViewModel model;
  CartButtonWidget(this.model);
  build(context) {
    List<Widget> children = [];
    children.add(Icon(Icons.shopping_basket));
    if (this.model.isEnable) {
      children.add(Transform(
        transform: Matrix4.identity()
          ..translate(22.0, -12.0)
          ..scale(0.6, 0.6),
        child: Chip(
          backgroundColor: Colors.redAccent.shade700,
          label: Text(
            this.model.nbItem.toString(),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ));
    }
    return FloatingActionButton(
      onPressed: () {
        this.model.openCart(context);
      },
      tooltip: "Afficher le panier",
      foregroundColor: Colors.white,
      backgroundColor:
          model.isEnable ? Theme.of(context).accentColor : Colors.grey.shade400,
      child: Stack(
        alignment: Alignment.center,
        overflow: Overflow.visible,
        children: children,
      ),
    );
  }
}

class CartButtonContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectedScopedModelBuilder<CartButtonViewModel>.fromModel(
      model: CartButtonViewModel(),
      builder: (context, model) {
        return CartButtonWidget(model);
      },
    );
  }
}

class OrderButtonWidget extends StatelessWidget {
  final OrderButtonViewModel model;
  OrderButtonWidget(this.model);
  build(context) {
    return RaisedButton(
      child: Text("COMMANDER"),
      color: Theme.of(context).accentColor,
      disabledColor: Colors.grey.shade400,
      textColor: Colors.white,
      disabledTextColor: Colors.white,
      elevation: 4.0,
      onPressed: model.canSubmit
          ? () {
              model.submitOrder(context);
            }
          : null,
    );
  }
}

class OrderButtonContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectedScopedModelBuilder<OrderButtonViewModel>.fromModel(
      model: OrderButtonViewModel(),
      builder: (context, model) {
        return OrderButtonWidget(model);
      },
    );
  }
}
