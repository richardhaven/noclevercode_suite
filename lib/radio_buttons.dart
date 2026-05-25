import 'package:flutter/material.dart';
import 'package:noclevercode_suite/common.dart';
import 'package:noclevercode_suite/strings.dart';
import 'package:noclevercode_suite/widget_utilities.dart';

/// Single-select radio group over [labels]. The optional [selected] value
/// initializes the selection and is honored on parent updates.
class RadioButtons extends StatefulWidget {
    final Strings labels;
    final String? selected;
    final BoxDecoration? boxDecoration;
    final TextStyle? textStyle;
    final Axis orientation;
    final int spacing;
    final OnStringChange onChange;
    final bool disabled;

    const RadioButtons({
        super.key,
        required this.labels,
        required this.onChange,
        this.selected,
        this.boxDecoration,
        this.textStyle,
        this.orientation = Axis.horizontal,
        this.spacing = 0,
        this.disabled = false,
    });

    @override
    State<RadioButtons> createState() => _RadioButtonsState();
}

class _RadioButtonsState extends State<RadioButtons> {
    final _scrollController = ScrollController();
    String? currentSelection;

    @override
    void initState() {
        super.initState();
        currentSelection = this.widget.selected;
    }

    @override
    void didUpdateWidget(RadioButtons oldWidget) {
        super.didUpdateWidget(oldWidget);
        if (this.widget.selected != oldWidget.selected) {
            currentSelection = this.widget.selected;
        }
    }

    @override
    void dispose() {
        this._scrollController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        List<Widget> buttons = List<Widget>.generate(this.widget.labels.length, (index) {
            return _createRadioButton(
                this.widget.labels[index],
                Directionality.maybeOf(context),
                this.widget.disabled,
                this.widget.textStyle,
            );
        });

        if (this.widget.spacing > 0) {
            buttons = interleaveSpacers(buttons, this.widget.spacing, this.widget.orientation);
        }

        return createScrollingContainer(
            buttons,
            this._scrollController,
            boxDecoration: this.widget.boxDecoration,
            orientation: this.widget.orientation,
            mainAxisAlignment: this.widget.spacing == 0 ? MainAxisAlignment.spaceAround : MainAxisAlignment.start,
        );
    }

    Widget _createRadioButton(String label, TextDirection? direction, bool disabled, TextStyle? textStyle) {
        List<Widget> components = [
            Radio<String>(
                groupValue: this.currentSelection,
                value: label,
                onChanged: disabled ? null : (value) => this._setSelection(value!),
            ),
            Text(label, textAlign: TextAlign.left, maxLines: 1, style: textStyle),
        ];

        if (direction == TextDirection.rtl) {
            components = components.reversed.toList();
        }

        return GestureDetector(
            onTap: disabled ? null : () => this._setSelection(label),
            child: Row(children: components),
        );
    }

    void _setSelection(String? value) {
        this.setState(() {
            this.currentSelection = value;
            this.widget.onChange(value);
        });
    }
}
