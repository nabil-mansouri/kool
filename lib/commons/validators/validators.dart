typedef bool ValidatorSync<T>(T value);

class Validators {
  static ValidatorSync<T> compose<T>(List<ValidatorSync<T>> validators) {
    return (T value) {
      for (ValidatorSync<T> v in validators) {
        if (!v(value)) {
          return false;
        }
      }
      return true;
    };
  }

  static ValidatorSync<T> required<T>() {
    return (T value) {
      if (value == null) {
        return false;
      }
      if ("$value" == "") {
        return false;
      }
      return true;
    };
  }

  static ValidatorSync<T> pattern<T>(RegExp reg) {
    return (T value) {
      if (value == null) {
        return true;
      }
      return reg.hasMatch("$value");
    };
  }
}
