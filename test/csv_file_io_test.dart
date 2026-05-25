import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noclevercode_suite/csv_file_io.dart';
import 'package:noclevercode_suite/strings.dart';

void main() {
    TestWidgetsFlutterBinding.ensureInitialized();

    late Directory tempDir;
    const MethodChannel pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

    setUp(() async {
        tempDir = await Directory.systemTemp.createTemp('ncc_csv_io_');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
            pathProviderChannel,
            (MethodCall call) async {
                if (call.method == 'getApplicationDocumentsDirectory') {
                    return tempDir.path;
                }
                return null;
            },
        );
    });

    tearDown(() async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(pathProviderChannel, null);
        if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
        }
    });

    group('localFileWrite', () {
        test('writes content to a new file', () async {
            bool ok = await localFileWrite('out.txt', 'hello');
            expect(ok, isTrue);
            expect(await File('${tempDir.path}/out.txt').readAsString(), 'hello');
        });

        test('overwrites an existing file', () async {
            await File('${tempDir.path}/out.txt').writeAsString('old');
            bool ok = await localFileWrite('out.txt', 'new');
            expect(ok, isTrue);
            expect(await File('${tempDir.path}/out.txt').readAsString(), 'new');
        });
    });

    group('localFileAppend', () {
        test('creates the file when missing', () async {
            bool ok = await localFileAppend('log.txt', 'first');
            expect(ok, isTrue);
            expect(await File('${tempDir.path}/log.txt').readAsString(), 'first');
        });

        test('appends to existing content', () async {
            await File('${tempDir.path}/log.txt').writeAsString('first');
            bool ok = await localFileAppend('log.txt', '-second');
            expect(ok, isTrue);
            expect(await File('${tempDir.path}/log.txt').readAsString(), 'first-second');
        });
    });

    group('localFileRead', () {
        test('returns null when the file does not exist', () async {
            Strings? result = await localFileRead('missing.txt');
            expect(result, isNull);
        });

        test('returns lines split on newline', () async {
            await File('${tempDir.path}/data.txt').writeAsString('a\nb\nc');
            Strings? result = await localFileRead('data.txt');
            expect(result, isNotNull);
            expect(result!.toList(), ['a', 'b', 'c']);
        });
    });

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

}
