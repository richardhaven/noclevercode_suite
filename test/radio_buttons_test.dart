import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noclevercode_suite/radio_buttons.dart';
import 'package:noclevercode_suite/strings.dart';

Widget _wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
}

void main() {
    testWidgets('renders one radio per label', (tester) async {
        await tester.pumpWidget(_wrap(RadioButtons(
            labels: Strings(['Yes', 'No', 'Maybe']),
            onChange: (_) {},
        )));

        expect(find.byType(Radio<String>), findsNWidgets(3));
        expect(find.text('Maybe'), findsOneWidget);
    });

    // Regression: `selected` was previously declared on the widget but never
    // read by the State; passing it had no effect.
    testWidgets('selected initializes the chosen radio', (tester) async {
        await tester.pumpWidget(_wrap(RadioButtons(
            labels: Strings(['Yes', 'No']),
            selected: 'No',
            onChange: (_) {},
        )));

        Iterable<Radio<String>> radios = tester.widgetList<Radio<String>>(find.byType(Radio<String>));
        expect(radios.elementAt(0).groupValue, 'No');
        expect(radios.elementAt(1).groupValue, 'No');
    });

    testWidgets('tapping radio fires onChange with label', (tester) async {
        String? observed;
        await tester.pumpWidget(_wrap(RadioButtons(
            labels: Strings(['Yes', 'No']),
            onChange: (value) => observed = value,
        )));

        await tester.tap(find.byType(Radio<String>).first);
        await tester.pump();

        expect(observed, 'Yes');
    });

    testWidgets('disabled blocks selection via row tap', (tester) async {
        bool fired = false;
        await tester.pumpWidget(_wrap(RadioButtons(
            labels: Strings(['Yes']),
            disabled: true,
            onChange: (_) => fired = true,
        )));

        await tester.tap(find.byType(Radio<String>));
        await tester.pump();

        expect(fired, isFalse);
    });

    testWidgets('didUpdateWidget honors parent selected change', (tester) async {
        Strings labels = Strings(['Yes', 'No']);
        await tester.pumpWidget(_wrap(RadioButtons(
            labels: labels,
            selected: 'Yes',
            onChange: (_) {},
        )));

        await tester.pumpWidget(_wrap(RadioButtons(
            labels: labels,
            selected: 'No',
            onChange: (_) {},
        )));
        await tester.pump();

        Radio<String> firstRadio = tester.widget(find.byType(Radio<String>).first);
        expect(firstRadio.groupValue, 'No');
    });
}
