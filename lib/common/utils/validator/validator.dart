class Validator {
  static String? nullOrEmptyValidation(String? value) {
    return (value ?? '').isEmpty ? 'This field is required' : null;
  }

  static String? emptyValidation(List<dynamic>? values) {
    return (values ?? []).isEmpty ? 'This field is required' : null;
  }

  static bool isNullOrEmpty(String? value) {
    return (value ?? '').isEmpty;
  }

  static bool isEmailValid(String? value) {
    if (value == null) {
      return false;
    }
    final RegExp rgx = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return rgx.hasMatch(value);
  }

  static String? passwordValidation(String? value) {
    if (Validator.isNullOrEmpty(value)) {
      return 'Password is required';
    }
    return null;
  }

  static String? emailValidation(String? value) {
    if (Validator.isNullOrEmpty(value)) {
      return 'Email is required';
    }
    return !isEmailValid(value) ? 'Invalid email' : null;
  }

  static bool passwordValidationCharacters(String? value) {
    if ((value ?? '').length < 8) {
      return false;
    }
    return true;
  }

  static bool passwordValidation1Lowercase(String? value) {
    final RegExp rgx = RegExp(r"(?=.*[a-z])");
    return rgx.hasMatch(value ?? '');
  }

  static bool passwordValidation1Uppercase(String? value) {
    final RegExp rgx = RegExp(r"(?=.*[A-Z])");
    return rgx.hasMatch(value ?? '');
  }

  static bool passwordValidationNumberAndSpecialCharacter(String? value) {
    final RegExp rgx = RegExp(r"(?=.*\d)(?=.*\W)");
    return rgx.hasMatch(value ?? '');
  }

  static String? addressValidation(String? value) {
    if (Validator.isNullOrEmpty(value)) {
      return 'Address is required';
    }
    return null;
  }

  static String? phoneValidation(String? value, {bool isRequired = true}) {
    if (Validator.isNullOrEmpty(value) && isRequired) {
      return 'Phone is required';
    }
    // final RegExp regExp = RegExp(r'(^(?:9)?[0-9]{10,12}$)');
    // if (!regExp.hasMatch(value ?? '')) {
    //   return Strings.invalidPhone;
    // }
    return null;
  }

  static bool isIpValid(String? value) {
    if (value == null) {
      return false;
    }
    final RegExp ipRegex = RegExp(
        r"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$");
    return ipRegex.hasMatch(value);
  }
}
