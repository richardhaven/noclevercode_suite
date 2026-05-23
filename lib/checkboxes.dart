import 'package:flutter/material.dart';
import 'package:noclevercode_suite/common.dart' as ncc_common;
import 'package:noclevercode_suite/strings.dart';
import 'package:noclevercode_suite/widget_utilities.dart';

/// Multi-select checkbox group laid out horizontally or vertically.
/// Selection order in the `onChange` callback matches the order of [labels].
class CheckBoxes extends StatefulWidget {
    final Strings labels;
    final BoxDecoration? boxDecoration;
    final TextStyle? textStyle;
    final Strings? selected;
    final ncc_common.OnStringsChange onChange;
    final Axis orientation;
    final ncc_common.TextAlign? verticalTextAlignment;
    final int spacing;
    final bool disabled;

    const CheckBoxes({
        super.key,
        required this.labels,
        required this.onChange,
        this.selected,
        this.boxDecoration,
        this.textStyle,
        this.orientation = Axis.horizontal,
        this.verticalTextAlignment,
        this.spacing = 0,
        this.disabled = false,
    });

    @override
    State<StatefulWidget> createState() => _CheckBoxesState();
}

class _CheckBoxesState extends State<CheckBoxes> {
    final _scrollController = ScrollController();
    Strings selected = Strings.empty(growable: true);

    @override
    void initState() {
        super.initState();

        if (this.widget.selected != null) {
            this.selected = this.widget.selected!;
        }
    }

    @override
    void dispose() {
        this._scrollController.dispose();

        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        List<Widget> boxes = List<Widget>.generate(this.widget.labels.length, (index) {
            return _createCheckbox(
                this.widget.labels[index],
                this.widget.spacing,
                Directionality.maybeOf(context),
                this.widget.disabled,
                this.widget.textStyle,
            );
        });

        if (this.widget.spacing != 0) {
            boxes = interleaveSpacers(boxes, this.widget.spacing, this.widget.orientation);
        }

        CrossAxisAlignment crossAlignment = CrossAxisAlignment.center;
        if (this.widget.orientation == Axis.vertical) {
            switch (this.widget.verticalTextAlignment) {
                case null || ncc_common.TextAlign.center:
                    crossAlignment = CrossAxisAlignment.center;
                    break;
                case ncc_common.TextAlign.start:
                    crossAlignment = CrossAxisAlignment.start;
                    break;
                case ncc_common.TextAlign.end:
                    crossAlignment = CrossAxisAlignment.end;
                    break;
            }
        }

        return createScrollingContainer(
            boxes,
            this._scrollController,
            boxDecoration: this.widget.boxDecoration,
            orientation: this.widget.orientation,
            mainAxisAlignment: this.widget.spacing == 0 ? MainAxisAlignment.spaceAround : MainAxisAlignment.start,
            crossAlignment: crossAlignment,
        );
    }

    Widget _createCheckbox(String label, int spacing, TextDirection? direction, bool disabled, TextStyle? textStyle) {
        var children = <Widget>[];

        children.add(Checkbox(
            value: this.isSelected(label),
            onChanged: (bool? value) => disabled ? null : this.setState(() => this.toggleLabel(label)),
        ));

        children.add(Text(label, textAlign: TextAlign.start, maxLines: 1, style: textStyle));

        if (direction == TextDirection.rtl) {
            var temp = children.first;
            children.first = children.last;
            children.last = temp;
        }

        return Row(children: children);
    }

    bool onSelect(String label) {
        bool result = !this.isSelected(label);
        if (result) {
            this.setState(() {
                this.selected.add(label);
                // report the selected labels in the order of the labels
                this.selected.sortByStrings(this.widget.labels);
            });
            this.widget.onChange(this.selected);
        }
        return result;
    }

    bool onDeselect(String label) {
        bool result = this.isSelected(label);
        if (result) {
            this.setState(() {
                this.selected.remove(label);
                // don't sort here as the sequence did not change with a removal
            });
            this.widget.onChange(this.selected);
        }
        return result;
    }

    bool isSelected(String label) {
        return this.selected.contains(label);
    }

    void toggleLabel(String label) {
        if (this.isSelected(label)) {
            this.onDeselect(label);
        } else {
            this.onSelect(label);
        }
    }
}

/// A single labeled checkbox built on top of [CheckBoxes]. Use [SimpleCheck]
/// (in `simple_check.dart`) for the haptic-feedback variant.
class SingleCheck extends StatelessWidget {
    final String label;
    final bool? value;
    final ncc_common.OnBoolChange onChange;
    final TextStyle? textStyle;
    final BoxDecoration? boxDecoration;
    final bool? disabled;

    const SingleCheck({
        super.key,
        required this.label,
        required this.onChange,
        this.value = false,
        this.textStyle,
        this.disabled,
        this.boxDecoration,
    });

    @override
    Widget build(BuildContext context) {
        return CheckBoxes(
            labels: Strings([this.label]),
            selected: this.value == true ? Strings([this.label]) : null,
            disabled: this.disabled == true,
            boxDecoration: this.boxDecoration,
            textStyle: this.textStyle,
            onChange: (selected) {
                if (this.disabled != true) {
                    this.onChange(selected.contains(this.label));
                }
            },
        );
    }
}
