import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A single labeled checkbox with optional decoration and haptic feedback
/// on tap. For multi-select use [CheckBoxes]; for a leaner haptic-free
/// single-checkbox API see `SingleCheck` in `checkboxes.dart`.
class SimpleCheck extends StatelessWidget {
    final String label;
    final bool? value;
    final Function(bool?)? onChange;
    final TextStyle? textStyle;
    final BoxDecoration? boxDecoration;
    final bool? disabled;

    const SimpleCheck({
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
        Function(bool?)? effectiveOnChange;
        if (this.disabled == true || this.onChange == null) {
            effectiveOnChange = null;
        } else {
            effectiveOnChange = (bool? value) {
                HapticFeedback.selectionClick();
                this.onChange!(value);
            };
        }

        Widget result = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
                Checkbox(value: value, onChanged: effectiveOnChange),
                const SizedBox(width: 10),
                Text(
                    this.label,
                    style: this.textStyle,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                ),
            ],
        );

        if (this.boxDecoration != null) {
            return Container(decoration: this.boxDecoration, child: result);
        } else {
            return result;
        }
    }
}
