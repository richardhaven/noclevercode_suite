# Changelog

All notable changes to this package. This project does not yet follow
semver — pin to a specific commit if you need stability.

## Unreleased

### Added
- `OnStringTranslateCheck` typedef in `common.dart` — `String? Function(String? value)` for input-field validator/translator callbacks. (Restores a typedef that was previously dropped; `save_our_places/lib/widgets/input_field.dart` depends on it.)
- Doc comments (`///`) on all public classes, typedefs, helpers, and extensions.
- `localFileAppend` in `csv_file_io.dart` — separated from `localFileWrite`, which now overwrites instead of appending.

### Fixed
- `common.dart`: `nullOrZero(int?)` now correctly returns true when the value is null or **zero**; previously it returned true when the value was non-zero, which silently flipped every caller's intent (notably the debounce-timer logic in `TextStrings`).
- `dropdown_picker.dart`: `autoselectSole` no longer dead. The `initState` override was on the wrong class (`StatefulWidget` instead of `State`), so the auto-select code never ran. Moved into `_DropdownPickerState` and added `didUpdateWidget` so parent updates to `selected` propagate.
- `radio_buttons.dart`: the `selected` constructor argument now actually initializes the selection (was previously declared but never read), and parent updates propagate via `didUpdateWidget`.
- `text_strings.dart`: dropped the unconditional `Expanded` wrap that crashed `TextStrings` when placed inside non-flex parents (e.g. `Table` cells, raw `Container`s). Callers needing flex sizing should wrap the widget themselves.
- `text_strings.dart`: fixed typo in the `maxAggregateDelay` branch that called `reset()` on `_onChangeTimer` instead of `_maximumOnChangeTimer`.
- `text_strings.dart`: removed initialization logic from `createState` (anti-pattern); now reads `widget.strings` in `initState`.
- `csv_file_io.dart`: switched from Android-only `getExternalStorageDirectory()` to cross-platform `getApplicationDocumentsDirectory()`; `localFileRead` is now fully async; dropped the `permission_handler` dependency (app-private documents directory needs no runtime permission).

### Changed
- `dropdown_picker.dart`: `DropdownPicker.selected` and `DropdownPicker.unselectedCaption` (now removed) were promoted to `final`, and the constructor is now `const`.
- `dropdown_picker.dart`: removed `unselectedCaption` parameter — its overlay behavior was a never-implemented TODO. Drop the named argument from call sites.
- `simple_check.dart`: `SimpleCheck` now actually renders its `label` (the rendering was previously commented out, leaving the `required label` parameter dead).
- `text_strings.dart`: `captionLocation`, `disabled`, `readOnly` are now `final`; constructor is `const`. Required for Flutter's `@immutable` widget contract.
- `radio_buttons.dart`: removed the unused `decoration: InputDecoration?` parameter.

## 0.0.1

Initial extraction of widgets and helpers from the consumer apps.

### Widgets
- `CheckBoxes` — multi-select checkbox group (`checkboxes.dart`)
- `DropdownPicker` — single-value dropdown (`dropdown_picker.dart`)
- `RadioButtons` — single-select radio group (`radio_buttons.dart`)
- `SimpleCheck` — labeled single checkbox (`simple_check.dart`)
- `WorkingButton` — async-aware button with working caption (`working_button.dart`)
- Widget layout helpers (`widget_utilities.dart`)

### Dart helpers
- Shared typedefs and enums (`common.dart`)
- `Strings` collection wrapper (`strings.dart`)
- i18n text utilities (`text_strings.dart`)
- CSV file I/O (`csv_file_io.dart`)
- US date formatting (`usa_date_formatter.dart`)
