import 'package:food/multiflow/multiflow.dart';
import 'workflow.dart';
import 'states.dart';
import 'actions.dart';
import '../domain/domain.dart';
//
export 'actions.dart';
export 'routes.dart';
export 'workflow.dart';
export 'states.dart';

/*
 *STORE AND ACTION KEYS
 */

class CartStore extends Store<CartState> with CartActions {
  CartWorkflow workflow;
  getWorkflow() => workflow;
  CartStore() : super(CartState()) {
    this.workflow = CartWorkflow(this).start();
    //ACTIONS
    this.addReducerForAction<CartUpdateAction>(
        CartActions.doUpdateCart, Reducer(_onCartUpdate));
    this.addReducerForAction(CartActions.doResetCart, Reducer(_onCartReset));
    this.addReducerForAction<CartItem>(
        CartActions.doRemove.success, Reducer(_onCartRemoveSuccess));
    this.addReducerForAction<CartItem>(
        CartActions.doEdit, Reducer(_onCartEdit));
    //PRODUCTS
    this.addReducerForAction<ProductModel>(
        CartActions.doLoadProducts.query, Reducer(_onCartSelectProduct));
    this.addReducerForAction<ProductDetailModel>(
        CartActions.doLoadProducts.success, Reducer(_onLoadProductSuccess));
    this.addReducerForAction(
        CartActions.doLoadProducts.failed, Reducer(_onLoadProductFailed));
    //PAYMENT
    this.addReducerForAction<PaymentMean>(
        CartActions.doUpdatePaymentMean, Reducer(_onPaymentMeanUpdate));
  }
  CartState _onCartUpdate(Action<CartUpdateAction> action, CartState state) {
    state = state.copy();
    final payload = action.payload;
    //
    final List<CartItem> cartItems = List.from(state.currentCart.items);
    cartItems.removeWhere((test) => test == payload.oldCartItem);
    if (payload.quantity > 0) {
      final cartDetails = payload.items
          .map((productItem) => CartItemDetails.fromProductItem(productItem))
          .toList();
      final cartItem = CartItem(
          details: cartDetails,
          comment: payload.comment,
          amountCents: payload.amountCents,
          totalAmountCents: payload.totalAmountCents,
          productId: payload.product.id,
          productName: payload.product.name,
          quantity: payload.quantity);
      cartItems.add(cartItem);
    }
    state.currentCart.items = cartItems;
    state.currentCart.update();
    return state;
  }

  CartState _onCartReset(Action action, CartState state) {
    state = state.copy();
    state.currentCart = Cart(totalAmountCents: 0);
    return state;
  }

  CartState _onCartRemoveSuccess(Action<CartItem> action, CartState state) {
    state = state.copy();
    final payload = action.payload;
    final List<CartItem> cartItems = List.from(state.currentCart.items);
    cartItems.removeWhere((test) => test == payload);
    state.currentCart.items = cartItems;
    state.currentCart.update();
    return state;
  }

  CartState _onCartEdit(Action<CartItem> action, CartState state) {
    state = state.copy();
    state.currentItem = action.payload;
    return state;
  }

  CartState _onCartSelectProduct(Action<ProductModel> action, CartState state) {
    state = state.copy();
    state.currentItem = null;
    state.productLoading = true;
    state.productLoadFailed = false;
    state.detail.product = action.payload;
    return state;
  }

  CartState _onLoadProductSuccess(
      Action<ProductDetailModel> action, CartState state) {
    state = state.copy();
    state.productLoading = false;
    state.productLoadFailed = false;
    state.detail = action.payload;
    return state;
  }

  CartState _onLoadProductFailed(Action action, CartState state) {
    state = state.copy();
    state.productLoading = false;
    state.productLoadFailed = true;
    return state;
  }

  CartState _onPaymentMeanUpdate(Action<PaymentMean> action, CartState state) {
    state = state.copy();
    state.paymentMean = action.payload;
    return state;
  }
}
