import 'dart:collection';
import 'dart:math';

/// Function that produces a [String] given an index.
typedef StringGenerator = String Function(int);

/// A small wrapper over `List<String>` exposing the [ListBase] API plus a
/// few set-like and ordering operations used across the suite. The backing
/// list is fixed-length unless [growable] is true.
///
/// Constructor [growable] defaults are intentionally inconsistent:
/// [Strings.empty] defaults to `growable: true` because an empty list is
/// almost always built up; every other constructor defaults to `false`
/// because the caller is supplying their final content up front.
class Strings extends ListBase<String> {
    late List<String> data;
    late bool growable;

    /// Wraps the given [values] (or builds an empty list when null).
    Strings(List<String>? values, {this.growable = false}) {
        if (values == null) {
            this.data = List<String>.empty(growable: false);
        } else {
            this.data = List<String>.from(values, growable: false);
        }
    }

    /// Fixed-size list filled with empty strings.
    Strings.fixed(int size, {this.growable = false}) {
        this.data = List<String>.filled(size, '', growable: false);
    }

    /// Empty list. The [growable] flag controls whether [length] can be
    /// changed later; the backing store is always rebuilt via the [length]
    /// setter when it grows.
    Strings.empty({this.growable = true}) {
        this.data = List<String>.empty(growable: false);
    }

    /// Builds a list of [size] strings via [generator].
    Strings.generate(int size, String Function(int) generator, {this.growable = false}) {
        this.data = List<String>.generate(size, generator, growable: false);
    }

    /// Copies the strings from [source].
    Strings.from(Iterable<String> source, {this.growable = false}) {
        this.data = List<String>.from(source, growable: false);
    }

    /// Joins all elements with '\n'.
    String get text => this.data.join('\n');

    @override
    int get length => this.data.length;

    @override
    set length(int newLength) {
        if (newLength == this.data.length) {
            return;
        } else if (!this.growable) {
            throw UnsupportedError('Cannot change the length of a fixed-length list');
        } else {
            // String elements cannot be null, so a plain length change would leave gaps.
            List<String> previous = this.data;
            this.data = List<String>.generate(newLength, (int index) {
                if (index < previous.length) {
                    return previous[index];
                } else {
                    return '';
                }
            });
        }
    }

    /// Sorts this list by the position of each element in [sortingStrings];
    /// elements not present in [sortingStrings] sort after, in lexical order.
    /// Returns this for chaining.
    Strings sortByStrings(Strings sortingStrings) {
        this.data.sort((String string1, String string2) {
            int index1 = sortingStrings.indexOf(string1);
            int index2 = sortingStrings.indexOf(string2);
            if (index1 == -1) {
                if (index2 == -1) {
                    return string1.compareTo(string2);
                } else {
                    return 1;
                }
            } else if (index2 == -1) {
                return -1;
            } else if (index1 == index2) {
                return 0;
            } else {
                return index1.compareTo(index2);
            }
        });
        return this;
    }

    /// Returns the index of the first element that starts with [leadingText],
    /// or -1 if none does. An empty [leadingText] matches the first element.
    int indexOfLeadingText(String leadingText) {
        for (int index = 0; index < this.length; index++) {
            if (this.data[index].startsWith(leadingText)) {
                return index;
            }
        }
        return -1;
    }

    @override
    String operator [](int index) => this.data[index];

    @override
    void operator []=(int index, String value) {
        this.data[index] = value;
    }

    /// Returns a shallow copy.
    Strings copy() => Strings.from(this);
}

/// Counts occurrences of a single-character string.
extension CountOfCharacter on String {
    int countOfCharacter(String character) {
        int result = 0;
        for (int index = this.length - 1; index >= 0; index--) {
            if (this[index] == character) {
                result++;
            }
        }
        return result;
    }
}

/// Case-insensitive equality.
extension StringIgnoreCase on String {
    bool equalsIgnoreCase(String other) {
        return this.toLowerCase() == other.toLowerCase();
    }
}

/// Case-insensitive equality over the shared leading characters of both
/// strings (the comparison length is `min(this.length, other.length)`).
extension StringIgnoreCaseLeading on String {
    bool equalsLeadingIgnoreCase(String other) {
        int minimumLength = min(this.length, other.length);

        String substr = this.substring(0, minimumLength);
        other = other.substring(0, minimumLength);

        return substr.equalsIgnoreCase(other);
    }
}

/// `substring` that accepts negative offsets (counted from end).
extension Substring on String {
    String substr(int start, [int? end]) {
        if (start < 0) {
            start += this.length;
        }
        int realEnd = end ?? this.length;
        if (realEnd < 0) {
            realEnd += this.length;
        }
        return this.substring(start, realEnd);
    }
}
