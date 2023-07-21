import 'charcodes.dart';

/// Returns the digit (0 through 15) corresponding to the hexadecimal code unit
/// at index [index] in [codeUnits].
///
/// If the given code unit isn't valid hexadecimal, throws a [FormatException].
int digitForCodeUnit(List<int> codeUnits, int index) {
  var codeUnit = codeUnits[index];
  var digit = $0 ^ codeUnit;

  if (digit <= 9) {
    if (digit >= 0) return digit;
  } else {
    var letter = 0x20 | codeUnit;
    if ($a <= letter && letter <= $f) return letter - $a + 10;
  }

  throw FormatException(
      'Invalid hexadecimal code unit '
      "U+${codeUnit.toRadixString(16).padLeft(4, '0')}.",
      codeUnits,
      index);
}
