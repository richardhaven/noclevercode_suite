import 'package:flutter_test/flutter_test.dart';
import 'package:noclevercode_suite/common.dart';

void main() {
    group('nullOrBlank', () {
        test('true for null', () => expect(nullOrBlank(null), isTrue));
        test('true for empty', () => expect(nullOrBlank(''), isTrue));
        test('false for whitespace (not trimmed)', () => expect(nullOrBlank(' '), isFalse));
        test('false for content', () => expect(nullOrBlank('hello'), isFalse));
    });

    group('nullOrZero', () {
        test('true for null', () => expect(nullOrZero(null), isTrue));
        // Regression: prior to fix, this returned false for 0 and true for non-zero.
        test('true for 0', () => expect(nullOrZero(0), isTrue));
        test('false for positive', () => expect(nullOrZero(1), isFalse));
        test('false for negative', () => expect(nullOrZero(-1), isFalse));
    });
}
