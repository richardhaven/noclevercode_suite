import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noclevercode_suite/common.dart';
import 'package:noclevercode_suite/strings.dart';

/// Keyboard-search behavior for [DropdownPicker] when the dropdown has focus
/// (e.g. after tab-navigation) and the menu is closed.
///
/// - [disabled]: keystrokes are ignored.
/// - [firstLetter]: pressing a letter jumps to the next item starting with
///   that letter (cycles).
/// - [incremental]: keystrokes accumulate into a buffer (case-insensitive)
///   and the first item whose label starts with the buffer is selected. The
///   buffer resets after a short idle.
enum DropdownPickerKeySearch { disabled, firstLetter, incremental }

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
    final DropdownPickerKeySearch keySearch;

    const DropdownPicker({
        super.key,
        required this.labels,
        required this.onChange,
        this.selected,
        this.disabled = false,
        this.boxDecoration,
        this.textStyle,
        this.autoselectSole = true,
        this.keySearch = DropdownPickerKeySearch.disabled,
    });

    @override
    State<StatefulWidget> createState() => _DropdownPickerState();
}

class _DropdownPickerState extends State<DropdownPicker> {
    static const Duration _incrementalResetDelay = Duration(milliseconds: 800);

    String? _selected;
    bool _autoselectScheduled = false;

    final FocusNode _searchFocusNode = FocusNode(debugLabel: 'DropdownPickerSearch');
    String _searchBuffer = '';
    Timer? _searchResetTimer;

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

    @override
    void dispose() {
        _searchResetTimer?.cancel();
        _searchFocusNode.dispose();
        super.dispose();
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

    void _commitSelection(String value) {
        this.setState(() => _selected = value);
        this.widget.onChange(value);
    }

    void _resetSearchBufferSoon() {
        _searchResetTimer?.cancel();
        _searchResetTimer = Timer(_incrementalResetDelay, () {
            _searchBuffer = '';
        });
    }

    KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
        if (this.widget.disabled) return KeyEventResult.ignored;
        if (this.widget.keySearch == DropdownPickerKeySearch.disabled) {
            return KeyEventResult.ignored;
        }
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
            return KeyEventResult.ignored;
        }

        Strings? labels = this.widget.labels;
        if (labels == null || labels.isEmpty) return KeyEventResult.ignored;

        String character = event.character ?? '';
        if (character.isEmpty) return KeyEventResult.ignored;
        // Only accept printable single characters; ignore control keys.
        int codeUnit = character.codeUnitAt(0);
        if (codeUnit < 0x20 || codeUnit == 0x7f) return KeyEventResult.ignored;

        String? match;
        if (this.widget.keySearch == DropdownPickerKeySearch.firstLetter) {
            match = _findFirstLetterMatch(labels, character);
        } else {
            _searchBuffer += character;
            match = _findIncrementalMatch(labels, _searchBuffer);
            if (match == null) {
                // Reset to just this key so the user can recover from a typo.
                _searchBuffer = character;
                match = _findIncrementalMatch(labels, _searchBuffer);
            }
            _resetSearchBufferSoon();
        }

        if (match != null && match != _selected) {
            _commitSelection(match);
        }
        return KeyEventResult.handled;
    }

    String? _findFirstLetterMatch(Strings labels, String letter) {
        String target = letter.toLowerCase();
        List<String> matches = <String>[];
        for (int index = 0; index < labels.length; index++) {
            String label = labels[index];
            if (label.isNotEmpty && label[0].toLowerCase() == target) {
                matches.add(label);
            }
        }
        if (matches.isEmpty) return null;
        int currentIndex = _selected == null ? -1 : matches.indexOf(_selected!);
        int nextIndex = currentIndex < 0 ? 0 : (currentIndex + 1) % matches.length;
        return matches[nextIndex];
    }

    String? _findIncrementalMatch(Strings labels, String buffer) {
        String target = buffer.toLowerCase();
        for (int index = 0; index < labels.length; index++) {
            String label = labels[index];
            if (label.toLowerCase().startsWith(target)) {
                return label;
            }
        }
        return null;
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
            onChanged: this.widget.disabled
                ? null
                : (String? value) {
                    if (value != null) {
                        _commitSelection(value);
                    } else {
                        this.setState(() => _selected = value);
                        this.widget.onChange(value);
                    }
                },
        );

        if (this.widget.keySearch != DropdownPickerKeySearch.disabled) {
            result = Focus(
                focusNode: _searchFocusNode,
                onKeyEvent: _handleKey,
                child: result,
            );
        }

        if (this.widget.boxDecoration != null) {
            result = Container(decoration: this.widget.boxDecoration, child: result);
        }

        return result;
    }
}
