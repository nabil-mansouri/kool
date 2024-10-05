import '../domain/domain.dart';

class CartState {
  bool productLoadFailed = false;
  bool productLoading = false;
  CartItem currentItem;
  Order currentOrder = Order(
      cart: Cart(totalAmountCents: 0),
      payment: Payment(status: Payment.STATUS_INIT, mean: PaymentMean()));
  ProductDetailModel detail = ProductDetailModel();
  //
  copy() {
    var copy = CartState();
    copy
      ..currentOrder = this.currentOrder
      ..currentItem = this.currentItem
      ..detail = this.detail;

    return copy;
  }

  get currentCart => this.currentOrder.cart;
  set currentCart(Cart c) => this.currentOrder.cart = c;
  get paymentMean => this.currentOrder.payment.mean;
  set paymentMean(PaymentMean c) => this.currentOrder.payment.mean = c;
}
