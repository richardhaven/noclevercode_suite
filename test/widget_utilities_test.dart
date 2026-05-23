import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noclevercode_suite/widget_utilities.dart';

Widget _wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
}

void main() {
    group('interleaveSpacers', () {
        test('returns input unchanged when empty', () {
            List<Widget> input = [];
            List<Widget> result = interleaveSpacers(input, 10, Axis.horizontal);
            expect(result, same(input));
        });

        test('single item gets no spacer', () {
            List<Widget> input = [const Text('one')];
            List<Widget> result = interleaveSpacers(input, 10, Axis.horizontal);
            expect(result.length, 1);
        });

        test('three items get two spacers interleaved', () {
            List<Widget> input = [const Text('a'), const Text('b'), const Text('c')];
            List<Widget> result = interleaveSpacers(input, 8, Axis.horizontal);
            expect(result.length, 5);
            expect(result[1], isA<SizedBox>());
            expect(result[3], isA<SizedBox>());
            expect((result[1] as SizedBox).width, 8.0);
        });

        test('vertical orientation produces height spacer', () {
            List<Widget> input = [const Text('a'), const Text('b')];
            List<Widget> result = interleaveSpacers(input, 12, Axis.vertical);
            expect((result[1] as SizedBox).height, 12.0);
            expect((result[1] as SizedBox).width, isNull);
        });
    });

    group('createScrollingContainer', () {
        testWidgets('horizontal places children in a Row', (tester) async {
            ScrollController controller = ScrollController();
            await tester.pumpWidget(_wrap(SizedBox(
                width: 200,
                height: 60,
                child: createScrollingContainer(
                    [const Text('a'), const Text('b')],
                    controller,
                ),
            )));

            expect(find.byType(Row), findsOneWidget);
            expect(find.byType(Scrollbar), findsOneWidget);
            controller.dispose();
        });

        testWidgets('vertical places children in a Column', (tester) async {
            ScrollController controller = ScrollController();
            await tester.pumpWidget(_wrap(SizedBox(
                width: 60,
                height: 200,
                child: createScrollingContainer(
                    [const Text('a'), const Text('b')],
                    controller,
                    orientation: Axis.vertical,
                ),
            )));

            // A Column is used for the scrolling content; Scaffold also has one,
            // so allow >=1.
            expect(find.byType(Column), findsWidgets);
            controller.dispose();
        });
    });
}
