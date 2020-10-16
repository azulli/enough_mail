/// LIST-EXTENDED selection options
enum SelectionOption {
  /// Includes flags for special-use mailboxes, such as those used to hold draft messages or sent messages.
  specialUse,

  /// List only subscribed names. Supplements the LSUB command but with accurate and complete informations.
  subscribed,

  /// Shows also remote mailboxes, marked with "\Remote" attribute.
  remote,

  /// Forces the return of informations about non matched mailboxes whose children matches the selection options.
  ///
  /// Cannot be uses alone or in combination with only the REMOTE option
  recursiveMatch,
}

extension Stringify on SelectionOption {
  String value() {
    switch (this) {
      case SelectionOption.specialUse:
        return 'SPECIAL-USE';
      case SelectionOption.subscribed:
        return 'SUBSCRIBED';
      case SelectionOption.remote:
        return 'REMOTE';
      case SelectionOption.recursiveMatch:
        return 'RECURSIVEMATCH';
    }
    throw UnsupportedError('Invalid LIST selection option');
  }
}
