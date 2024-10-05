import 'package:food/multiflow/multiflow.dart';
import 'workflow.dart';
import '../domain/domain.dart';
import 'package:meta/meta.dart';
import 'routes.dart';

///
/// ACTIONS
///
abstract class CartActions {
  static final AsyncAction<ProductDetailModel, ProductModel> doLoadProducts =
      AsyncAction.create("cart.products");
  static final Action<CartItem> doEdit = Action.string<CartItem>("cart.edit");
  static final AsyncAction<CartItem, CartItem> doRemove =
      AsyncAction.create("cart.remove");
  static final Action<PaymentMean> doUpdatePaymentMean =
      Action.string<PaymentMean>("cart.paymentmean.update");
  static final Action<CartUpdateAction> doUpdateCart =
      Action.string<CartUpdateAction>("cart.update");
  static final Action<Object> doResetCart = Action.string<Object>("cart.reset");
  static final Action<Object> doValidateCart =
      Action.string<Object>("cart.validate");

  CartWorkflow getWorkflow();
  loadProduct(ProductModel model) {
    getWorkflow()
        .store
        .sendAction(CartActions.doLoadProducts.query.withPayload(model));
  }

  addCartItem(
      {@required ProductModel product,
      @required List<ProductItemModel> items,
      @required int quantity,
      @required String comment}) {
    getWorkflow().publishAction(
        CartActions.doUpdateCart.withPayload(CartUpdateAction(
          product,
          comment: comment,
          items: items,
          quantity: quantity,
        )),
        true);
  }

  updateCartItem(
      {@required ProductModel product,
      @required List<ProductItemModel> items,
      @required int quantity,
      @required String comment,
      @required CartItem oldCartItem}) {
    getWorkflow().publishAction(
        CartActions.doUpdateCart.withPayload(CartUpdateAction(product,
            comment: comment,
            items: items,
            quantity: quantity,
            oldCartItem: oldCartItem)),
        true);
  }

  removeCartItem(CartItem item) {
    getWorkflow()
        .publishAction(CartActions.doRemove.query.withPayload(item), true);
  }

  editCartItem(CartItem item) {
    getWorkflow().publishAction(CartActions.doEdit.withPayload(item), true);
  }

  displayCart() {
    getWorkflow()
        .publishAction(NavigationActions.createPush(CartRoutes.CART_SHOW), true);
  }

  updatePaymentMean(PaymentMean mean) {
    getWorkflow().store.sendAction(doUpdatePaymentMean.withPayload(mean));
  }
}

///
/// ACTION PAYLOAD
///
class CartUpdateAction {
  final CartItem oldCartItem;
  final ProductModel product;
  final List<ProductItemModel> items;
  final int quantity;
  final String comment;
  CartUpdateAction(this.product,
      {this.items = const [],
      this.oldCartItem,
      this.quantity = 1,
      this.comment});
  get amountCents {
    int amount = product.priceCents;
    items.forEach((item) => amount += item.priceCents);
    return amount;
  }

  get totalAmountCents {
    return this.amountCents * this.quantity;
  }
}
