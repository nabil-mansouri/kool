import 'package:food/multiflow/multiflow.dart';
import 'package:flutter/material.dart';
import '../../store/store.dart';
import '../../domain/domain.dart';

class RecapRowViewModel {
  final CartItem item;
  final String title;
  final List<String> details;
  final String price;
  final int priceCents;
  final int quantity;
  RecapRowViewModel(
      {this.item,
      this.title,
      this.details,
      this.price,
      this.priceCents,
      this.quantity});
}

class RecapViewModel extends AbstractFormModel<CartState> {
  Cart cart;
  List<CartItem> items = [];
  List<RecapRowViewModel> rows = [];
  FormFieldController promoController;
  FormFieldController commentController;
  // TODO dont update state directly? save on model and on dispose save on state if needed
  RecapViewModel() {
    promoController = createFormFieldController(
        getter: (s) => this.cart?.promo, setter: (s) => this.cart?.promo = s);
    commentController = createFormFieldController(
        getter: (s) => this.cart?.comment,
        setter: (s) => this.cart?.comment = s);
  }

  get total {
    return cart.totalAmountFormat;
  }

  editCartItem(BuildContext context, CartItem item) {
    this.getStore<CartStore>(context, CartStore).editCartItem(item);
  }

  onAction(action) {
    super.onAction(action);
  }

  bool refresh(CartState state) {
    bool changed = false;
    bool cartChanged = this.cart != state.currentCart;
    if (cartChanged) {
      this.cart = state.currentCart;
      changed = true;
    }
    if (cartChanged || this.items != state.currentCart?.items) {
      this.items = state.currentCart.items;
      _updateItems();
      changed = true;
    }
    return changed;
  }

  _updateItems() {
    this.rows = [];
    for (CartItem row in this.cart.items) {
      final details = row.details.map((i) => i.optionName).toList();
      final hasComments = row?.comment?.isNotEmpty;
      if (hasComments != null && hasComments) {
        details.add(row.comment);
      }
      this.rows.add(RecapRowViewModel(
          item: row,
          title: row.productName,
          quantity: row.quantity,
          details: details,
          price: row.totalAmountFormat,
          priceCents: row.totalAmountCents));
    }
  }
}
