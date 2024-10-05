// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItemDetails _$CartItemDetailsFromJson(Map<String, dynamic> json) {
  return CartItemDetails(
      optionId: json['optionId'] as String,
      optionName: json['optionName'] as String,
      amountCents: json['amountCents'] as int);
}

Map<String, dynamic> _$CartItemDetailsToJson(CartItemDetails instance) =>
    <String, dynamic>{
      'optionId': instance.optionId,
      'optionName': instance.optionName,
      'amountCents': instance.amountCents
    };

CartItem _$CartItemFromJson(Map<String, dynamic> json) {
  return CartItem(
      productId: json['productId'] as String,
      details: (json['details'] as List)
          ?.map((e) => e == null
              ? null
              : CartItemDetails.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      productName: json['productName'] as String,
      amountCents: json['amountCents'] as int,
      totalAmountCents: json['totalAmountCents'] as int,
      comment: json['comment'] as String,
      quantity: json['quantity'] as int)
    ..kind = json['kind'] as String;
}

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'quantity': instance.quantity,
      'amountCents': instance.amountCents,
      'totalAmountCents': instance.totalAmountCents,
      'comment': instance.comment,
      'kind': instance.kind,
      'details': instance.details
    };

Cart _$CartFromJson(Map<String, dynamic> json) {
  return Cart(
      totalAmountCents: json['totalAmountCents'] as int,
      comment: json['comment'] as String)
    ..promo = json['promo'] as String
    ..items = (json['items'] as List)
        ?.map((e) =>
            e == null ? null : CartItem.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$CartToJson(Cart instance) => <String, dynamic>{
      'promo': instance.promo,
      'comment': instance.comment,
      'totalAmountCents': instance.totalAmountCents,
      'items': instance.items
    };

PaymentMean _$PaymentMeanFromJson(Map<String, dynamic> json) {
  return PaymentMean(
      type: json['type'] as String,
      name: json['name'] as String,
      ccNumber: json['ccNumber'] as String,
      ccExpiryMMYY: json['ccExpiryMMYY'] as String,
      ccSecurityCode: json['ccSecurityCode'] as String);
}

Map<String, dynamic> _$PaymentMeanToJson(PaymentMean instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'ccNumber': instance.ccNumber,
      'ccExpiryMMYY': instance.ccExpiryMMYY,
      'ccSecurityCode': instance.ccSecurityCode
    };

Payment _$PaymentFromJson(Map<String, dynamic> json) {
  return Payment(
      mean: json['mean'] == null
          ? null
          : PaymentMean.fromJson(json['mean'] as Map<String, dynamic>),
      status: json['status'] as String,
      amountPaidCents: json['amountPaidCents'] as int,
      paidAtUTCMs: json['paidAtUTCMs'] as int,
      transactionId: json['transactionId'] as String);
}

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
      'transactionId': instance.transactionId,
      'amountPaidCents': instance.amountPaidCents,
      'paidAtUTCMs': instance.paidAtUTCMs,
      'mean': instance.mean,
      'status': instance.status
    };

Order _$OrderFromJson(Map<String, dynamic> json) {
  return Order(
      cart: json['cart'] == null
          ? null
          : Cart.fromJson(json['cart'] as Map<String, dynamic>),
      payment: json['payment'] == null
          ? null
          : Payment.fromJson(json['payment'] as Map<String, dynamic>));
}

Map<String, dynamic> _$OrderToJson(Order instance) =>
    <String, dynamic>{'cart': instance.cart, 'payment': instance.payment};
