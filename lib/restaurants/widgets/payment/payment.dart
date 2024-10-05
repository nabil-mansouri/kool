import 'package:flutter/material.dart';
import 'package:food/multiflow/multiflow.dart';
import 'package:food/commerce/commerce.dart';
import '../commons/commons.dart';
import 'view_model.dart';
import "header.dart";

class PaymentWidget extends StatelessWidget {
  final RestaurantPaymentViewModel model;
  PaymentWidget(this.model);
  _buildRestaurantInfo() {
    return Container(
        color: Colors.white, child: RestaurantLocationInfo(model?.current));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: IntrinsicHeight(child: OrderButtonContainer()),
        backgroundColor: Colors.grey.shade200,
        body: CustomScrollView(slivers: <Widget>[
          PaymentHeader(model.current),
          SliverList(
              delegate: SliverChildListDelegate([
            _buildRestaurantInfo(),
            RecapCartContainer(),
            Padding(
              child: PaymentContainer(),
              padding: EdgeInsets.only(bottom: 28),
            )
          ]))
        ]));
  }
}

class RestaurantPaymentScreen extends StatelessWidget {
  build(context) {
    return ConnectedScopedModelBuilder<RestaurantPaymentViewModel>.fromModel(
      model: RestaurantPaymentViewModel(),
      builder: (context, model) {
        return PaymentWidget(model);
      },
    );
  }
}
