class SmtpCodec {
  /// Dubles the initial dot of any text line.
  ///
  /// See https://tools.ietf.org/html/rfc5321#section-4.5.2
  static String dotStuff(final String text) {
    return text.replaceAll('\r\n.', '\r\n..');
  }
}
