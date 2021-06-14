import 'package:enough_mail/mail_address.dart';
import 'package:enough_mail/src/imap/parser_helper.dart';
import 'package:enough_mail/src/util/mail_address_parser.dart';

/// Export della funzione di parsing degli indirizzi email
List<MailAddress> parseEmailAddresses(String? emailText) =>
    MailAddressParser.parseEmailAddreses(emailText);

String? parseEmail(String value) => ParserHelper.parseEmail(value);
