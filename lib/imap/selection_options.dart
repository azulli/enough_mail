/// LIST-EXTENDED selection options
class SelectionOptions {
  /// List only subscribed names. Supplements the LSUB command but with accurate and complete informations.
  static const String subscribed = 'SUBSCRIBED';

  /// Shows also remote mailboxes, marked with "\Remote" attribute.
  static const String remote = 'REMOTE';

  /// Forces the return of informations about non matched mailboxes whose children matches the selection options.
  ///
  /// Cannot be uses alone or in combination with only the REMOTE option
  static const String recursiveMatch = 'RECURSIVEMATCH';
}
