import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noclevercode_suite/dropdown_picker.dart';
import 'package:noclevercode_suite/strings.dart';

Widget _wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
}

void main() {
    testWidgets('null labels renders fallback', (tester) async {
        await tester.pumpWidget(_wrap(DropdownPicker(
            labels: null,
            onChange: (_) {},
        )));

        expect(find.text('----'), findsOneWidget);
    });

    testWidgets('empty labels renders fallback', (tester) async {
        await tester.pumpWidget(_wrap(DropdownPicker(
            labels: Strings(const []),
            onChange: (_) {},
        )));

        expect(find.text('----'), findsOneWidget);
    });

    testWidgets('renders dropdown items', (tester) async {
        await tester.pumpWidget(_wrap(DropdownPicker(
            labels: Strings(['Red', 'Green', 'Blue']),
            selected: 'Red',
            onChange: (_) {},
        )));

        expect(find.byType(DropdownButton<String>), findsOneWidget);
        expect(find.text('Red'), findsOneWidget);
    });

    // Regression: autoselectSole was previously dead because the @override
    // sat on the wrong class (StatefulWidget instead of State).
    testWidgets('autoselectSole reports the lone label via onChange', (tester) async {
        String? reported;
        await tester.pumpWidget(_wrap(DropdownPicker(
            labels: Strings(['Only']),
            onChange: (value) => reported = value,
        )));

        await tester.pump(); // run postFrameCallback

        expect(reported, 'Only');
    });

    testWidgets('autoselectSole=false does not auto-fire', (tester) async {
        String? reported;
        await tester.pumpWidget(_wrap(DropdownPicker(
            labels: Strings(['Only']),
            autoselectSole: false,
            onChange: (value) => reported = value,
        )));

        await tester.pump();

        expect(reported, isNull);
    });

    testWidgets('didUpdateWidget honors parent selected change', (tester) async {
        Strings labels = Strings(['A', 'B']);
        await tester.pumpWidget(_wrap(DropdownPicker(
            labels: labels,
            selected: 'A',
            onChange: (_) {},
        )));

        await tester.pumpWidget(_wrap(DropdownPicker(
            labels: labels,
            selected: 'B',
            onChange: (_) {},
        )));
        await tester.pump();

        DropdownButton<String> button = tester.widget(find.byType(DropdownButton<String>));
        expect(button.value, 'B');
    });
}
