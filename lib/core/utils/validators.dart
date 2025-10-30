class Validators {
  static String? required(String? value, {String message = 'Required'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value, {String message = 'Invalid email'}) {
    if (value == null || value.isEmpty) return 'Required';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value)) return message;
    return null;
  }
}


