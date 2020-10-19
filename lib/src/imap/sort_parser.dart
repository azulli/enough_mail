import 'package:enough_mail/imap/message_sequence.dart';
import 'package:enough_mail/imap/response.dart';
import 'package:enough_mail/src/imap/response_parser.dart';

import 'imap_response.dart';

/// Parses sort responses
class SortParser extends ResponseParser<SortImapResult> {
  List<int> ids = <int>[];
  int highestModSequence;

  bool isExtended;
  String tag;
  int min;
  int max;
  int count;
  MessageSequence all;

  String partialRange;
  MessageSequence partial;

  SortParser(this.isExtended);

  @override
  SortImapResult parse(
      ImapResponse details, Response<SortImapResult> response) {
    if (response.isOkStatus) {
      var result = SortImapResult()
        ..ids = ids
        ..highestModSequence = highestModSequence
        ..isExtended = isExtended
        ..tag = tag
        ..min = min
        ..max = max
        ..count = count
        ..all = all
        ..partialRange = partialRange
        ..partial = partial;
      return result;
    }
    return null;
  }

  @override
  bool parseUntagged(
      ImapResponse imapResponse, Response<SortImapResult> response) {
    var details = imapResponse.parseText;
    if (details.startsWith('SORT ')) {
      return _parseDetails(details);
    } else if (details.startsWith('ESEARCH ')) {
      return _parseExtended(details);
    } else if (details == 'SORT' || details == 'ESEARCH') {
      // this is an empty search result
      return true;
    } else {
      return super.parseUntagged(imapResponse, response);
    }
  }

  bool _parseDetails(String details) {
    var listEntries = parseListEntries(details, 'SORT '.length, null);
    for (var i = 0; i < listEntries.length; i++) {
      var entry = listEntries[i];
      // Maybe MODSEQ should not be supported by SORT (introduced by ESORT?)
      if (entry == '(MODSEQ') {
        i++;
        entry = listEntries[i];
        var modSeqText = entry.substring(0, entry.length - 1);
        highestModSequence = int.tryParse(modSeqText);
      } else {
        var id = int.tryParse(entry);
        if (id != null) {
          ids.add(id);
        }
      }
    }
    return true;
  }

  bool _parseExtended(String details) {
    isExtended = true;
    var hasUid = false;
    var listEntries = parseListEntries(details, 'ESEARCH '.length, null);
    for (var i = 0; i < listEntries.length; i++) {
      var entry = listEntries[i];
      if (entry == '(TAG') {
        i++;
        entry = listEntries[i];
        tag = entry.substring(0, entry.length - 1);
      } else if (entry == 'UID') {
        hasUid = true;
      } else if (entry == 'MIN') {
        i++;
        min = int.tryParse(listEntries[i]);
      } else if (entry == 'MAX') {
        i++;
        max = int.tryParse(listEntries[i]);
      } else if (entry == 'COUNT') {
        i++;
        count = int.tryParse(listEntries[i]);
      } else if (entry == 'ALL') {
        i++;
        all = MessageSequence.parse(listEntries[i], isUidSequence: hasUid);
      } else if (entry == 'MODSEQ') {
        i++;
        highestModSequence = int.tryParse(listEntries[i]);
      } else if (entry == 'PARTIAL') {
        i++;
        partialRange = listEntries[i].substring(1);
        i++;
        partial = MessageSequence.parse(
            listEntries[i].substring(0, listEntries[i].length - 1));
      }
    }
    return true;
  }
}
