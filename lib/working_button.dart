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

    bool get working => _working;

    // cannot use a real mutator as we have to pass it around
    void setWorking(bool value) => this.setState(() => _working = value);

    void doneWorking() => this.setWorking(false);

    @override
    Widget build(BuildContext context) {
        bool effectivelyDisabled = false;
        if (this.widget.disabled) {
            effectivelyDisabled = true;
        } else if (this.working && this.widget.disableWhileWorking) {
            effectivelyDisabled = true;
        }

        String effectiveCaption;
        if (this.working && this.widget.workingCaption != null) {
            effectiveCaption = this.widget.workingCaption!;
        } else {
            effectiveCaption = this.widget.caption;
        }

        Widget textChild = Text(effectiveCaption, style: this.widget.textStyle);

        Widget result = ElevatedButton(
            onPressed: effectivelyDisabled
                ? null
                : () {
                    setWorking(true);
                    this.widget.onPress(doneWorking);
                },
            onLongPress: effectivelyDisabled || this.widget.onLongPress == null
                ? null
                : () {
                    this.widget.onLongPress!(doneWorking);
                },
            clipBehavior: Clip.none,
            style: this.widget.buttonStyle,
            child: textChild,
        );

        String? effectiveHint;
        if (effectivelyDisabled && this.widget.disabledHint != null) {
            effectiveHint = this.widget.disabledHint;
        } else if (this.working) {
            effectiveHint = this.widget.workingHint;
        } else {
            effectiveHint = this.widget.hint;
        }

        if (effectiveHint != null) {
            result = Tooltip(
                message: effectiveHint,
                child: result,
            );
        }

        return result;
    }
}
