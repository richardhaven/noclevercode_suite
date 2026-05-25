import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:noclevercode_suite/common.dart';
import 'package:noclevercode_suite/strings.dart';

/// Multi-line text input that reports its value via [onChange] as a [Strings]
/// collection (one element per line). When [aggregateDelay] or
/// [maxAggregateDelay] are non-zero the callback is debounced.
class TextStrings extends StatefulWidget {
    final int? aggregateDelay;
    final int? maxAggregateDelay;
    final OnStringsChange onChange;
    final BoxDecoration? boxDecoration;
    final Strings? strings;
    final String caption;
    final CaptionLocation captionLocation;
    final int? lineCount;
    final bool disabled;
    final bool readOnly;
    final TextStyle? textStyle;
    final TextStyle? captionStyle;

    const TextStrings({
        super.key,
        required this.onChange,
        this.lineCount,
        this.aggregateDelay,
        this.maxAggregateDelay,
        this.caption = '',
        this.captionLocation = CaptionLocation.above,
        this.boxDecoration,
        this.strings,
        this.disabled = false,
        this.readOnly = false,
        this.textStyle,
        this.captionStyle,
    });

    @override
    State<StatefulWidget> createState() => _TextStringsState();
}

class _TextStringsState extends State<TextStrings> {
    RestartableTimer? _onChangeTimer;
    RestartableTimer? _maximumOnChangeTimer;
    Strings? _currentStrings;
    late TextEditingController _textEditingController;

    @override
    void initState() {
        super.initState();
        this._currentStrings = this.widget.strings;
        this._textEditingController = TextEditingController(text: this._currentStrings?.text);
    }

    @override
    void dispose() {
        this._textEditingController.dispose();
        super.dispose();
    }

    RestartableTimer _createTimer(int period) {
        return RestartableTimer(Duration(milliseconds: period), _onTimerDone);
    }

    @override
    Widget build(BuildContext context) {
        Widget textWidget = TextField(
            style: this.widget.textStyle,
            controller: this._textEditingController,
            maxLines: (this.widget.lineCount != null && this.widget.lineCount != 0)
                ? this.widget.lineCount
                : (this._currentStrings == null)
                    ? 1
                    : calculateLineCount(this._currentStrings!.text),
            enabled: !this.widget.disabled,
            readOnly: this.widget.readOnly,
            selectionControls: DesktopTextSelectionControls(),
            enableInteractiveSelection: !this.widget.disabled,
            onChanged: this.widget.disabled ? null : _onAggregatedChange, // don't set to null if widget.readOnly or it will disable
        );

        Widget containedChild;
        if (!nullOrBlank(this.widget.caption)) {
            Widget captionWidget = Text(style: this.widget.captionStyle, this.widget.caption);

            switch (this.widget.captionLocation) {
                case CaptionLocation.above:
                    containedChild = Column(crossAxisAlignment: CrossAxisAlignment.center, children: [captionWidget, textWidget]);
                case CaptionLocation.below:
                    containedChild = Column(crossAxisAlignment: CrossAxisAlignment.center, children: [textWidget, captionWidget]);
                case CaptionLocation.leading:
                    // TextField has no intrinsic width; wrap in Expanded so the Row can size it.
                    containedChild = Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [captionWidget, Expanded(child: textWidget)],
                    );
                case CaptionLocation.following:
                    containedChild = Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [Expanded(child: textWidget), captionWidget],
                    );
            }
        } else {
            containedChild = textWidget;
        }

        if (this.widget.boxDecoration != null) {
            return Container(
                alignment: Alignment.topCenter,
                decoration: this.widget.boxDecoration,
                padding: const EdgeInsets.all(10),
                child: containedChild,
            );
        } else {
            return containedChild;
        }
    }

    void _onAggregatedChange(String value) {
        this._currentStrings = Strings.from(value.split('\n'));

        bool hasDebounce = !nullOrZero(this.widget.aggregateDelay);
        bool hasMaxDebounce = !nullOrZero(this.widget.maxAggregateDelay);

        if (!hasDebounce && !hasMaxDebounce) {
            this._onTimerDone();
            return;
        }

        if (hasDebounce) {
            this._restartDebounce();
        }
        if (hasMaxDebounce) {
            this._ensureMaxDebounce();
        }
    }

    /// Kicks the per-keystroke debounce timer forward to `aggregateDelay`
    /// from now, restarting it on each call.
    void _restartDebounce() {
        if (this._onChangeTimer != null) {
            this._onChangeTimer!.reset();
        } else {
            this._onChangeTimer = this._createTimer(this.widget.aggregateDelay!);
        }
    }

    /// Starts the ceiling timer on first input and lets it run to completion;
    /// subsequent keystrokes do not extend it.
    void _ensureMaxDebounce() {
        if (this._maximumOnChangeTimer == null) {
            this._maximumOnChangeTimer = this._createTimer(this.widget.maxAggregateDelay!);
        } else if (!this._maximumOnChangeTimer!.isActive) {
            this._maximumOnChangeTimer!.reset();
        }
    }

    void _onTimerDone() {
        // _currentStrings is populated by _onAggregatedChange before either
        // timer is scheduled, so it is always non-null here. Guard anyway
        // to document the invariant and survive any future restructuring.
        if (this._currentStrings == null) {
            return;
        }
        this.widget.onChange(this._currentStrings!);

        this._onChangeTimer?.cancel();
        this._maximumOnChangeTimer?.cancel();
    }
}

/// Heuristic for `maxLines` when no explicit lineCount is provided: counts
/// embedded newlines, and falls back to estimating wraps at 50-character
/// width for single-line strings.
int calculateLineCount(String text) {
    int result = text.countOfCharacter('\n');

    if (result == 0) {
        List<String> lines = text.split('\n');
        for (int index = lines.length - 1; index >= 0; index--) {
            if (lines[index].length > 50) {
                result++;
            }
        }
        result++;
    }
    return result;
}
