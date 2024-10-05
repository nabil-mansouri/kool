import 'package:flutter/material.dart';
import 'package:food/multiflow/multiflow.dart';
import 'view_model.dart';
import 'recap_cart.dart';

class RecapCartContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //contains some textinput that rebuild all the report so=> persistent
    return ConnectedScopedModelBuilder<RecapViewModel>.fromFactory(
      modelFactory: () => RecapViewModel(),
      builder: (context, model) {
        return RecapCartWidget(model);
      },
    );
  }
}
