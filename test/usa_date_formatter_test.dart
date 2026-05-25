import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noclevercode_suite/usa_date_formatter.dart';

TextEditingValue _value(String text) {
    return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
    );
}

void main() {
    late USADateFormatter formatter;

    setUp(() {
        formatter = USADateFormatter();
    });

    test('rejects non-digit, non-slash input', () {
        TextEditingValue oldValue = _value('1');
        TextEditingValue newValue = _value('1a');
        expect(formatter.formatEditUpdate(oldValue, newValue).text, '1');
    });

    test('accepts empty', () {
        expect(formatter.formatEditUpdate(_value('1'), _value('')).text, '');
    });

    test('accepts single digit month', () {
        expect(formatter.formatEditUpdate(_value(''), _value('1')).text, '1');
    });

    test('accepts two-digit valid month', () {
        expect(formatter.formatEditUpdate(_value('1'), _value('12')).text, '12');
    });

    test('rejects two-digit month above 12', () {
        TextEditingValue result = formatter.formatEditUpdate(_value('1'), _value('13'));
        expect(result.text, '1');
    });

    test('accepts month/day separator', () {
        expect(formatter.formatEditUpdate(_value('1'), _value('1/')).text, '1/');
    });

    test('auto-inserts slash after two-digit month', () {
        // typing '123' after having '12' becomes '12/3'
        TextEditingValue result = formatter.formatEditUpdate(_value('12'), _value('123'));
        expect(result.text, '12/3');
    });

    test('accepts full m/d/yyyy', () {
        expect(formatter.formatEditUpdate(_value('1/2/202'), _value('1/2/2024')).text, '1/2/2024');
    });

    test('rejects day exceeding month limit', () {
        // February has 28 days in the _monthDays table
        TextEditingValue result = formatter.formatEditUpdate(_value('2/2'), _value('2/29'));
        expect(result.text, '2/2');
    });

    test('auto-inserts slash after a two-digit day (single-digit month)', () {
        // "5/13" + typing "5" -> "5/13/5"
        TextEditingValue result = formatter.formatEditUpdate(_value('5/13'), _value('5/135'));
        expect(result.text, '5/13/5');
        expect(result.selection.baseOffset, 6);
    });

    test('auto-inserts slash after a two-digit day (two-digit month)', () {
        // "12/25" + typing "5" -> "12/25/5"
        TextEditingValue result = formatter.formatEditUpdate(_value('12/25'), _value('12/255'));
        expect(result.text, '12/25/5');
        expect(result.selection.baseOffset, 7);
    });

    test('accepts a single-digit-day separator: d/d/', () {
        TextEditingValue result = formatter.formatEditUpdate(_value('5/3'), _value('5/3/'));
        expect(result.text, '5/3/');
    });

    test('accepts a two-digit-day separator: dd/dd/', () {
        TextEditingValue result = formatter.formatEditUpdate(_value('12/25'), _value('12/25/'));
        expect(result.text, '12/25/');
    });

    test('rejects further input after a complete four-digit year', () {
        TextEditingValue result = formatter.formatEditUpdate(_value('5/3/2024'), _value('5/3/20245'));
        expect(result.text, '5/3/2024');
    });

    test('allows shrinking a complete date (backspacing)', () {
        TextEditingValue result = formatter.formatEditUpdate(_value('5/3/2024'), _value('5/3/202'));
        expect(result.text, '5/3/202');
    });

    test('rejects an unparseable length-4 paste rather than throwing', () {
        // Pasting "12/3" lands at length 4 with a slash at index 2 — not a
        // shape produced by natural typing. Must not throw on int.parse.
        TextEditingValue result = formatter.formatEditUpdate(_value(''), _value('12/3'));
        expect(result.text, '');
    });
}
