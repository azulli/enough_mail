import 'dart:io';
import 'dart:typed_data';

import 'package:enough_mail/src/util/uint8_list_reader.dart';

import 'imap_response.dart';
import 'imap_response_line.dart';

class ImapResponseReader {
  final Uint8ListReader _rawReader = Uint8ListReader();
  ImapResponse _currentResponse;
  ImapResponseLine _currentLine;
  final Function(ImapResponse) _onImapResponse;

  ImapResponseReader([this._onImapResponse]);

  void onData(Uint8List data) {
    //print('---- ONDATA BEGIN ${data?.length ?? 0}');
    _rawReader.add(data);
    // var text = String.fromCharCodes(data).replaceAll('\r\n', '<CRLF>\n');
    // print('onData: $text');
    //  print("onData: hasLineBreak=${_rawReader.hasLineBreak()} currentResponse != null: ${(_currentResponse != null)}");
    if (_currentResponse != null) {
      //print('---- ONDATA RESPONSE CONTINUE');
      _checkResponse(_currentResponse, _currentLine);
    }
    if (_currentResponse == null) {
      //print('---- ONDATA RESPONSE NEW');
      // there is currently no response awaiting its finalization
      var text = _rawReader.readLine();
      while (text != null) {
        //print('---- ONDATA TIMING START');
        var response = ImapResponse();
        var line = ImapResponseLine(text);
        response.add(line);
        if (line.isWithLiteral) {
          _currentLine = line;
          _currentResponse = response;
          _checkResponse(response, line);
        } else {
          // this is a simple response:
          _onImapResponse(response);
        }
        if (_currentLine != null && _currentLine.isWithLiteral) {
          break;
        }
        text = _rawReader.readLine();
        //print('---- LOOP READLINE');
      }
    }
    //print('---- ONDATA END');
  }

  /// If [true] signals the buffered reading mode for a tagged body
  bool _rawReading = false;
  //ImapResponseLine _rawReadLine;
  List<Uint8List> _rawParts = [];

  int _rawPartsLength() => _rawParts.fold(
      0, (previousValue, element) => previousValue + element.length);

  Uint8List _joinedRawParts() {
    var bb = BytesBuilder();
    _rawParts.forEach((element) => bb.add(element));
    return bb.toBytes();
  }

  void _checkResponse(ImapResponse response, ImapResponseLine line) {
    if (line.isWithLiteral) {
      var sizeToRead = line.literal -
          (_rawReading ? _rawPartsLength() /*_rawReadLine.rawData.length*/ : 0);
      //print('${sizeToRead} of ${line.literal} bytes left');
      if (_rawReader.isAvailable(sizeToRead /*line.literal*/)) {
        // Block reading switch
        //print('---- {LITERAL} READS AVAILABLE RAW ${sizeToRead}');
        if (_rawReading) {
          // Reads the last available bytes and terminates block reading
          //**_rawReadLine.appendRaw(_rawReader.readBytes(sizeToRead));
          _rawParts.add(_rawReader.readBytes(sizeToRead));
          //**_currentLine = _rawReadLine;
          _rawReading = false;
          //**_rawReadLine = null;
          var rawLine = ImapResponseLine.raw(_joinedRawParts());
          response.add(rawLine);
          _currentLine = rawLine;
          _checkResponse(response, rawLine);
        } else {
          // Direct read the required bytes
          var rawLine =
              ImapResponseLine.raw(_rawReader.readBytes(line.literal));
          response.add(rawLine);
          _currentLine = rawLine;
          _checkResponse(response, rawLine);
        }
      } else if (_rawReader.isBufferFull) {
        if (_rawReading) {
          //**_rawReadLine.appendRaw(_rawReader.readBufferedBytes());
          _rawParts.add(_rawReader.readBufferedBytes());
          _checkResponse(response, _currentLine); // Blocca al literal
        } else {
          // Starts block reading mode
          _rawReading = true;
          //**_rawReadLine = ImapResponseLine.raw(_rawReader.readBufferedBytes());
          //**response.add(_rawReadLine);
          _rawParts = [_rawReader.readBufferedBytes()];
          _checkResponse(response, _currentLine); // Blocca al literal
        }
      }
      // else print('---- {LITERAL} NO AVAILABLE FOR READING');
    } else {
      // print('---- READS TEXT');
      // current line has no literal
      var text = _rawReader.readLine();
      if (text != null) {
        var textLine = ImapResponseLine(text);
        // handle special case:
        // the remainder of this line may consists of only a literal,
        // in this case the information should be added on the previous line
        if (textLine.isWithLiteral && textLine.line.isEmpty) {
          line.literal = textLine.literal;
          //line.rawLine += text;
          line.append(text);
        } else {
          if (textLine.line.isNotEmpty) {
            response.add(textLine);
          }
          if (!textLine.isWithLiteral) {
            // this is the last line of this server response:
            //print('---- ONDATA IMAP RESPONSE COMPLETE');
            _onImapResponse(response);
            _currentResponse = null;
            _currentLine = null;
          } else {
            _currentLine = textLine;
            _checkResponse(response, textLine);
          }
        }
      }
    }
  }
}
