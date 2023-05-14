String toTitle(String word) {
  return word[0].toUpperCase() + word.substring(1);
}

String dashedBetween(String word, int characters) {
  String specialCharacter = "";
  for (int i = 0; i < word.length; i++) {
    if (i + 1 > characters && i % characters == 0) {
      specialCharacter += "-";
    }

    specialCharacter += word[i];
  }

  return specialCharacter;
}

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) {
    return input;
  }

  final words = input.split(' ');
  final capitalizedWords = words.map((word) {
    if (word.isEmpty) {
      return word;
    }
    final firstLetter = word[0].toUpperCase();
    final remainingLetters = word.substring(1).toLowerCase();
    return '$firstLetter$remainingLetters';
  });

  return capitalizedWords.join(' ');
}