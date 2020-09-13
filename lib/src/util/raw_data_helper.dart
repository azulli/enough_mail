import 'dart:typed_data';

import 'ascii_runes.dart';

class RawDataHelper {
  static int findSequence(final Uint8List haystack, final Uint8List needle,
      [int start = 0]) {
    var isComplete = false;
    var result = -1;
    //print('haystack length ${haystack.length}, needle length ${needle.length}');
    for (var p = start, m = haystack.length;
        p + needle.length < m && !isComplete;) {
      var needleFound = true;
      var d = 0;

      p = haystack.indexOf(needle[0], p);
      //print('first position of ${needle[0]} at $p');
      if (p == -1 || p + needle.length > m) {
        break;
      }
      for (; d < needle.length && needleFound; d++) {
        //print('trying ${haystack[p + d]} = ${needle[d]}');
        needleFound = haystack[p + d] == needle[d];
      }
      if (needleFound) {
        //print('found needle!');
        result = p + needle.length;
        isComplete = true;
      }
      /* else {
        print('needle missed after $d chars');
      } */
      p += d;
      //print('continue from $p');
    }
    return result;
  }

  static List<int> findBoundaries(
      final Uint8List haystack, final Uint8List needle,
      [int start = 0]) {
    // TODO: Call findSequence for detection
    /*print('Searching boundary "' +
        String.fromCharCodes(needle).trimRight() +
        '" locations');*/
    var ps = <int>[];
    var isComplete = false;
    for (var p = start, m = haystack.length;
        p + needle.length < m && !isComplete;) {
      var boundaryFound = true;
      var x = 0;
      p = haystack.indexOf(needle[0], p);
      if (p == -1 || (p + needle.length) > m) {
        break;
      }
      for (; x < needle.length && boundaryFound; x++) {
        boundaryFound = haystack[p + x] == needle[x];
      }
      if (boundaryFound) {
        //print('boundary at $p');
        ps.add(p);
      } else if (x == needle.length - 1) {
        // Check close boundary
        if (haystack[p + x - 1] == AsciiRunes.runeMinus &&
            haystack[p + x] == AsciiRunes.runeMinus) {
          //print('boundary close at $p');
          ps.add(p);
          isComplete = true;
        }
      }
      p += x;
      //print('continue from $p');
    }
    return ps;
  }

  RawDataHelper._();
}
