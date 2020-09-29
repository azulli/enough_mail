import 'package:enough_mail/smtp/smtp_client.dart';
import 'package:enough_mail/smtp/smtp_response.dart';
import '../smtp_command.dart';

class SmtpQuitCommand extends SmtpCommand {
  final SmtpClient _client;
  SmtpQuitCommand(this._client) : super('QUIT');

  @override
  Future<String> nextCommand(SmtpResponse response) async {
    await _client.closeConnection();
    return null;
  }
}
