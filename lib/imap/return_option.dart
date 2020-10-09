/// Return option definition for LIST commands.
class ReturnOption {
  final String name;
  final List<String> _parameters;

  ReturnOption(this.name, [this._parameters]);

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
    if (_parameters != null && _parameters.isNotEmpty) {
      result..write(' (')..write(_parameters.join(' '))..write(')');
    }
    return result.toString();
  }

  /// Returns subscription state of all matching mailbox names.
  static final subscribed = ReturnOption('SUBSCRIBED');

  /// Returns mailbox child information as flags "\HasChildren", "\HasNoChildren".
  static final children = ReturnOption('CHILDREN');

  /// Returns given STATUS informations of all matching mailbox names.
  static final status = ReturnOption('STATUS', []);
}
