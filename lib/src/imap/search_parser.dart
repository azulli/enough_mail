import 'package:enough_mail/imap/message_sequence.dart';
import 'package:enough_mail/imap/response.dart';
import 'package:enough_mail/src/imap/response_parser.dart';

import 'imap_response.dart';

/// Parses search responses
///
/// The flag [isExtended] must be set if the command was an extended search.
class SearchParser extends ResponseParser<SearchImapResult> {
  List<int> ids = <int>[];
  int highestModSequence;

  bool isExtended;
  String tag; // Reference tag for the current extended search untagged response
  int min;
  int max;
  int count;

  MessageSequence sequenceSet;

  String partialRange;

  SearchParser([this.isExtended = false]);

  @override
  SearchImapResult parse(
      ImapResponse details, Response<SearchImapResult> response) {
    if (response.isOkStatus) {
      var result = SearchImapResult()
        ..ids = ids
        ..highestModSequence = highestModSequence
        ..isExtended = isExtended
        ..tag = tag
        ..min = min
        ..max = max
        ..count = count
        ..sequenceSet = sequenceSet
        ..partialRange = partialRange;
      return result;
    }
    return null;
  }

  @override
  bool parseUntagged(
      ImapResponse imapResponse, Response<SearchImapResult> response) {
    var details = imapResponse.parseText;
    if (details.startsWith('SEARCH ')) {
      return _parseDetails(details);
    } else if (details.startsWith('ESEARCH ')) {
      return _parseExtended(details);
    } else if (details == 'SEARCH' || details == 'ESEARCH') {
      return true;
    } else {
      return super.parseUntagged(imapResponse, response);
    }
  }

  bool _parseDetails(String details) {
    var listEntries = parseListEntries(details, 'SEARCH '.length, null);
    for (var i = 0; i < listEntries.length; i++) {
      var entry = listEntries[i];
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
        sequenceSet =
            MessageSequence.parse(listEntries[i], isUidSequence: hasUid);
      } else if (entry == 'MODSEQ') {
        i++;
        highestModSequence = int.tryParse(listEntries[i]);
      } else if (entry == 'PARTIAL') {
        i++;
        partialRange = listEntries[i].substring(1);
        i++;
        sequenceSet = MessageSequence.parse(
            listEntries[i].substring(0, listEntries[i].length - 1));
      }
    }
    // Expands the sequence-set to the corresponding U/IDs list
    if (sequenceSet != null &&
        !sequenceSet.isNil &&
        !sequenceSet.isSavedSequence) {
      ids = sequenceSet.toList();
    }
    return true;
  }
}
