import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../products/products.dart';
part 'models.g.dart';

@JsonSerializable()
class CartItemDetails {
  String optionId;
  String optionName;
  int amountCents;
  CartItemDetails(
      {@required this.optionId,
      @required this.optionName,
      @required this.amountCents});
  factory CartItemDetails.fromJson(Map<String, dynamic> json) {
    return _$CartItemDetailsFromJson(json);
  }
  Map<String, dynamic> toJson() {
    return _$CartItemDetailsToJson(this);
  }

  factory CartItemDetails.fromProductItem(ProductItemModel productItem) {
    return CartItemDetails(
        amountCents: productItem.priceCents,
        optionId: productItem.id,
        optionName: productItem.name);
  }
  String get amountFormat => formatCurrency.format(this.amountCents / 100);
}

@JsonSerializable()
class CartItem {
  String productId;
  String productName;
  int quantity;
  int amountCents;
  int totalAmountCents;
  String comment;
  String kind; //fee,product,...
  List<CartItemDetails> details = [];
  CartItem(
      {@required this.productId,
      @required this.details,
      @required this.productName,
      @required this.amountCents,
      @required this.totalAmountCents,
      this.comment,
      this.quantity = 1});
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return _$CartItemFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$CartItemToJson(this);
  }

  String get amountFormat => formatCurrency.format(this.amountCents / 100);
  String get totalAmountFormat =>
      formatCurrency.format(this.totalAmountCents / 100);
}

@JsonSerializable()
class Cart {
  String promo;
  String comment;
  int totalAmountCents;
  List<CartItem> items = [];

  Cart({@required this.totalAmountCents, this.comment});
  factory Cart.fromJson(Map<String, dynamic> json) {
    return _$CartFromJson(json);
  }
  Map<String, dynamic> toJson() {
    return _$CartToJson(this);
  }

  Cart copy() {
    Cart copy = Cart(totalAmountCents: this.totalAmountCents);
    copy
      ..items = this.items
      ..totalAmountCents = this.totalAmountCents
      ..comment = this.comment
      ..promo = this.promo;
    return copy;
  }

  get count {
    if (items.length == 0) {
      return 0;
    }
    return this.items.map((f) => f.quantity).reduce((a, b) => a + b);
  }

  get canSubmit {
    return this.count > 0 && this.totalAmountCents > 0;
  }

  update() {
    int amount = 0;
    this.items.forEach((item) => amount += item.totalAmountCents);
    this.totalAmountCents = amount;
  }

  String get totalAmountFormat =>
      formatCurrency.format(this.totalAmountCents / 100);
}

@JsonSerializable()
class PaymentMean {
  static const String PAYPAL = "paypal";
  static const String CC_VISA = "visa";
  static const String CC_MASTERCARD = "mastercard";
  static const String CC_AMERICAN_EXPRESS = "ameriacan_express";
  String name;
  String type;
  String ccNumber;
  String ccExpiryMMYY;
  String ccSecurityCode;
  PaymentMean(
      {this.type,
      this.name,
      this.ccNumber,
      this.ccExpiryMMYY,
      this.ccSecurityCode});

  PaymentMean copy() {
    final clone = PaymentMean()
      ..name = this.name
      ..type = this.type
      ..ccNumber = this.ccNumber
      ..ccExpiryMMYY = this.ccExpiryMMYY
      ..ccSecurityCode = this.ccSecurityCode;
    return clone;
  }

  factory PaymentMean.fromJson(Map<String, dynamic> json) {
    return _$PaymentMeanFromJson(json);
  }
  Map<String, dynamic> toJson() {
    return _$PaymentMeanToJson(this);
  }

  get isValid {
    if (type == PaymentMean.PAYPAL) {
      return true;
    }
    return this.ccNumber?.isNotEmpty == true &&
        this.ccExpiryMMYY?.isNotEmpty == true &&
        this.ccSecurityCode?.isNotEmpty == true;
  }
}

@JsonSerializable()
class Payment {
  static const String STATUS_INIT = "init";
  static const String STATUS_COMPLETE = "complete";
  static const String STATUS_VERIFYING = "verifying";
  static const String STATUS_ABORT = "abort";
  String transactionId;
  int amountPaidCents;
  int paidAtUTCMs;
  PaymentMean mean;
  String status;
  Payment(
      {this.mean,
      @required this.status,
      this.amountPaidCents,
      this.paidAtUTCMs,
      this.transactionId});
  factory Payment.fromJson(Map<String, dynamic> json) {
    return _$PaymentFromJson(json);
  }
  Map<String, dynamic> toJson() {
    return _$PaymentToJson(this);
  }
}

@JsonSerializable()
class Order {
  Cart cart;
  Payment payment;
  Order({@required this.cart, @required this.payment});
  get canSubmit {
    return this.cart.canSubmit &&
        this.payment.status == Payment.STATUS_INIT &&
        this.payment.mean.isValid;
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return _$OrderFromJson(json);
  }
  Map<String, dynamic> toJson() {
    return _$OrderToJson(this);
  }
}
