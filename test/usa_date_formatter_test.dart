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
}
