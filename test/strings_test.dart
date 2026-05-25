import 'package:flutter_test/flutter_test.dart';
import 'package:noclevercode_suite/strings.dart';

void main() {
    group('Strings constructors', () {
        test('default with null builds empty', () {
            Strings strings = Strings(null);
            expect(strings.length, 0);
        });

        test('default with values', () {
            Strings strings = Strings(['a', 'b', 'c']);
            expect(strings.length, 3);
            expect(strings[0], 'a');
            expect(strings[2], 'c');
        });

        test('Strings.fixed fills with empty strings', () {
            Strings strings = Strings.fixed(3);
            expect(strings.length, 3);
            expect(strings.every((string) => string.isEmpty), isTrue);
        });

        test('Strings.empty defaults to growable', () {
            Strings strings = Strings.empty();
            expect(strings.length, 0);
            expect(strings.growable, isTrue);
        });

        test('Strings.generate', () {
            Strings strings = Strings.generate(3, (index) => 'item$index');
            expect(strings.toList(), ['item0', 'item1', 'item2']);
        });

        test('Strings.from copies', () {
            List<String> source = ['x', 'y'];
            Strings strings = Strings.from(source);
            source.clear();
            expect(strings.toList(), ['x', 'y']);
        });
    });

    group('Strings.text', () {
        test('joins with newline', () {
            expect(Strings(['a', 'b', 'c']).text, 'a\nb\nc');
        });

        test('empty list yields empty string', () {
            expect(Strings.empty().text, '');
        });
    });

    group('Strings length setter', () {
        test('fixed-length throws on resize', () {
            Strings strings = Strings(['a', 'b']);
            expect(() => strings.length = 5, throwsUnsupportedError);
        });

        test('growable extends with empty strings', () {
            Strings strings = Strings.empty(growable: true);
            strings.length = 3;
            expect(strings.toList(), ['', '', '']);
        });

        test('no-op when length unchanged', () {
            Strings strings = Strings(['a']);
            strings.length = 1;
            expect(strings[0], 'a');
        });
    });

    group('Strings.sortByStrings', () {
        test('orders by reference list position', () {
            Strings reference = Strings(['x', 'y', 'z']);
            Strings target = Strings(['z', 'x', 'y'], growable: true);
            target.sortByStrings(reference);
            expect(target.toList(), ['x', 'y', 'z']);
        });

        test('unknown items sort after by lexical order', () {
            Strings reference = Strings(['known']);
            Strings target = Strings(['z', 'known', 'a'], growable: true);
            target.sortByStrings(reference);
            expect(target.toList(), ['known', 'a', 'z']);
        });
    });

    group('Strings.indexOfLeadingText', () {
        test('finds the first element starting with the given prefix', () {
            Strings strings = Strings(['apple', 'banana', 'apricot']);
            expect(strings.indexOfLeadingText('app'), 0);
            expect(strings.indexOfLeadingText('ban'), 1);
            expect(strings.indexOfLeadingText('apr'), 2);
        });
        test('returns -1 when no element matches', () {
            Strings strings = Strings(['apple', 'banana']);
            expect(strings.indexOfLeadingText('xyz'), -1);
        });
        test('empty prefix matches the first element', () {
            Strings strings = Strings(['apple', 'banana']);
            expect(strings.indexOfLeadingText(''), 0);
        });
        test('returns -1 on an empty list regardless of prefix', () {
            Strings strings = Strings([]);
            expect(strings.indexOfLeadingText(''), -1);
            expect(strings.indexOfLeadingText('a'), -1);
        });
    });

    group('Strings.copy', () {
        test('produces an independent list', () {
            Strings original = Strings(['a', 'b'], growable: true);
            Strings copied = original.copy();
            expect(copied.toList(), ['a', 'b']);
            expect(identical(original, copied), isFalse);
        });
    });

    group('String extensions', () {
        test('countOfCharacter', () {
            expect('aabba'.countOfCharacter('a'), 3);
            expect(''.countOfCharacter('a'), 0);
            expect('xyz'.countOfCharacter('a'), 0);
        });

        test('equalsIgnoreCase', () {
            expect('Hello'.equalsIgnoreCase('HELLO'), isTrue);
            expect('Hello'.equalsIgnoreCase('World'), isFalse);
        });

        test('equalsLeadingIgnoreCase compares shared-length prefix', () {
            expect('Apple'.equalsLeadingIgnoreCase('app'), isTrue);
            expect('App'.equalsLeadingIgnoreCase('Apple'), isTrue);
            expect('Pear'.equalsLeadingIgnoreCase('app'), isFalse);
        });

        test('substr with positive bounds', () {
            expect('abcdef'.substr(1, 4), 'bcd');
        });

        test('substr with negative start counts from end', () {
            expect('abcdef'.substr(-3), 'def');
        });

        test('substr defaults end to length', () {
            expect('abc'.substr(1), 'bc');
        });
    });
}
