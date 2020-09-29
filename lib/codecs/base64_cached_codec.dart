import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:enough_mail/mail_conventions.dart';
import 'package:enough_mail/src/util/ascii_runes.dart';

import 'mail_codec.dart';

mixin Base64CachedCodec on MailCodec {
  Future<void> cachedEncodeFile(File sourceFile, File destFile) async {
    var cacheSink = destFile.openWrite();
    final chunkLength = MailConventions.textLineMaxLength;
    var remainder = 0;
    var subscription = sourceFile.openRead().transform(Base64Encoder()).listen(
      (event) {
        var length = event.length;
        var chunkIndex = 0;
        // Adds the line terminaor for a previous full line
        if (remainder < 0) {
          cacheSink.write('\r\n');
          remainder = 0;
        }
        // Writes the remaining characters for a complete line
        if (remainder > 0) {
          if (length >= remainder) {
            cacheSink.write(event.substring(0, remainder));
            length -= remainder;
          } else {
            cacheSink.write(event.substring(0, length));
            remainder = chunkLength - length;
            length -= length;
          }
          if (length > 0) {
            cacheSink.write('\r\n');
          }
        }
        // Chunked writing
        while (length > chunkLength) {
          var startPos = (chunkIndex * chunkLength) + remainder;
          var endPos = startPos + chunkLength;
          // print('Write chunk $chunkIndex from $startPos to $endPos');
          cacheSink.write(event.substring(startPos, endPos));
          cacheSink.write('\r\n');
          chunkIndex++;
          length -= chunkLength;
        }
        if (length > 0) {
          var startPos = (chunkIndex * chunkLength) + remainder;
          // print('Write remaining bytes from $startPos');
          cacheSink.write(event.substring(startPos));
          remainder = chunkLength - length;
        } else if (remainder == 0) {
          remainder = -1;
        }
      },
    );
    await subscription
        .asFuture()
        .catchError((err) => throw err)
        .whenComplete(() async => await cacheSink.close());
  }

  Future<void> cachedDecodeFile(File sourceFile, File destFile) async {
    var cacheSink = destFile.openWrite();
    var subscription = sourceFile
        .openRead()
        .transform(StreamTransformer<List<int>, String>.fromHandlers(
          handleData: (data, sink) {
            var pos = 0;
            var index = data.indexOf(AsciiRunes.runeCarriageReturn, pos);
            while (index > -1 && index < data.length) {
              sink.add(String.fromCharCodes(data.sublist(pos, index)));
              pos = index + 2;
              index = data.indexOf(AsciiRunes.runeCarriageReturn, pos);
            }
            if (index == -1 && pos < data.length) {
              sink.add(String.fromCharCodes(data.sublist(pos)));
            }
          },
        ))
        .transform(Base64Decoder())
        .listen(
          (event) {
            cacheSink.add(event);
          },
        );
    print('cachedDecodeData → attesa del completamento');
    await subscription
        .asFuture()
        .catchError((err) => throw err)
        .whenComplete(() async => await cacheSink.close());
  }
}
