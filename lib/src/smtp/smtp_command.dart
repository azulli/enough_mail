import 'dart:async';
import 'package:enough_mail/smtp/smtp_response.dart';

class SmtpCommand {
  final String _command;
  String get command => getCommand();

  final Completer<SmtpResponse> completer = Completer<SmtpResponse>();

  SmtpCommand(this._command);

  String getCommand() {
    return _command;
  }

  Future<String> nextCommand(SmtpResponse response) async {
    return null;
  }

  bool isCommandDone(SmtpResponse response) {
    return true;
  }

  bool isStreamData(SmtpResponse response) {
    return false;
  }
}
