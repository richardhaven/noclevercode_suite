import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noclevercode_suite/common.dart';
import 'package:noclevercode_suite/working_button.dart';

Widget _wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
}

void main() {
    testWidgets('shows caption when idle', (tester) async {
        await tester.pumpWidget(_wrap(WorkingButton(
            caption: 'Submit',
            onPress: (_) {},
        )));

        expect(find.text('Submit'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('press swaps to workingCaption until doneWorking', (tester) async {
        OnEvent? captured;
        await tester.pumpWidget(_wrap(WorkingButton(
            caption: 'Submit',
            workingCaption: 'Submitting…',
            onPress: (doneWorking) => captured = doneWorking,
        )));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(find.text('Submitting…'), findsOneWidget);
        expect(find.text('Submit'), findsNothing);

        captured!.call();
        await tester.pump();

        expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('disabled button does not invoke onPress', (tester) async {
        bool fired = false;
        await tester.pumpWidget(_wrap(WorkingButton(
            caption: 'Submit',
            disabled: true,
            onPress: (_) => fired = true,
        )));

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(fired, isFalse);
    });

    testWidgets('hint renders a Tooltip', (tester) async {
        await tester.pumpWidget(_wrap(WorkingButton(
            caption: 'Submit',
            hint: 'click me',
            onPress: (_) {},
        )));

        expect(find.byType(Tooltip), findsOneWidget);
    });
}
