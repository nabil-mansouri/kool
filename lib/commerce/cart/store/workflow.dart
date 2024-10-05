import 'dart:async';
import 'package:food/multiflow/multiflow.dart';
import '../domain/domain.dart';
import 'states.dart';
import 'routes.dart';
import 'actions.dart';

/*
 *WORKFLOW 
 */
class CartWorkflow extends Workflow<CartState> {
  ProductService productService = getProductService();
  CartWorkflow(Store<CartState> store) : super(store);
  onSendAction<PAYLOAD>(Action<PAYLOAD> action, CartState state) {
    super.onSendAction(action, state);
  }

  EffectTakeEvery<ProductModel> _forEachCartProductSelect() {
    print("[Workflow][Cart] start waiting for product selection");
    return takeEvery<ProductModel>(CartActions.doLoadProducts.query,
        debounceMs: 250, callback: (action) async {
      ProductModel product = action.payload;
      print("[Workflow][Cart] selecting a product");
      final productDetail = productService.fetchProductDetail(product);
      store.sendAction(NavigationActions.createPush(CartRoutes.CART_SELECT));
      store.sendActionFuture(
          CartActions.doLoadProducts.request.withPayload(productDetail));
    });
  }

  EffectTakeEvery<CartItem> _forEachCartItemSelect() {
    print("[Workflow][Cart] start waiting for cart item selection");
    return takeEvery(CartActions.doEdit, debounceMs: 250,
        callback: (action) async {
      CartItem cartItem = action.payload;
      print("[Workflow][Cart] selecting a cart item");
      if (cartItem.productId != null) {
        final productDetail =
            productService.fetchProductDetailById(cartItem.productId);
        store
            .sendAction(NavigationActions.createPush(CartRoutes.CART_SELECT));
        store.sendActionFuture(
            CartActions.doLoadProducts.request.withPayload(productDetail));
      } else {
        //TODO error
        print("[Workflow][Cart] missing cart item ID!!!!!!!!!!!!!");
      }
    });
  }

  EffectTakeEvery<CartUpdateAction> _forEachCartUpdate() {
    print("[Workflow][Cart] start waiting for cart update");
    return takeEvery(CartActions.doUpdateCart, debounceMs: 250,
        callback: (action) async {
      store.sendAction(NavigationActions.createPop());
    });
  }

  EffectTakeEvery<CartItem> _forEachCartRemove() {
    print("[Workflow][Cart] start waiting for cart update");
    return takeEvery(CartActions.doRemove.query, debounceMs: 250,
        callback: (action) async {
      //REMOVE FROM CART
      store
          .sendAction(CartActions.doRemove.success.withPayload(action.payload));
      //GO BACK TO CART
      store.sendAction(NavigationActions.createPop());
      //IF CART EMPTY GO BACK AGAIN
      final count = store.state.currentCart?.count;
      if (count != null && count == 0) {
        //BACK FROM CART VIEW
        store.sendAction(NavigationActions.createPop());
      }
    });
  }

  @override
  Future<Object> workflow() async {
    try {
      print("[CartWorkflow][Cart] starting");
      await join([
        _forEachCartProductSelect(),
        _forEachCartUpdate(),
        _forEachCartItemSelect(),
        _forEachCartRemove()
      ]).future;
      return null;
    } catch (e) {
      print("[CartWorkflow][Cart] erro occured: $e");
      throw e;
    } finally {
      print("[CartWorkflow][Cart] ended");
    }
  }
}
