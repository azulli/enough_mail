import 'package:enough_mail/imap/response.dart';
import 'package:enough_mail/src/imap/response_parser.dart';

import 'imap_response.dart';

/// Parses sort responses
class SortParser extends ResponseParser<SortImapResult> {
  List<int> ids = <int>[];
  int highestModSequence;

  @override
  SortImapResult parse(
      ImapResponse details, Response<SortImapResult> response) {
    if (response.isOkStatus) {
      var result = SortImapResult()
        ..ids = ids
        ..highestModSequence = highestModSequence;
      return result;
    }
    return null;
  }

  @override
  bool parseUntagged(
      ImapResponse imapResponse, Response<SortImapResult> response) {
    var details = imapResponse.parseText;
    if (details.startsWith('SORT ')) {
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
    } else if (details == 'SORT') {
      // this is an empty search result
      return true;
    } else {
      return super.parseUntagged(imapResponse, response);
    }
  }
}
