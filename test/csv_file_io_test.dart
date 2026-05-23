import 'package:flutter_test/flutter_test.dart';
import 'package:noclevercode_suite/csv_file_io.dart';
import 'package:noclevercode_suite/strings.dart';

void main() {
    group('undelimitStrings', () {
        test('splits each row on commas', () {
            Strings input = Strings(['a,b,c', '1,2,3']);
            DelimitedStrings result = undelimitStrings(input);
            expect(result.length, 2);
            expect(result[0].toList(), ['a', 'b', 'c']);
            expect(result[1].toList(), ['1', '2', '3']);
        });

        test('empty input yields empty rows', () {
            DelimitedStrings result = undelimitStrings(Strings.empty());
            expect(result, isEmpty);
        });

        test('rows without commas become single-column rows', () {
            Strings input = Strings(['onlycol']);
            DelimitedStrings result = undelimitStrings(input);
            expect(result[0].toList(), ['onlycol']);
        });

        test('does not strip quotes or handle embedded commas', () {
            // Documents current behavior: '"a,b"' splits into two columns.
            Strings input = Strings(['"a,b",c']);
            DelimitedStrings result = undelimitStrings(input);
            expect(result[0].length, 3);
            expect(result[0][0], '"a');
            expect(result[0][1], 'b"');
        });
    });

    // localFileRead / localFileWrite / localFileAppend hit path_provider,
    // which needs a platform channel mock to test in pure Dart. Covered
    // indirectly by example-app smoke testing on real devices.
}
