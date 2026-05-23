# noclevercode_suite

A small grab-bag of Flutter widgets and Dart utilities used across the
No Clever Code projects. Nothing fancy — just the helpers that kept getting
copy-pasted between apps, pulled into one place.

## What's in here

### Widgets

| File | What it provides |
| --- | --- |
| `checkboxes.dart` | `CheckBoxes` — multi-select checkbox group with horizontal or vertical layout |
| `dropdown_picker.dart` | `DropdownPicker` — single-value dropdown, optionally auto-selecting a sole entry |
| `radio_buttons.dart` | `RadioButtons` — single-select radio group |
| `simple_check.dart` | `SimpleCheck` — single labeled checkbox |
| `working_button.dart` | `WorkingButton` — button that shows a working caption / disables while an async `onPress` runs |
| `widget_utilities.dart` | Small layout / sizing helpers |

### Dart helpers

| File | What it provides |
| --- | --- |
| `common.dart` | Shared typedefs (`OnEvent`, `OnIntChange`, `OnBoolChange`, `OnStringChange`, `OnStringsChange`, `OnStringTranslateCheck`), `CaptionLocation` and `TextAlign` enums, `nullOrBlank` / `nullOrZero` / `boolishToString` helpers |
| `strings.dart` | `Strings` — a small wrapper over `List<String>` with set-like operations |
| `text_strings.dart` | i18n-friendly text constants and lookup utilities |
| `csv_file_io.dart` | Read / write CSV files via `path_provider` |
| `usa_date_formatter.dart` | US-locale date / time formatting helpers |

A barrel file is provided so consumers can just:

```dart
import 'package:noclevercode_suite/noclevercode_suite.dart';
```

…or import individual files for finer control.

## Naming caveat — `TextAlign`

`common.dart` defines its own `TextAlign { start, end, center }` enum, which
collides with Flutter's `TextAlign` from `dart:ui`. If you import both this
package and `package:flutter/material.dart` into the same file and need
Flutter's version, hide ours:

```dart
import 'package:noclevercode_suite/common.dart' hide TextAlign;
```

The package's `TextAlign` is "more inclusive than left/right" (its words),
intended for non-LTR-only layouts; Flutter's covers the start/end set too,
so for most Material-stack consumers the `hide TextAlign` route is right.

## Getting started

Add a `path:` dependency in your app's `pubspec.yaml` (this package is not
published to pub.dev):

```yaml
dependencies:
  noclevercode_suite:
    path: ../noclevercode_suite
```

…then `flutter pub get`. There is no initialization step — import what you
need and use it.

## Status

Internal-use package. Breaking changes happen without a deprecation cycle;
pin to a specific commit if you depend on stability.

## Contributing

Issues and PRs welcome but expect slow turnaround — this is a side-project
helper library, not a maintained product.
