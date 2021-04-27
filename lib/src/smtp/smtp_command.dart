import 'dart:async';
import 'dart:io';
import 'package:enough_mail/smtp/smtp_response.dart';

class SmtpCommand {
  final String _command;
  String get command => getCommand();

  final Completer<SmtpResponse> completer = Completer<SmtpResponse>();

  SmtpCommand(this._command);

  String getCommand() {
    return _command;
  }

  SmtpCommandData? next(SmtpResponse response) {
    final text = nextCommand(response);
    if (text != null) {
      return SmtpCommandData(text, null, null);
    }
    final data = nextCommandData(response);
    if (data != null) {
      return SmtpCommandData(null, data, null);
    }
    final file = nextCommandFile(response);
    if (file != null) {
      return SmtpCommandData(null, null, file);
    }
    return null;
  }

  String? nextCommand(SmtpResponse response) {
    return null;
  }

  List<int>? nextCommandData(SmtpResponse response) {
    return null;
  }

  File? nextCommandFile(SmtpResponse response) {
    return null;
  }

  bool isCommandDone(SmtpResponse response) {
    return true;
  }

  bool isStreamingData(SmtpResponse response) {
    return false;
  }

  @override
  String toString() {
    return command;
  }
}

class SmtpCommandData {
  final String? text;
  final List<int>? data;
  final File? file;
  SmtpCommandData(this.text, this.data, this.file);
}
