/// Return option definition for LIST commands.
class ReturnOption {
  final String name;

  /// Optional list of return option parameters.
  final List<String> _parameters;

  /// Optional single return option parameter.
  final String _parameter;

  ReturnOption(this.name, [this._parameters, this._parameter]);

  ReturnOption.specialUse() : this('SPECIAL-USE');

  /// Returns subscription state of all matching mailbox names.
  ReturnOption.subscribed() : this('SUBSCRIBED');

  /// Returns mailbox child information as flags "\HasChildren", "\HasNoChildren".
  ReturnOption.children() : this('CHILDREN');

  /// Returns given STATUS informations of all matching mailbox names.
  ReturnOption.status([List<String> parameters]) : this('STATUS', parameters);

  /// Returns the minimum message id or UID that satisfies the search parameters.
  ReturnOption.min() : this('MIN');

  /// Return the maximum message id or UID that satisfies the search parameters.
  ReturnOption.max() : this('MAX');

  /// Returns all the message ids or UIDs that satisfies the search parameters.
  ReturnOption.all() : this('ALL');

  /// Returns the match count of the search request.
  ReturnOption.count() : this('COUNT');

  /// Indicates that the search criteria are likey to be used in subsequent commands.
  // TODO ReturnOption.context() : this('CONTEXT');

  /// Requests unsolicited updates of the given search.
  // TODO ReturnOption.update() : this('UPDATE');

  /// Returns a view of the search results in the given x:y range set.
  ReturnOption.partial(String rangeSet) : this('PARTIAL', null, rangeSet);

  void add(String parameter) {
    _parameters?.add(parameter);
  }

  void addAll(List<String> parameters) {
    _parameters?.addAll(parameters);
  }

  bool hasParameter(String parameter) =>
      _parameters?.contains(parameter) ?? false;

  @override
  String toString() {
    final result = StringBuffer(name);
    if (_parameter != null) {
      result..write(' ')..write(_parameter);
    } else if (_parameters != null && _parameters.isNotEmpty) {
      result..write(' (')..write(_parameters.join(' '))..write(')');
    }
    return result.toString();
  }
}
