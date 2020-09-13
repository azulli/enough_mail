import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:enough_mail/src/util/ascii_runes.dart';

/// Combines several Uin8Lists to read from them sequentially
class Uint8ListReader {
  Uint8List _data = Uint8List(0);
  final BytesBuilder _bb = BytesBuilder();

  final _bufferSize = 1024 * 64; // 64K buffer

  /// true se sono presenti più dati della "capienza" del buffer
  bool get isBufferFull => _data.length >= _bufferSize;
  int get size => _data.length;

  void add(Uint8List list) {
    //idea: consider BytesBuilder
    if (_data.isEmpty) {
      _data = list;
    } else {
      // _data = Uint8List.fromList(_data + list);
      _bb.add(_data);
      _bb.add(list);
      _data = _bb.takeBytes();
    }
  }

  void addText(String text) {
    add(Uint8List.fromList(text.codeUnits));
  }

  int findLineBreak() {
    var charIndex = _data.indexOf(13);
    if (charIndex < _data.length - 1 && _data[charIndex + 1] == 10) {
      return charIndex + 1;
    }
    return null;
  }

  int findLastLineBreak() {
    var charIndex = _data.lastIndexOf(10);
    if (_data[charIndex - 1] == 13) {
      return charIndex;
    }
    return null;
  }

  bool hasLineBreak() {
    return (findLineBreak() != null);
  }

  String readLine() {
    var pos = findLineBreak();
    if (pos == null) {
      return null;
    }
    var line = String.fromCharCodes(_data, 0, pos - 1);
    _data = _data.sublist(pos + 1);
    return line;
  }

  List<String> readLines() {
    var pos = findLastLineBreak();
    if (pos == null) {
      return null;
    }
    String text;
    if (pos == _data.length - 1) {
      text = String.fromCharCodes(_data);
      _data = Uint8List(0);
    } else {
      text = String.fromCharCodes(_data, 0, pos);
      _data = _data.sublist(pos + 1);
    }
    return text.split('\r\n');
  }

  int findLastCrLfDotCrLfSequence() {
    var start = _data.length;
    while (start > 4) {
      var charIndex = _data.lastIndexOf(10, start);
      if (_data[charIndex] == 10 &&
          _data[charIndex - 1] == 13 &&
          _data[charIndex - 2] == AsciiRunes.runeDot &&
          _data[charIndex - 3] == 10 &&
          _data[charIndex - 4] == 13) {
        // ok found CRLF.CRLF sequence:
        return charIndex;
      }
    }
    return null;
  }

  List<String> readLinesToCrLfDotCrLfSequence() {
    var pos = findLastCrLfDotCrLfSequence();
    if (pos == null) {
      return null;
    }
    String text;
    text = String.fromCharCodes(_data, 0, pos - 4);
    if (pos == _data.length - 1) {
      _data = Uint8List(0);
    } else {
      _data = _data.sublist(pos + 1);
    }
    return text.split('\r\n');
  }

  Uint8List readBytes(int length) {
    if (!isAvailable(length)) {
      return null;
    }
    var result = _data.sublist(0, length);
    _data = _data.sublist(length);
    return result;
  }

  /// Legge tutto il buffer fino ad un massimo di [_bufferSize] elementi
  Uint8List readBufferedBytes() {
    var result = _data.sublist(0, min(_bufferSize, _data.length));
    _data = _data.sublist(_bufferSize);
    return result;
  }

  bool isAvailable(int length) {
    return (length <= _data.length);
  }
}
