import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:async/async.dart';
import 'model.dart';
import '../store.dart';
import '../actions.dart';

typedef OnValidChanged = void Function(bool valid);
typedef OnChange = void Function(String value);
typedef Getter<STATE> = String Function(STATE state);
typedef Setter = void Function(String value);
typedef ValidatorSync = bool Function(Object value);
typedef VoidFunc = void Function(String newValue);
typedef OnFocusChanged = void Function(bool focused);

ValidatorSync _composeSync(List<ValidatorSync> validators) {
  if (validators == null || validators.length == 0) {
    return null;
  }
  return (Object value) {
    for (ValidatorSync v in validators) {
      if (!v(value)) {
        return false;
      }
    }
    return true;
  };
}

class FormFieldController<STATE> {
  final Getter getter;
  final Setter setter;
  final OnChange onChange;
  final int debounceChangesInMs;
  final OnValidChanged onValidChange;
  final OnFocusChanged onFocused;
  final ValidatorSync validator;
  final List<TextInputFormatter> formatters;
  FocusNode focusNode = FocusNode();

  //
  bool _valid = true;
  String _oldValue;
  CancelableOperation _previousOp;
  //
  final TextEditingController controller = TextEditingController();
  FormFieldController(
      {@required this.getter,
      this.setter,
      this.onChange,
      this.onValidChange,
      this.debounceChangesInMs,
      this.onFocused,
      List<ValidatorSync> validators,
      this.formatters})
      : validator = _composeSync(validators) {
    controller.addListener(() {
      _onNotifyListnener();
    });
    if (this.onFocused != null) {
      focusNode.addListener(() {
        this.onFocused(focusNode.hasFocus);
      });
    }
  }
  _onNotifyListnener() {
    _debounceOrNow(() {
      String newValue = controller.text;
      _updateValid(newValue);
      _updateChange(newValue);
    });
  }

  _debounceOrNow(VoidCallback call) {
    _previousOp?.cancel();
    if (debounceChangesInMs != null) {
      _previousOp = CancelableOperation.fromFuture(
          Future.delayed(Duration(milliseconds: debounceChangesInMs)));
      _previousOp.value.then((v) => call());
    } else {
      call();
    }
  }

  _updateChange(String newValue) {
    if (this.setter != null) {
      this.setter(newValue);
    }
    if (this.onChange != null) {
      this.onChange(newValue);
    }
  }

  _updateValid(String newValue) {
    if (this.validator != null) {
      var _newValid = this.validator(newValue);
      if (_newValid != _valid) {
        _valid = _newValid;
        if (this.onValidChange != null) this.onValidChange(_newValid);
      }
    }
  }

  bool refresh(STATE state) {
    final newValue = this.getter(state);
    if (_oldValue != newValue) {
      controller.text = newValue;
      _oldValue = newValue;
      return true;
    }
    return false;
  }

  get hasValue => controller.text != null && controller.text.trim().length > 0;
  get value => controller.text;

  get valid => _valid;

  clear() {
    controller.clear();
    _onNotifyListnener();
  }

  dispose() {
    controller.dispose();
  }
}

abstract class AbstractFormModel<STATE> extends AbstractModel<STATE> {
  final List<FormFieldController<STATE>> formFieldControllers = [];
  final int debounceChangesInMs;
  CancelableOperation _previousOp;
  AbstractFormModel({this.debounceChangesInMs}) : super();
  
  _debounceOrNow(VoidCallback call) {
    _previousOp?.cancel();
    if (debounceChangesInMs != null) {
      _previousOp = CancelableOperation.fromFuture(
          Future.delayed(Duration(milliseconds: debounceChangesInMs)));
      _previousOp.value.then((v) => call());
    } else {
      call();
    }
  }

  onFormChange() {}

  onFormValidChange() {}

  FormFieldController<STATE> createFormFieldController(
      {@required Getter getter,
      Setter setter,
      OnChange onChange,
      int debounceChangesInMs,
      OnValidChanged onValidChange,
      List<ValidatorSync> validators,
      OnFocusChanged onFocused,
      List<TextInputFormatter> formatters}) {
    final controller = FormFieldController<STATE>(
        getter: getter,
        setter: setter,
        onChange: (text) {
          if (onChange != null) onChange(text);
          _debounceOrNow(() => onFormChange());
        },
        onValidChange: (valid) {
          if (onValidChange != null) onValidChange(valid);
          _debounceOrNow(() => onFormValidChange());
        },
        debounceChangesInMs: debounceChangesInMs,
        validators: validators,
        onFocused: onFocused,
        formatters: formatters);
    formFieldControllers.add(controller);
    return controller;
  }

  @mustCallSuper
  refreshFormFieldControllers(Store store) {
    STATE state = store.getStateFor(stateType());
    this.formFieldControllers.forEach((f) => f.refresh(state));
  }

  @mustCallSuper
  clearFormFieldControllers() {
    this.formFieldControllers.forEach((f) => f.clear());
  }

  @mustCallSuper
  removeAllFormFieldControllers() {
    this.formFieldControllers.clear();
  }

  @mustCallSuper
  removeFormFieldControllers(FormFieldController controller) {
    this.formFieldControllers.removeWhere((test) => test == controller);
  }

  @mustCallSuper
  void onInitState(Store store) {
    //refresh model before refresh controllers
     super.onInitState(store);
    refreshFormFieldControllers(store);
  }

  @mustCallSuper
  void onStoreChanged(Store store) {
    super.onStoreChanged(store);
    refreshFormFieldControllers(store);
  }

  @mustCallSuper
  void onStateChanged(Store store, Action action) {
    //refresh model before refresh controllers
    super.onStateChanged(store, action);
    refreshFormFieldControllers(store);
  }

  @override
  onDispose() {
    this.formFieldControllers.forEach((f) => f.dispose());
    return super.onDispose();
  }
}
