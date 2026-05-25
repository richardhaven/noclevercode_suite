import 'dart:io';

import 'package:noclevercode_suite/strings.dart';
import 'package:path_provider/path_provider.dart';

/// A list of rows, where each row is a [Strings] of column values.
typedef DelimitedStrings = List<Strings>;

Future<File> _documentsFile(String fileName) async {
    Directory documents = await getApplicationDocumentsDirectory();
    return File('${documents.path}/$fileName');
}

/// Writes [data] to a file inside the app's documents directory.
/// Overwrites any existing file at the same path. Returns true on success.
Future<bool> localFileWrite(String fileName, String data) async {
    try {
        File target = await _documentsFile(fileName);
        await target.writeAsString(data);
        return true;
    } catch (_) {
        return false;
    }
}

/// Appends [data] to a file inside the app's documents directory, creating
/// it if needed. Returns true on success.
Future<bool> localFileAppend(String fileName, String data) async {
    try {
        File target = await _documentsFile(fileName);
        await target.writeAsString(data, mode: FileMode.append);
        return true;
    } catch (_) {
        return false;
    }
}

/// Reads a file from the app's documents directory and returns its lines
/// (split on '\n'). Returns null if the file does not exist or cannot be read.
Future<Strings?> localFileRead(String fileName) async {
    try {
        File source = await _documentsFile(fileName);
        if (!await source.exists()) {
            return null;
        }
        String fileContent = await source.readAsString();
        return Strings.from(fileContent.split('\n'));
    } catch (_) {
        return null;
    }
}

/// Splits each row of [input] on commas. Does not strip enclosing quotes
/// or handle embedded commas; pull in `package:csv` for that.
DelimitedStrings undelimitStrings(Strings input) {
    DelimitedStrings result = DelimitedStrings.generate(input.length, (index) {
        Strings columns = Strings.from(input[index].split(','));
        return columns;
    });
    return result;
}
