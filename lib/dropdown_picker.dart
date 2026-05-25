import 'package:flutter/material.dart';
import 'package:noclevercode_suite/common.dart';
import 'package:noclevercode_suite/strings.dart';

/// Single-value dropdown over [labels]. When [autoselectSole] is true and
/// the list contains exactly one entry, that entry is selected automatically
/// and reported via [onChange] on mount.
class DropdownPicker extends StatefulWidget {
    final Strings? labels;
    final OnStringChange onChange;
    final String? selected;
    final bool disabled;
    final BoxDecoration? boxDecoration;
    final TextStyle? textStyle;
    final bool autoselectSole;

    const DropdownPicker({
        super.key,
        required this.labels,
        required this.onChange,
        this.selected,
        this.disabled = false,
        this.boxDecoration,
        this.textStyle,
        this.autoselectSole = true,
    });

    @override
    State<StatefulWidget> createState() => _DropdownPickerState();
}

class _DropdownPickerState extends State<DropdownPicker> {
    String? _selected;
    bool _autoselectScheduled = false;

    @override
    void initState() {
        super.initState();
        _selected = this.widget.selected;
        _maybeAutoselect();
    }

    @override
    void didUpdateWidget(DropdownPicker oldWidget) {
        super.didUpdateWidget(oldWidget);
        if (this.widget.selected != oldWidget.selected) {
            _selected = this.widget.selected;
        }
        _maybeAutoselect();
    }

    void _maybeAutoselect() {
        Strings? labels = this.widget.labels;
        if (!this.widget.autoselectSole || labels == null || labels.length != 1) {
            return;
        }
        String sole = labels[0];
        if (_selected == sole || _autoselectScheduled) {
            return;
        }
        _selected = sole;
        _autoselectScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
            _autoselectScheduled = false;
            if (mounted) {
                this.widget.onChange(sole);
            }
        });
    }

    @override
    Widget build(BuildContext context) {
        Strings? labels = this.widget.labels;
        if (labels == null || labels.isEmpty) {
            return const Text('----');
        }

        List<DropdownMenuItem<String>> items = List<DropdownMenuItem<String>>.generate(labels.length, (index) {
            return DropdownMenuItem(
                value: labels[index],
                child: Text(labels[index]),
            );
        });
        String? validSelected = labels.contains(_selected) ? _selected : null;

        Widget result = DropdownButton<String>(
            style: this.widget.textStyle,
            focusColor: Colors.transparent,
            items: items,
            value: validSelected,
            onChanged: (this.widget.disabled || labels.length <= 1)
                ? null
                : (String? value) {
                    this.setState(() => _selected = value);
                    this.widget.onChange(value);
                },
        );

        if (this.widget.boxDecoration != null) {
            result = Container(decoration: this.widget.boxDecoration, child: result);
        }

        return result;
    }
}
