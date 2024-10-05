import 'package:flutter/material.dart';
import 'view_model.dart';
import 'body.dart';
import 'header.dart';
import 'package:food/multiflow/multiflow.dart';

class CartSelection extends StatelessWidget {
  final SelectionViewModel model;
  CartSelection(this.model);

  _buildBottom() {
    if (!model.productLoading) {
      return IntrinsicHeight(
        child: SelectionButton(this.model),
      );
    } else {
      return null;
    }
  }

  _buildScroll(context) {
    if (model.product == null) {
      return Center(child: CircularProgressIndicator());
    }
    return CustomScrollView(
        slivers: [SelectionHeader(this.model), SelectionBody(model)]);
  }

  Widget build(context) {
    //final children = <Widget>[_buildScroll(context), _buildBottom()];
    //children.removeWhere((a) => a == null);
    //return Scaffold(body: Column(children: children));
    return Scaffold(
      body: _buildScroll(context),
      bottomNavigationBar: _buildBottom(),
    );
  }
}

class CartSelectionScreen extends StatelessWidget {
  build(context) {
    return ConnectedScopedModelBuilder<SelectionViewModel>.fromFactory(
        modelFactory: () => SelectionViewModel(),
        builder: (context, model) {
          return CartSelection(model);
        });
  }
}
