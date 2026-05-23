import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noclevercode_suite/simple_check.dart';

Widget _wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
}

void main() {
    testWidgets('renders the label text', (tester) async {
        await tester.pumpWidget(_wrap(SimpleCheck(
            label: 'Accept',
            onChange: (_) {},
        )));

        expect(find.text('Accept'), findsOneWidget);
        expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('toggling fires onChange', (tester) async {
        bool? observed;
        await tester.pumpWidget(_wrap(SimpleCheck(
            label: 'Accept',
            value: false,
            onChange: (value) => observed = value,
        )));

        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        expect(observed, isTrue);
    });

    testWidgets('disabled checkbox does not fire onChange', (tester) async {
        bool fired = false;
        await tester.pumpWidget(_wrap(SimpleCheck(
            label: 'Accept',
            value: false,
            disabled: true,
            onChange: (_) => fired = true,
        )));

        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        expect(fired, isFalse);
    });

    testWidgets('boxDecoration wraps in Container', (tester) async {
        await tester.pumpWidget(_wrap(SimpleCheck(
            label: 'Decorated',
            onChange: (_) {},
            boxDecoration: BoxDecoration(border: Border.all()),
        )));

        Finder containerWithDecoration = find.byWidgetPredicate((widget) {
            return widget is Container && widget.decoration is BoxDecoration;
        });
        expect(containerWithDecoration, findsOneWidget);
    });
}
