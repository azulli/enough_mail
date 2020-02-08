An experimental IMAP and SMTP client for Dart developers.

Available under the commercial friendly 
[MPL Mozilla Public License 2.0](https://www.mozilla.org/en-US/MPL/).

## Usage

A simple usage example:

```dart
import 'package:enough_mail/enough_mail.dart';

main() async {
  var client  = ImapClient(isLogEnabled: true);
  await client.connectToServer('imap.example.com', 993, isSecure: true);
  var loginResponse = await client.login('user.name', 'secret');
  if (loginResponse.isOkStatus) {
    var listResponse = await client.listMailboxes();
    if (listResponse.isOkStatus) {
      print('mailboxes: ${listResponse.result}');
    }
  }
}
```

## Installation
Add this dependency your pubspec.yaml file:

```
dependencies:
  enough_mail: ^0.0.3
```
The latest version or `enough_mail` is [![enough_mail version](https://img.shields.io/pub/v/enough_mail.svg)](https://pub.dartlang.org/packages/enough_mail).


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/Enough-Software/enough_mail/issues

Done:
* ✅ basic [IMAP4 rev1](https://tools.ietf.org/html/rfc3501) support 
* ✅ [IMAP IDLE](https://tools.ietf.org/html/rfc2177) support
* ✅ basic [SMTP](https://tools.ietf.org/html/rfc5321) support

Open:
* hardening & bugfixing
* support more encodings
* improve performance
* support [OAuth 2.0](https://tools.ietf.org/html/rfc6749) for login
* support [IMAP4 rev1](https://tools.ietf.org/html/rfc3501) fully
* support [IMAP METADATA](https://tools.ietf.org/html/rfc5464)
* support [WebPush IMAP Extension](https://github.com/coi-dev/coi-specs/blob/master/webpush-spec.md)
* support [Open PGP](https://tools.ietf.org/html/rfc4880)
* support [POP3](https://tools.ietf.org/html/rfc1939)
