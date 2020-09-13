import 'dart:io';
import 'dart:typed_data';

import 'parser_helper.dart';

class ImapResponseLine {
  // String rawLine;
  String line;
  int literal;
  // Should consider empty bodies with literal value 0
  bool get isWithLiteral => (literal != null && literal >= 0);
  Uint8List rawData;

  String get rawLine => rawData != null ? String.fromCharCodes(rawData) : '';

  ImapResponseLine.raw(this.rawData) {
    rawData ??= Uint8List(0);
    line = String.fromCharCodes(rawData);
    // rawLine = line;
  }

  ImapResponseLine(String /*this.*/ rawLine) {
    // Example for lines using the literal extension / rfc7888:
    //  C: A001 LOGIN {11+}
    //  C: FRED FOOBAR {7+}
    //  C: fat man
    //  S: A001 OK LOGIN completed
    //var tama = DateTime.now();
    rawData = Uint8List.fromList(rawLine.codeUnits);
    if (rawLine.length > 3 && rawLine[rawLine.length - 1] == '}') {
      var openIndex = rawLine.lastIndexOf('{', rawLine.length - 2);
      var endIndex = rawLine.length - 1;
      if (rawLine[endIndex - 1] == '+') {
        endIndex--;
      }
      literal = ParserHelper.parseIntByIndex(rawLine, openIndex + 1, endIndex);
      if (literal != null) {
        if (openIndex > 0 && rawLine[openIndex - 1] == ' ') {
          openIndex--;
        }
        line = rawLine.substring(0, openIndex);
      }
    } else {
      line = rawLine;
    }
    /*print('ImapResponseLine() Elapsed ' +
        DateTime.now().difference(tama).inMilliseconds.toString() +
        'ms');*/
  }

  void append(String text) {
    //rawData += Uint8List.fromList(text.codeUnits);
    rawData = (BytesBuilder(copy: false)..add(rawData)..add(text.codeUnits))
        .takeBytes();
  }

  /*void appendRaw(Uint8List data) {
    // Invece di fare le copie qui, creare una lista di Uint8List che poi viene assemblata in finalizzazione
    _bb.add(rawData);
    _bb.add(data);
    rawData = _bb.takeBytes();
  }*/

  @override
  String toString() {
    return String.fromCharCodes(rawData); //rawLine;
  }
}
