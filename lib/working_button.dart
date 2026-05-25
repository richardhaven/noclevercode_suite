import 'package:flutter/material.dart';
import 'package:noclevercode_suite/common.dart';

/// Callback signature for [WorkingButton.onPress] / [WorkingButton.onLongPress].
/// Invoke the `doneWorking` parameter to clear the working state.
typedef OnWorkingPress = void Function(OnEvent doneWorking);

/// An [ElevatedButton] that flips into a "working" state for the duration
/// of an async [onPress]. While working it can optionally swap its caption
/// ([workingCaption]), hint ([workingHint]), and disable itself
/// ([disableWhileWorking]). Call the supplied `doneWorking` callback from
/// inside your handler to leave the working state.
class WorkingButton extends StatefulWidget {
    final String caption;
    final String? workingCaption;
    final OnWorkingPress onPress;
    final OnWorkingPress? onLongPress;
    final bool disabled;
    final bool disableWhileWorking;

    final FocusNode? focusNode;
    final bool autofocus;
    final TextStyle? textStyle;
    final ButtonStyle? buttonStyle;

    final String? hint;
    final String? workingHint;
    final String? disabledHint;

    const WorkingButton({
        super.key,
        required this.caption,
        this.workingCaption,
        required this.onPress,
        this.onLongPress,
        this.hint,
        this.workingHint,
        this.disabledHint,
        this.focusNode,
        this.disabled = false,
        this.disableWhileWorking = true,
        this.autofocus = false,
        this.textStyle,
        this.buttonStyle,
    });

    @override
    State<StatefulWidget> createState() => _WorkingButtonState();
}

class _WorkingButtonState extends State<WorkingButton> {
    bool _working = false;

    // doneWorking is passed to user handlers, so it must be a closure rather
    // than a plain method invocation.
    void doneWorking() => this.setState(() => _working = false);

    @override
    Widget build(BuildContext context) {
        bool effectivelyDisabled = this.widget.disabled || (this._working && this.widget.disableWhileWorking);
        String effectiveCaption = (this._working ? this.widget.workingCaption : null) ?? this.widget.caption;
        String? effectiveHint;
        if (effectivelyDisabled && this.widget.disabledHint != null) {
            effectiveHint = this.widget.disabledHint;
        } else if (this._working) {
            effectiveHint = this.widget.workingHint;
        } else {
            effectiveHint = this.widget.hint;
        }

        Widget result = ElevatedButton(
            onPressed: effectivelyDisabled
                ? null
                : () {
                    this.setState(() => this._working = true);
                    this.widget.onPress(doneWorking);
                },
            onLongPress: effectivelyDisabled || this.widget.onLongPress == null
                ? null
                : () => this.widget.onLongPress!(doneWorking),
            clipBehavior: Clip.none,
            style: this.widget.buttonStyle,
            child: Text(effectiveCaption, style: this.widget.textStyle),
        );

        if (effectiveHint != null) {
            result = Tooltip(message: effectiveHint, child: result);
        }

        return result;
    }
}
