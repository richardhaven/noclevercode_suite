import 'package:flutter/services.dart';

// Accepts m/d/yyyy, mm/d/yyyy, m/dd/yyyy, and mm/dd/yyyy as the user types,
// auto-inserting slashes after a complete month and day field.
//
// Parse the resulting text with `DateFormat.yMd('en_US').tryParseLoose`.

final _onlyDigitsAndSlashes = RegExp(r'^[0-9\/]*$');
final _hasYear = RegExp(r'[0-9]{4}$');
const _monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

/// [TextInputFormatter] that constrains entry to a US m/d/yyyy date as the
/// user types, auto-inserting separator slashes after the month and day fields.
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
                return _handleLength1(newText, newValue, oldValue);
            case 2:
                return _handleLength2(newText, newValue, oldValue);
            case 3:
                return _handleLength3(newText, newValue, oldValue);
            case 4:
                return _handleLength4(newText, newValue, oldValue);
            case 5:
                return _handleLength5(newText, newValue, oldValue);
            case 6:
                return _handleLength6(newText, newValue, oldValue);
            case 7:
            case 8:
            case 9:
            case 10:
                return _handleYearTail(newText, newValue, oldValue);
            default:
                return oldValue;
        }
    }

    /// First character: anything that isn't a leading slash is acceptable.
    TextEditingValue _handleLength1(String newText, TextEditingValue newValue, TextEditingValue oldValue) {
        if (newText[0] != '/') {
            return newValue;
        }
        return oldValue;
    }

    /// Two characters: either "d/" or a two-digit month <= 12.
    TextEditingValue _handleLength2(String newText, TextEditingValue newValue, TextEditingValue oldValue) {
        if (newText[1] == '/') {
            return newValue;
        }
        int monthValue = int.parse(newText);
        if (monthValue <= 12) {
            return newValue;
        }
        return oldValue;
    }

    /// Three characters: "d/d" passes through, "dd" + next-digit autoslashes
    /// to "dd/d".
    TextEditingValue _handleLength3(String newText, TextEditingValue newValue, TextEditingValue oldValue) {
        bool slashAtIndex2 = newText[2] == '/';
        bool slashAtIndex1 = newText[1] == '/';

        if (slashAtIndex2) {
            // Trailing slash is only valid when it follows a single-digit month, e.g. "5/".
            return slashAtIndex1 ? oldValue : newValue;
        }
        if (slashAtIndex1) {
            // "d/d" — single-digit month and single-digit day so far.
            return newValue;
        }
        // "ddd" — month already two digits, autoslash before the day.
        return _autoslashAfter(newValue, sliceEnd: 2, tailStart: 2, caretOffset: 4);
    }

    /// Four characters: a trailing '/' is valid only when it follows a
    /// non-slash at index 2 (i.e. "d/d/"); otherwise validate the day
    /// against the parsed month.
    TextEditingValue _handleLength4(String newText, TextEditingValue newValue, TextEditingValue oldValue) {
        if (newText[3] == '/') {
            return newText[2] != '/' ? newValue : oldValue;
        }
        // For a length-4 "dd?d?" without a trailing slash, the only natural
        // shape is "dd/d" (post-autoslash). Reject pastes whose slash sits
        // somewhere unparseable rather than throwing in int.parse below.
        if (newText[0] == '/' || newText[2] == '/') {
            return oldValue;
        }
        int month = _parseMonth(newText);
        int day = int.parse(newText.substring(2, 4));
        return day <= _monthDays[month - 1] ? newValue : oldValue;
    }

    /// Five characters: cover "d/dd/", "dd/d/", "dd/dd" (autoslash), and
    /// "d/d/y" (start of year).
    TextEditingValue _handleLength5(String newText, TextEditingValue newValue, TextEditingValue oldValue) {
        bool slashAtIndex4 = newText[4] == '/';
        bool slashAtIndex3 = newText[3] == '/';
        bool slashAtIndex1 = newText[1] == '/';

        if (slashAtIndex4) {
            // A trailing '/' here is the day-separator (e.g. "12/3/"); double-slash is invalid.
            return !slashAtIndex3 ? newValue : oldValue;
        }
        if (slashAtIndex3) {
            // "d/d/y" — typing the first year digit.
            return newValue;
        }
        if (slashAtIndex1) {
            // "d/ddd" — autoslash before the year.
            return _autoslashAfter(newValue, sliceEnd: 4, tailStart: 4, caretOffset: 6);
        }
        // "dd/dd" — validate the two-digit day against the two-digit month.
        int month = int.parse(newText.substring(0, 2));
        int day = int.parse(newText.substring(3, 5));
        return day <= _monthDays[month - 1] ? newValue : oldValue;
    }

    /// Six characters: covers "dd/dd/" (trailing slash) and "dd/ddy" (autoslash
    /// before the year). Anything else is rejected.
    TextEditingValue _handleLength6(String newText, TextEditingValue newValue, TextEditingValue oldValue) {
        if (newText[5] == '/') {
            bool dayFieldEndsHere = newText[4] == '/' || newText[3] == '/';
            return dayFieldEndsHere ? oldValue : newValue;
        }
        if (newText[4] != '/' && newText[2] == '/') {
            // "dd/ddy" — autoslash before the year digit.
            return _autoslashAfter(newValue, sliceEnd: 5, tailStart: 5, caretOffset: 7);
        }
        return newValue;
    }

    /// Lengths 7-10: the year tail. Allow growth only while the year hasn't
    /// reached four digits yet; allow shrinking always.
    TextEditingValue _handleYearTail(String newText, TextEditingValue newValue, TextEditingValue oldValue) {
        bool endsWithSlash = newText[newText.length - 1] == '/';
        bool shrinking = newText.length <= oldValue.text.length;
        bool yearAlreadyComplete = _hasYear.hasMatch(oldValue.text);
        if (!endsWithSlash && (shrinking || !yearAlreadyComplete)) {
            return newValue;
        }
        return oldValue;
    }

    /// Returns the month value parsed from the start of [newText], using the
    /// position of the first '/' to decide whether it's one or two digits.
    int _parseMonth(String newText) {
        if (newText[1] == '/') {
            return int.parse(newText[0]);
        }
        return int.parse(newText.substring(0, 2));
    }

    /// Inserts a '/' between `newValue.text[0..sliceEnd]` and
    /// `newValue.text[tailStart..]`, moving the caret to [caretOffset].
    TextEditingValue _autoslashAfter(TextEditingValue newValue, {required int sliceEnd, required int tailStart, required int caretOffset}) {
        String nextText = '${newValue.text.substring(0, sliceEnd)}/${newValue.text.substring(tailStart)}';
        return newValue.copyWith(
            text: nextText,
            selection: TextSelection.collapsed(offset: caretOffset),
        );
    }
}
