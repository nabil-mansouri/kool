import 'package:flutter/material.dart';
import 'view_model.dart';

class SelectionRowProduct extends StatelessWidget {
  final SelectionViewModel model;
  final SelectionRowViewModel row;
  SelectionRowProduct(this.model, this.row);
  Widget check() {
    if (row.unique) {
      return RadioListTile<bool>(
          groupValue: true,
          value: this.row.selected,
          title: Text(row.productName),
          onChanged: (bool value) {
            this.model.updateRow(row, !value);
          });
    } else {
      return CheckboxListTile(
          value: this.row.selected,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(row.productName),
          onChanged: (bool value) {
            this.model.updateRow(row, value);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Flexible(child: check()),
      Padding(
          padding: EdgeInsets.only(right: 24), child: Text(row.productPrice))
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }
}

class SelectionRowDescription extends StatelessWidget {
  final SelectionViewModel model;
  SelectionRowDescription(this.model);
  build(context) {
    return Text(this.model.product.name);
  }
}

class SelectionRowProductGroup extends StatelessWidget {
  final SelectionRowViewModel model;
  SelectionRowProductGroup(this.model);
  Widget _buildRow() {
    List<Widget> children = List();
    children.add(_buildTitleGroup());
    if (this.model.headerMandatory) {
      children.add(Chip(
        backgroundColor: Colors.grey.shade200,
        label: Text("OBLIGATOIRE"),
        labelStyle: TextStyle(color: Colors.black, fontSize: 12),
      ));
    }
    return Row(
      children: children,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }

  Widget _buildTitleGroup() {
    final title = Text(
      this.model.headerTitle,
      style: TextStyle(color: Colors.black54, fontSize: 16),
    );
    if (this.model.hasHeaderSubtitle) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            title,
            Text(this.model.headerSubtitle,
                style: TextStyle(color: Colors.black54, fontSize: 12))
          ]);
    } else {
      return title;
    }
  }

  build(context) {
    return Padding(
      child: _buildRow(),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }
}

class SelectionRowComment extends StatelessWidget {
  final SelectionViewModel model;
  SelectionRowComment(this.model);
  build(context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              "Instructions spécifiques",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ),
          TextField(
            autocorrect: false,
            controller: model.commentController,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                border: InputBorder.none,
                hintText: 'Saisissez vos instructions....'),
          )
        ]);
  }
}

class SelectionBody extends StatelessWidget {
  final SelectionViewModel model;
  SelectionBody(this.model);
  List<Widget> _buildChildren() {
    int index = 0;
    final List<Widget> children = [];
    for (SelectionRowViewModel row in this.model.rows) {
      if (row.isDescription) {
        children.add(SelectionRowDescription(model));
      } else if (row.isHeader) {
        //divider before group
        if (index > 0) {
          children.add(Divider());
        }
        children.add(SelectionRowProductGroup(row));
      } else if (row.isProduct) {
        children.add(SelectionRowProduct(model, row));
      } else {
        //DO NOTHING
      }
      index++;
    }
    //divider before instructions
    if (index > 0) {
      children.add(Divider());
    }
    children.add(SelectionRowComment(model));
    children.add(QuantitySelector(model));
    return children;
  }

  Widget build(context) {
    if (model.productLoading) {
      return SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()));
    } else {
      return SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 16),
          sliver:
              SliverList(delegate: SliverChildListDelegate(_buildChildren())));
    }
  }
}

class SelectionButton extends StatelessWidget {
  final SelectionViewModel model;
  SelectionButton(this.model);
  build(context) {
    return RaisedButton(
      child: Text(model.submitText),
      color: Theme.of(context).accentColor,
      disabledColor: Colors.grey.shade400,
      textColor: Colors.white,
      disabledTextColor: Colors.white,
      elevation: 4.0,
      onPressed: model.canSubmit
          ? () {
              model.submit(context);
            }
          : null,
    );
  }
}

class QuantitySelector extends StatelessWidget {
  final SelectionViewModel model;
  QuantitySelector(this.model);
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ButtonTheme(
                        minWidth: 0.0,
                        child: FlatButton(
                            child:
                                Text("\uFF0D", style: TextStyle(fontSize: 24)),
                            onPressed: this.model.canDecrement()
                                ? () {
                                    this.model.decrementQuantity();
                                  }
                                : null)),
                    Text(this.model.quantity.toString(),
                        style: TextStyle(fontSize: 24)),
                    ButtonTheme(
                        minWidth: 0.0,
                        child: FlatButton(
                            child:
                                Text("\uFF0B", style: TextStyle(fontSize: 24)),
                            onPressed: () {
                              this.model.incrementQuantity();
                            }))
                  ],
                ),
              )
            ]));
  }
}
