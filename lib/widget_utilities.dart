import 'package:flutter/material.dart';

/// Inserts a [SizedBox] of the given [spacing] between each adjacent pair
/// of [widgets]. The spacer's axis matches [orientation]. Returns [widgets]
/// unchanged when there is nothing to interleave.
List<Widget> interleaveSpacers(List<Widget> widgets, int spacing, Axis orientation) {
    if (widgets.isEmpty) {
        return widgets;
    }
    SizedBox spacer;
    if (orientation != Axis.vertical) {
        spacer = SizedBox(width: spacing.toDouble());
    } else {
        spacer = SizedBox(height: spacing.toDouble());
    }

    int numberOfSpacers = widgets.length - 1;

    List<Widget> result = List<Widget>.generate(widgets.length + numberOfSpacers, (index) {
        if (index.isEven) {
            return widgets[(index ~/ 2)];
        } else {
            return spacer;
        }
    });

    return result;
}

/// Wraps [children] in a [SingleChildScrollView] with a [Scrollbar],
/// laid out as a [Row] or [Column] per [orientation], inside an optional
/// decorated [Container].
Widget createScrollingContainer(
    List<Widget> children,
    ScrollController scrollController, {
    BoxDecoration? boxDecoration,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.spaceAround,
    Axis? orientation = Axis.horizontal,
    CrossAxisAlignment crossAlignment = CrossAxisAlignment.center,
}) {
    return Container(
        decoration: boxDecoration,
        child: Scrollbar(
            thickness: 10,
            radius: const Radius.circular(20),
            scrollbarOrientation: ScrollbarOrientation.bottom,
            controller: scrollController,
            child: SingleChildScrollView(
                scrollDirection: orientation ?? Axis.horizontal,
                clipBehavior: Clip.none,
                controller: scrollController,
                child: orientation == Axis.horizontal
                    ? Row(
                        mainAxisAlignment: mainAxisAlignment,
                        crossAxisAlignment: crossAlignment,
                        children: children,
                    )
                    : Column(
                        mainAxisAlignment: mainAxisAlignment,
                        crossAxisAlignment: crossAlignment,
                        children: children,
                    ),
            ),
        ),
    );
}
