import 'package:noclevercode_suite/strings.dart';

/// A handler that takes no arguments. Equivalent to `VoidCallback`.
typedef OnEvent = void Function();

/// A handler that receives a nullable int (e.g. parsed numeric input).
typedef OnIntChange = void Function(int? value);

/// A handler that receives a boolean (e.g. checkbox toggled).
typedef OnBoolChange = void Function(bool value);

/// A handler that receives a nullable string (e.g. dropdown selection).
typedef OnStringChange = void Function(String? value);

/// A handler that receives a [Strings] collection (e.g. multi-line text).
typedef OnStringsChange = void Function(Strings value);

/// A validator/translator that may transform or reject an input string.
/// Returning null typically signals "no change" or "valid".
typedef OnStringTranslateCheck = String? Function(String? value);

/// Where a caption should sit relative to its associated widget.
enum CaptionLocation { above, below, leading, following }

/// Direction-agnostic text alignment, "more inclusive than left/right".
/// Named to avoid colliding with Flutter's `TextAlign`.
enum NccTextAlign { start, end, center }

/// True when [string] is null or empty.
bool nullOrBlank(String? string) {
    return string == null || string.isEmpty;
}

/// True when [anInt] is null or equal to zero.
bool nullOrZero(int? anInt) {
    return anInt == null || anInt == 0;
}
