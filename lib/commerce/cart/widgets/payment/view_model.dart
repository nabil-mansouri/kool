import 'package:masked_text_input_formatter/masked_text_input_formatter.dart';
import 'package:food/multiflow/multiflow.dart';
import '../../store/store.dart';
import '../../domain/domain.dart';

class PaymentViewModel extends AbstractFormModel<CartState> {
  PaymentMean paymentMean;
  PaymentMean paymentMeanNext;
  FormFieldController ccvController;
  FormFieldController cardNumberController;
  FormFieldController expiryController;
  PaymentViewModel() : super(debounceChangesInMs: 350) {
    ccvController = createFormFieldController(
      getter: (s) => this.paymentMean?.ccSecurityCode,
      setter: (s) => this.paymentMeanNext?.ccSecurityCode = s,
      formatters: [
        MaskedTextInputFormatter(mask: 'XXX', separator: '-'),
      ],
    );
    cardNumberController = createFormFieldController(
      getter: (s) => this.paymentMean?.ccNumber,
      setter: (s) => this.paymentMeanNext?.ccNumber = s,
      formatters: [
        MaskedTextInputFormatter(
          mask: 'xxxx-xxxx-xxxx-xxxx',
          separator: '-',
        ),
      ],
    );
    expiryController = createFormFieldController(
        getter: (s) => this.paymentMean?.ccExpiryMMYY,
        setter: (s) => this.paymentMeanNext?.ccExpiryMMYY = s,
        formatters: [
          MaskedTextInputFormatter(
            mask: 'MM/YY',
            separator: '/',
          ),
        ]);
  }
  onFormChange() {
    _updatePaymentMeanStore();
  }

  bool refresh(CartState state) {
    bool changed = false;
    if (this.paymentMean != state.paymentMean) {
      this.paymentMean = state.paymentMean;
      this.paymentMeanNext = this.paymentMean.copy();
      changed = true;
    }
    return changed;
  }

  List<String> get paymentTypes {
    return [PaymentMean.CC_VISA, PaymentMean.CC_MASTERCARD, PaymentMean.PAYPAL];
  }

  isSelectedType(String type) {
    return paymentMean.type == type;
  }

  _updatePaymentMeanStore() {
    final _lastContext = lastContext.orElseGet(() => null);
    if (_lastContext != null) {
      getStore<CartStore>(_lastContext, CartStore)
          .updatePaymentMean(paymentMean);
    }
  }

  selectType(String type) {
    paymentMean.type = type;
    this.clearFormFieldControllers();
    this.notifyListeners();
  }

  getImgUrl(String type) {
    switch (type) {
      case PaymentMean.CC_VISA:
        return "assets/images/visa.png";
      case PaymentMean.CC_MASTERCARD:
        return "assets/images/mastercard.png";
      case PaymentMean.PAYPAL:
        return "assets/images/paypal.png";
    }
    return null;
  }

  isCreditCard() {
    return [PaymentMean.CC_VISA, PaymentMean.CC_MASTERCARD]
        .contains(this.paymentMean.type);
  }
}
