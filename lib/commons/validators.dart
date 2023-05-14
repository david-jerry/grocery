bool validateAlphabetsOnly(String value) {
  // Define the regex pattern for alphabets only
  final RegExp alphabetsOnlyRegex = RegExp(r'^[a-zA-Z]+$');

  // Check if the value matches the regex pattern
  return alphabetsOnlyRegex.hasMatch(value);
}

bool validatePassword(String value) {
  // Define the regex pattern for password validation
  final RegExp passwordRegex = RegExp(
    r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
  );

  // Check if the value matches the regex pattern
  return passwordRegex.hasMatch(value);
}

bool validateMinimumLength(String value, int minLength) {
  // check if value is greater than or equal to minimum length
  return value.trim().length >= minLength;
}

bool validateMaximumLength(String value, int maxLength) {
  // check if value is lesser than or equal to maximum length
  return value.trim().length <= maxLength;
}

bool validateMinimumNumber(String value, int minNumber) {
  // check if value is greater than or equal to minimum length
  return int.parse(value.trim()) >= minNumber;
}

bool validateMaximumNumber(String value, int maxNumber) {
  // check if value is lesser than or equal to maximum length
  return int.parse(value.trim()) <= maxNumber;
}

bool validateRequired(String value) {
  // check if value is fulfills required status
  return value.trim().isNotEmpty;
}

bool validateNumeric(String value) {
  // check if the value is made of numbers and not double or decimals
  return double.tryParse(value.trim()) != null;
}
