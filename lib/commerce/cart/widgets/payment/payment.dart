import 'package:flutter/material.dart';
import 'view_model.dart';
import 'package:food/commons/custom_input.dart';
import 'package:food/multiflow/multiflow.dart';
import 'payment_logo.dart';

class PaymentWidget extends StatelessWidget {
  final PaymentViewModel model;
  PaymentWidget(this.model);
  _buildTitle() {
    return ListTile(
        title: Text("Paiement",
            style: TextStyle(color: Colors.black54, fontSize: 14)));
  }

  _buildType() {
    final children = model.paymentTypes
        .map((type) => PaymentLogo(model: model, type: type))
        .toList();
    return Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            spacing: 8,
            children: children));
  }

  _buildRow() {
    return Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
      Flexible(
          flex: 1,
          child: CustomInputWidget(
              controller: model.expiryController,
              keyboardType: TextInputType.number,
              autocorrect: false,
              labelText: "Date d'expiration",
              hintText: "MM/YY")),
      Flexible(
          flex: 1,
          child: CustomInputWidget(
              controller: model.ccvController,
              keyboardType: TextInputType.number,
              autocorrect: false,
              labelText: "Code CVC",
              hintText: "123"))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(_buildTitle());
    children.add(_buildType());
    if (model.isCreditCard()) {
      children.add(CustomInputWidget(
          controller: model.cardNumberController,
          autocorrect: false,
          keyboardType: TextInputType.number,
          labelText: "Numéro de la carte",
          hintText: 'xxxx-xxxx-xxxx-xxxx'));
      children.add(Divider());
      children.add(_buildRow());
    }
    return Padding(
      child: Container(color: Colors.white, child: Column(children: children)),
      padding: EdgeInsets.symmetric(vertical: 12),
    );
  }
}

class PaymentContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //contains some textinput that rebuild all the report so=> persistent
    return ConnectedScopedModelBuilder<PaymentViewModel>.fromFactory(
      modelFactory: () => PaymentViewModel(),
      builder: (context, model) {
        return PaymentWidget(model);
      },
    );
  }
}
