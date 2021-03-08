enum SmtpEventType { connectionLost, unknown, streamData }

class SmtpEvent {
  SmtpEventType type;

  SmtpEvent(this.type);
}

class SmtpConnectionLostEvent extends SmtpEvent {
  SmtpConnectionLostEvent() : super(SmtpEventType.connectionLost);
}

class SmtpStreamDataEvent extends SmtpEvent {
  final int transferred;
  final int total;
  SmtpStreamDataEvent(this.transferred, this.total)
      : super(SmtpEventType.streamData);
}
