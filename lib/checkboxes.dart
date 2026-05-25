import 'package:flutter/material.dart';
import 'package:noclevercode_suite/common.dart';
import 'package:noclevercode_suite/strings.dart';
import 'package:noclevercode_suite/widget_utilities.dart';

/// Multi-select checkbox group laid out horizontally or vertically.
/// Selection order in the `onChange` callback matches the order of [labels].
class CheckBoxes extends StatefulWidget {
    final Strings labels;
    final BoxDecoration? boxDecoration;
    final TextStyle? textStyle;
    final Strings? selected;
    final OnStringsChange onChange;
    final Axis orientation;
    final NccTextAlign? verticalTextAlignment;
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
            crossAlignment = switch (this.widget.verticalTextAlignment) {
                NccTextAlign.start => CrossAxisAlignment.start,
                NccTextAlign.end => CrossAxisAlignment.end,
                null || NccTextAlign.center => CrossAxisAlignment.center,
            };
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
        List<Widget> children = [
            Checkbox(
                value: this._isSelected(label),
                onChanged: disabled ? null : (bool? value) => this.setState(() => this._toggleLabel(label)),
            ),
            Text(label, textAlign: TextAlign.start, maxLines: 1, style: textStyle),
        ];

        if (direction == TextDirection.rtl) {
            children = children.reversed.toList();
        }

        return Row(children: children);
    }

    bool _onSelect(String label) {
        bool result = !this._isSelected(label);
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

    bool _onDeselect(String label) {
        bool result = this._isSelected(label);
        if (result) {
            this.setState(() {
                this.selected.remove(label);
                // don't sort here as the sequence did not change with a removal
            });
            this.widget.onChange(this.selected);
        }
        return result;
    }

    bool _isSelected(String label) {
        return this.selected.contains(label);
    }

    void _toggleLabel(String label) {
        if (this._isSelected(label)) {
            this._onDeselect(label);
        } else {
            this._onSelect(label);
        }
    }
}

/// A single labeled checkbox built on top of [CheckBoxes]. Use [SimpleCheck]
/// (in `simple_check.dart`) for the haptic-feedback variant.
class SingleCheck extends StatelessWidget {
    final String label;
    final bool? value;
    final OnBoolChange onChange;
    final TextStyle? textStyle;
    final BoxDecoration? boxDecoration;
    final bool disabled;

    const SingleCheck({
        super.key,
        required this.label,
        required this.onChange,
        this.value = false,
        this.textStyle,
        this.disabled = false,
        this.boxDecoration,
    });

    @override
    Widget build(BuildContext context) {
        return CheckBoxes(
            labels: Strings([this.label]),
            selected: this.value == true ? Strings([this.label]) : null,
            disabled: this.disabled,
            boxDecoration: this.boxDecoration,
            textStyle: this.textStyle,
            onChange: (selected) {
                if (!this.disabled) {
                    this.onChange(selected.contains(this.label));
                }
            },
        );
    }
}
