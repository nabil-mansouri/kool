import 'package:food/multiflow/multiflow.dart';
import 'package:flutter/material.dart';
import '../../store/store.dart';
import '../../domain/domain.dart';

class CartButtonViewModel extends AbstractModel<CartState> {
  int nbItem = 0;
  bool get isEnable {
    return this.nbItem > 0;
  }

  bool refresh(CartState state) {
    var changed = false;
    final cart = state.currentCart;
    if (cart != null) {
      if (cart.count != nbItem) {
        nbItem = cart.count;
        changed = true;
      }
    }
    return changed;
  }

  openCart(BuildContext context) {
    if (this.isEnable) {
      this.getStore<CartStore>(context, CartStore).displayCart();
    }
  }
}

class OrderButtonViewModel extends AbstractModel<CartState> {
  Order order;
  bool canSubmit;
  bool refresh(CartState state) {
    var changed = false;
    if (order != state.currentOrder) {
      order = state.currentOrder;
      changed = true;
    }
    if (this.canSubmit != state.currentOrder.canSubmit) {
      this.canSubmit = state.currentOrder.canSubmit;
      changed = true;
    }
    return changed;
  }

  submitOrder(BuildContext context) {
    //TODO
  }
}
