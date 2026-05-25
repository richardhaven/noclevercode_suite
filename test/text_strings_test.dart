import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noclevercode_suite/common.dart';
import 'package:noclevercode_suite/strings.dart';
import 'package:noclevercode_suite/text_strings.dart';

Widget _wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
}

void main() {
    group('TextStrings widget', () {
        testWidgets('renders a TextField with initial content', (tester) async {
            await tester.pumpWidget(_wrap(SizedBox(
                width: 300,
                height: 80,
                child: TextStrings(
                    strings: Strings(['hello', 'world']),
                    lineCount: 2,
                    onChange: (_) {},
                ),
            )));

            expect(find.byType(TextField), findsOneWidget);
            TextField field = tester.widget(find.byType(TextField));
            expect(field.controller!.text, 'hello\nworld');
        });

        testWidgets('renders caption above by default', (tester) async {
            await tester.pumpWidget(_wrap(SizedBox(
                width: 300,
                height: 80,
                child: TextStrings(
                    caption: 'My label',
                    lineCount: 1,
                    onChange: (_) {},
                ),
            )));

            expect(find.text('My label'), findsOneWidget);
            expect(find.byType(Column), findsWidgets);
        });

        testWidgets('caption=leading places caption in a Row', (tester) async {
            await tester.pumpWidget(_wrap(SizedBox(
                width: 300,
                height: 80,
                child: TextStrings(
                    caption: 'L',
                    captionLocation: CaptionLocation.leading,
                    lineCount: 1,
                    onChange: (_) {},
                ),
            )));

            expect(find.text('L'), findsOneWidget);
        });

        // Regression: previously unconditionally wrapped its output in
        // Expanded, which crashed inside non-flex parents (e.g. Table cells,
        // raw Containers).
        testWidgets('does not crash inside a non-flex parent', (tester) async {
            await tester.pumpWidget(_wrap(SizedBox(
                width: 300,
                height: 100,
                child: TextStrings(
                    caption: 'inside sized box',
                    lineCount: 1,
                    boxDecoration: BoxDecoration(border: Border.all()),
                    onChange: (_) {},
                ),
            )));

            expect(tester.takeException(), isNull);
            expect(find.byType(TextField), findsOneWidget);
        });

        testWidgets('does not crash inside a Table cell', (tester) async {
            await tester.pumpWidget(_wrap(Table(
                defaultColumnWidth: const FixedColumnWidth(300),
                children: [
                    TableRow(children: [
                        TextStrings(
                            caption: 'in table',
                            lineCount: 1,
                            boxDecoration: BoxDecoration(border: Border.all()),
                            onChange: (_) {},
                        ),
                    ]),
                ],
            )));

            expect(tester.takeException(), isNull);
        });

        testWidgets('typing fires onChange immediately when no delay set', (tester) async {
            Strings? observed;
            await tester.pumpWidget(_wrap(SizedBox(
                width: 300,
                height: 60,
                child: TextStrings(
                    lineCount: 1,
                    onChange: (value) => observed = value,
                ),
            )));

            await tester.enterText(find.byType(TextField), 'hello');
            await tester.pump();

            expect(observed, isNotNull);
            expect(observed!.toList(), ['hello']);
        });

        testWidgets('aggregateDelay defers onChange until after the delay', (tester) async {
            Strings? observed;
            await tester.pumpWidget(_wrap(SizedBox(
                width: 300,
                height: 60,
                child: TextStrings(
                    lineCount: 1,
                    aggregateDelay: 300,
                    onChange: (value) => observed = value,
                ),
            )));

            await tester.enterText(find.byType(TextField), 'hi');
            await tester.pump();
            expect(observed, isNull);

            await tester.pump(const Duration(milliseconds: 350));
            expect(observed, isNotNull);
            expect(observed!.toList(), ['hi']);
        });

        testWidgets('aggregateDelay restarts on each keystroke', (tester) async {
            int callCount = 0;
            await tester.pumpWidget(_wrap(SizedBox(
                width: 300,
                height: 60,
                child: TextStrings(
                    lineCount: 1,
                    aggregateDelay: 300,
                    onChange: (_) => callCount++,
                ),
            )));

            await tester.enterText(find.byType(TextField), 'a');
            await tester.pump(const Duration(milliseconds: 200));
            await tester.enterText(find.byType(TextField), 'ab');
            await tester.pump(const Duration(milliseconds: 200));
            // Neither keystroke's 300 ms window has closed yet.
            expect(callCount, 0);

            await tester.pump(const Duration(milliseconds: 150));
            expect(callCount, 1);
        });

        testWidgets('maxAggregateDelay fires even while keystrokes keep coming', (tester) async {
            int callCount = 0;
            await tester.pumpWidget(_wrap(SizedBox(
                width: 300,
                height: 60,
                child: TextStrings(
                    lineCount: 1,
                    aggregateDelay: 300,
                    maxAggregateDelay: 500,
                    onChange: (_) => callCount++,
                ),
            )));

            // Type every 150 ms — fast enough to keep resetting the 300 ms
            // debounce, but the 500 ms ceiling should still fire.
            for (int index = 0; index < 4; index++) {
                await tester.enterText(find.byType(TextField), 'x' * (index + 1));
                await tester.pump(const Duration(milliseconds: 150));
            }
            // 600 ms elapsed: ceiling (500 ms) has passed.
            expect(callCount, greaterThanOrEqualTo(1));
        });

        testWidgets('disabled blocks input', (tester) async {
            await tester.pumpWidget(_wrap(SizedBox(
                width: 300,
                height: 60,
                child: TextStrings(
                    lineCount: 1,
                    disabled: true,
                    onChange: (_) {},
                ),
            )));

            TextField field = tester.widget(find.byType(TextField));
            expect(field.enabled, isFalse);
        });
    });

    group('calculateLineCount', () {
        test('single short line returns 1', () {
            expect(calculateLineCount('short'), 1);
        });

        test('newline-separated text counts the newlines', () {
            expect(calculateLineCount('a\nb\nc'), 2);
        });

        test('long single line wraps at 50 chars', () {
            String longLine = 'x' * 60;
            expect(calculateLineCount(longLine), greaterThanOrEqualTo(2));
        });
    });
}
