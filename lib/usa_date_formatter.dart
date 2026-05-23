import 'package:flutter/services.dart';

// this allows m/d/yyyy, mm/d/yyyy, m/dd/yyyy, and mm/dd/yyyy

// note that DateFormat.yMd('en_US').tryParseLoose(newDate) can import this format

final _onlyDigitsAndSlashes = RegExp(r'^[0-9\/]*$');
final _hasYear = RegExp(r'[0-9]{4}$');
const _monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

/// [TextInputFormatter] that constrains entry to a US m/d/yyyy date as
/// the user types, auto-inserting separator slashes after the month and
/// day fields. Pair with `DateFormat.yMd('en_US').tryParseLoose` to read.
class USADateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    if (!_onlyDigitsAndSlashes.hasMatch(newText)) {
      return oldValue;
    }
    switch (newText.length) {
      case 0:
        return newValue;
      case 1:
        if (newText.substring(0, 1) != '/') {
          return newValue;
        }
      case 2:
        if (newText.substring(1, 2) == '/') {
          return newValue;
        }
        int monthValue = int.parse(newText);
        if (monthValue <= 12) {
          return newValue;
        }
      case 3:
        if (newText.substring(2, 3) == '/') {
          if (newText.substring(1, 2) != '/') {
            return newValue;
          }
        } else if (newText.substring(1, 2) != '/') {
          String nextText = '${newText.substring(0, 2)}/${newText.substring(2, 3)}';
          TextSelection newSelection = const TextSelection.collapsed(offset: 4);
          TextEditingValue result = newValue.copyWith(text: nextText, selection: newSelection);
          return result;
        } else {
          return newValue;
        }
      case 4:
        if (newText.substring(3, 4) == '/') {
          if (newText.substring(2, 3) != '/') {
            return newValue;
          }
        } else {
          int dayValue = int.parse(newText.substring(2, 4));
          int monthValue;
          if (newText.substring(1, 2) == '/') {
            monthValue = int.parse(newText.substring(0, 1));
          } else {
            monthValue = int.parse(newText.substring(0, 2));
          }
          if (dayValue <= _monthDays[monthValue - 1]) {
            return newValue;
          }
        }
      case 5:
        if (newText.substring(4, 5) == '/') {
          if (newText.substring(3, 4) != '/') {
            return newValue;
          }
        } else if (newText.substring(3, 4) == '/') {
          return newValue; // we're on years now
        } else if (newText.substring(1, 2) == '/') {
          String nextText = '${newText.substring(0, 4)}/${newText.substring(4, 5)}';
          TextSelection newSelection = const TextSelection.collapsed(offset: 6);
          TextEditingValue result = newValue.copyWith(text: nextText, selection: newSelection);
          return result;
        } else {
          int dayValue = int.parse(newText.substring(3, 5));
          int monthValue;
          if (newText.substring(1, 2) == '/') {
            monthValue = int.parse(newText.substring(0, 1));
          } else {
            monthValue = int.parse(newText.substring(0, 2));
          }
          if (dayValue <= _monthDays[monthValue - 1]) {
            return newValue;
          }
        }
      case 6:
        if (newText.substring(5, 6) == '/') {
          if ((newText.substring(4, 5) != '/') && (newText.substring(3, 4) != '/')) {
            return newValue;
          }
        } else if ((newText.substring(4, 5) != '/') && (newText.substring(2, 3) == '/')) {
          String nextText = '${newText.substring(0, 5)}/${newText.substring(5, 6)}';
          TextSelection newSelection = const TextSelection.collapsed(offset: 7);
          TextEditingValue result = newValue.copyWith(text: nextText, selection: newSelection);
          return result;
        } else {
          return newValue;
        }
      case 7:
      case 8:
      case 9:
      case 10:
        if ((newText.substring(newText.length - 1) != '/') && ((newText.length <= oldValue.text.length) || !_hasYear.hasMatch(oldValue.text))) {
          return newValue;
        }
    }
    return oldValue;
  }
}
