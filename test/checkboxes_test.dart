import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noclevercode_suite/checkboxes.dart';
import 'package:noclevercode_suite/strings.dart';

Widget _wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
}

void main() {
    group('CheckBoxes', () {
        testWidgets('renders one checkbox per label', (tester) async {
            await tester.pumpWidget(_wrap(CheckBoxes(
                labels: Strings(['One', 'Two', 'Three']),
                onChange: (_) {},
            )));

            expect(find.byType(Checkbox), findsNWidgets(3));
            expect(find.text('One'), findsOneWidget);
            expect(find.text('Three'), findsOneWidget);
        });

        testWidgets('initial selected pre-checks the matching boxes', (tester) async {
            await tester.pumpWidget(_wrap(CheckBoxes(
                labels: Strings(['One', 'Two']),
                selected: Strings(['Two'], growable: true),
                onChange: (_) {},
            )));

            Iterable<Checkbox> boxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
            expect(boxes.elementAt(0).value, isFalse);
            expect(boxes.elementAt(1).value, isTrue);
        });

        testWidgets('tapping a box adds to selection and fires onChange', (tester) async {
            Strings? observed;
            await tester.pumpWidget(_wrap(CheckBoxes(
                labels: Strings(['One', 'Two']),
                onChange: (selected) => observed = selected,
            )));

            await tester.tap(find.byType(Checkbox).first);
            await tester.pump();

            expect(observed, isNotNull);
            expect(observed!.toList(), ['One']);
        });

        testWidgets('disabled blocks selection', (tester) async {
            bool fired = false;
            await tester.pumpWidget(_wrap(CheckBoxes(
                labels: Strings(['One']),
                disabled: true,
                onChange: (_) => fired = true,
            )));

            await tester.tap(find.byType(Checkbox));
            await tester.pump();

            expect(fired, isFalse);
        });
    });

    group('SingleCheck', () {
        testWidgets('renders one checkbox + label', (tester) async {
            await tester.pumpWidget(_wrap(SingleCheck(
                label: 'Accept',
                onChange: (_) {},
            )));

            expect(find.byType(Checkbox), findsOneWidget);
            expect(find.text('Accept'), findsOneWidget);
        });

        testWidgets('fires onChange with new bool', (tester) async {
            bool? observed;
            await tester.pumpWidget(_wrap(SingleCheck(
                label: 'Accept',
                value: false,
                onChange: (value) => observed = value,
            )));

            await tester.tap(find.byType(Checkbox));
            await tester.pump();

            expect(observed, isTrue);
        });
    });
}
