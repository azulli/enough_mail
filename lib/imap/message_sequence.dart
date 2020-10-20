import 'package:enough_mail/enough_mail.dart';

/// Defines a list of message IDs.
/// IDs can be either be based on sequence IDs or on UIDs.
class MessageSequence {
  /// True when this sequence is consisting of UIDs
  final bool isUidSequence;

  /// True when this sequence represents a previously saved result
  final bool isSavedSequence;

  /// This flag prevents the sorting of the [_ids] list that voids any given ordering.
  final bool dontReorder;

  /// The length of this sequence - only valid when there is no range to last involved.
  int get length => toList().length;

  final List<int> _ids = <int>[];
  final List<int> _idsWithRangeToLast = <int>[];
  final Map<int, int> _idsWithRange = <int, int>{};
  bool _isLastAdded = false;
  bool _isAllAdded = false;
  String _text;

  bool _isNilSequence = false;
  bool get isNil => _isNilSequence;

  /// Creates a new message sequence.
  /// Optionally specify [isUidSequence] in case this is a sequence based on UIDs.
  MessageSequence(
      {this.isUidSequence,
      this.isSavedSequence = false,
      this.dontReorder = false});

  /// Adds the sequence ID of the specified [message].
  void addSequenceId(MimeMessage message) {
    if (isSavedSequence) {
      throw StateError('cannot add sequence IDs to a saved sequence reference');
    }
    var id = message.sequenceId;
    if (id == null) {
      throw StateError('no sequence ID found in message');
    }
    add(id);
  }

  /// Removes the sequence ID of the specified [message].
  void removeSequenceId(MimeMessage message) {
    if (isSavedSequence) {
      throw StateError(
          'cannot remove sequence IDs from a saved sequence reference');
    }
    var id = message.sequenceId;
    if (id == null) {
      throw StateError('no sequence ID found in message');
    }
    remove(id);
  }

  /// Adds the UID of the specified [message].
  void addUid(MimeMessage message) {
    if (isSavedSequence) {
      throw StateError('cannot add UIDs to a saved sequence reference');
    }
    var uid = message.uid;
    if (uid == null) {
      throw StateError('no UID found in message');
    }
    add(uid);
  }

  /// Remoces the UID of the specified [message].
  void removeUid(MimeMessage message) {
    if (isSavedSequence) {
      throw StateError('cannot remove UIDs from a saved sequence reference');
    }
    var uid = message.uid;
    if (uid == null) {
      throw StateError('no UID found in message');
    }
    remove(uid);
  }

  /// Adds the specified ID
  void add(int id) {
    if (isSavedSequence) {
      throw StateError('cannot add sequence ID to a saved sequence reference');
    }
    _ids.add(id);
    _text = null;
  }

  void remove(int id) {
    if (isSavedSequence) {
      throw StateError(
          'cannot remove sequence ID from a saved sequence reference');
    }
    _ids.remove(id);
    _text = null;
  }

  /// Adds all messages between [start] and [end] inclusive.
  void addRange(int start, int end) {
    if (isSavedSequence) {
      throw StateError(
          'cannot add sequence ID range to a saved sequence reference');
    }
    // start:end
    if (start == end) {
      add(start);
      return;
    }
    var wasEmpty = isEmpty();
    _idsWithRange[start] = end;
    if (wasEmpty) {
      _text = '$start:$end';
    } else {
      _text = null;
    }
  }

  /// Adds a range from the specified [start] ID towards to the last ('*') element.
  void addRangeToLast(int start) {
    if (isSavedSequence) {
      throw StateError('cannot add id range to a saved sequence reference');
    }
    // start:*
    var wasEmpty = isEmpty();
    _idsWithRangeToLast.add(start);
    if (wasEmpty) {
      _text = '$start:*';
    } else {
      _text = null;
    }
  }

  /// Adds the last element, which is alway '*'.
  void addLast() {
    if (isSavedSequence) {
      throw StateError('cannot update a saved sequence reference');
    }
    // *
    var wasEmpty = isEmpty();
    _isLastAdded = true;
    if (wasEmpty) {
      _text = '*';
    } else {
      _text = null;
    }
  }

  /// Adds all messages
  /// This results into '1:*'.
  void addAll() {
    if (isSavedSequence) {
      throw StateError('cannot replace a saved sequence reference');
    }
    // 1:*
    var wasEmpty = isEmpty();
    _isAllAdded = true;
    if (wasEmpty) {
      _text = '1:*';
    } else {
      _text = null;
    }
  }

  /// Adds the specified IDs
  void addList(List<int> ids) {
    if (isSavedSequence) {
      throw StateError('cannot add list of ids to a saved sequence reference');
    }
    _ids.addAll(ids);
    _text = null;
  }

  /// Convenience method for getting the sequence for a single [id].
  /// Optionally specify the if the ID is a UID with [isUid], defaults to false.
  static MessageSequence fromId(int id, {bool isUid}) {
    var sequence = MessageSequence(isUidSequence: isUid);
    sequence.add(id);
    return sequence;
  }

  /// Convenience method for getting the sequence for a single [message].
  static MessageSequence fromSequenceId(MimeMessage message) {
    var sequence = MessageSequence();
    sequence.addSequenceId(message);
    return sequence;
  }

  /// Convenience method for getting the sequence for a single [message]'s UID.
  static MessageSequence fromUid(MimeMessage message) {
    var sequence = MessageSequence(isUidSequence: true);
    sequence.addUid(message);
    return sequence;
  }

  /// Convenience method for getting the sequence for a single [message]'s UID or sequence ID.
  static MessageSequence fromMessage(MimeMessage message) {
    bool isUid;
    int id;
    if (message.uid != null) {
      isUid = true;
      id = message.uid;
    } else {
      isUid = false;
      id = message.sequenceId;
    }
    var sequence = MessageSequence(isUidSequence: isUid);
    sequence.add(id);
    return sequence;
  }

  /// Convenience method for getting the sequence for a single range from [start] to [end] inclusive.
  static MessageSequence fromRange(int start, int end) {
    var sequence = MessageSequence();
    sequence.addRange(start, end);
    return sequence;
  }

  /// Convenience method for getting the sequence for a single range from [start] to the last message inclusive.
  static MessageSequence fromRangeToLast(int start) {
    var sequence = MessageSequence();
    sequence.addRangeToLast(start);
    return sequence;
  }

  /// Convenience method for getting the sequence for the last message.
  static MessageSequence fromLast() {
    var sequence = MessageSequence();
    sequence.addLast();
    return sequence;
  }

  /// Convenience method for getting the sequence for all messages.
  static MessageSequence fromAll() {
    var sequence = MessageSequence();
    sequence.addAll();
    return sequence;
  }

  /// Convenience method for getting the sequence from a list of message UIDs.
  ///
  /// For search results set [dontReorder] to true
  static MessageSequence fromUidList(List<int> list,
      [bool dontReorder = false]) {
    var sequence =
        MessageSequence(isUidSequence: true, dontReorder: dontReorder);
    sequence.addList(list);
    return sequence;
  }

  static MessageSequence parse(String text, {bool isUidSequence}) {
    var sequence = MessageSequence(isUidSequence: isUidSequence);
    var chunks = text.split(',');
    if (chunks[0] == 'NIL') {
      sequence._isNilSequence = true;
    } else {
      for (var chunk in chunks) {
        var id = int.tryParse(chunk);
        if (id != null) {
          sequence.add(id);
        } else if (chunk == '*') {
          sequence.addLast();
        } else if (chunk.endsWith(':*')) {
          var idText = chunk.substring(0, chunk.length - ':*'.length);
          var id = int.tryParse(idText);
          if (id != null) {
            sequence.addRangeToLast(id);
          } else {
            throw StateError('expect id in $idText for $chunk in $text');
          }
        } else {
          var colonIndex = chunk.indexOf(':');
          if (colonIndex == -1) {
            throw StateError('expect colon in  $chunk / $text');
          }
          var start = int.tryParse(chunk.substring(0, colonIndex));
          var end = int.tryParse(chunk.substring(colonIndex + 1));
          if (start == null || end == null) {
            throw StateError('expect range in  $chunk / $text');
          }
          sequence.addRange(start, end);
        }
      }
    }
    return sequence;
  }

  static MessageSequence saved() {
    var sequence = MessageSequence(isSavedSequence: true);
    sequence._text = r'$';
    return sequence;
  }

  /// Checks if this sequence contains the last indicator in some form - '*'
  bool containsLast() {
    return _isLastAdded || _isAllAdded || _idsWithRangeToLast.isNotEmpty;
  }

  /// Lists all entries of this sequence.
  /// You must specify the number of existing messages with the [exists] parameter, in case this sequence contains the last element '*' in some form.
  /// Use the [containsLast()] method to determine if this sequence contains the last element '*'.
  List<int> toList([int exists]) {
    if (exists == null && containsLast()) {
      throw StateError(
          'Unable to list sequence when * is part of the list and the \'exists\' parameter is not specified.');
    } else if (_isNilSequence) {
      throw StateError('Unable to list non existent sequence.');
    } else if (isSavedSequence) {
      throw StateError('Unable to list a saved sequence reference.');
    }
    if (dontReorder) return List<int>.from(_ids);
    var entries = List<int>.from(_ids);
    entries..sort();
    for (var start in _idsWithRange.keys) {
      var end = _idsWithRange[start];
      for (var i = start; i <= end; i++) {
        entries.add(i);
      }
    }
    for (var start in _idsWithRangeToLast) {
      for (var i = start; i <= exists; i++) {
        entries.add(i);
      }
    }
    if (_isAllAdded) {
      for (var i = 1; i <= exists; i++) {
        entries.add(i);
      }
    }
    if (_isLastAdded) {
      entries.add(exists);
    }
    entries.sort();
    return entries;
  }

  /// Checks is this sequence has no elements
  bool isEmpty() {
    return isSavedSequence
        ? false
        : !_isLastAdded &&
            !_isAllAdded &&
            _ids.isEmpty &&
            _idsWithRangeToLast.isEmpty &&
            _idsWithRange.isEmpty;
  }

  /// Checks is this sequence has at least one element
  bool isNotEmpty() {
    return isSavedSequence
        ? true
        : _isLastAdded ||
            _isAllAdded ||
            _ids.isNotEmpty ||
            _idsWithRangeToLast.isNotEmpty ||
            _idsWithRange.isNotEmpty;
  }

  @override
  String toString() {
    if (_isNilSequence) {
      return 'NIL';
    } else if (_text != null) {
      return _text;
    }
    var buffer = StringBuffer();
    render(buffer);
    return buffer.toString();
  }

  /// Renders this message sequence into the specified StringBuffer [buffer].
  void render(StringBuffer buffer) {
    if (_isNilSequence) {
      buffer.write('NIL');
      return;
    } else if (_text != null) {
      buffer.write(_text);
      return;
    }
    if (isEmpty()) {
      throw StateError('no ID added to sequence');
    }
    if (_ids.length == 1) {
      buffer.write(_ids[0]);
    } else {
      if (dontReorder) {
        buffer.write(_ids.join(','));
      } else {
        _ids.sort();
        int last;
        int lastWritten;
        for (var i = 0; i < _ids.length; i++) {
          var current = _ids[i];
          if (i == 0) {
            lastWritten = current;
            buffer.write(current);
          } else if (current > last + 1) {
            if (last != lastWritten) {
              buffer..write(':')..write(last);
            }
            buffer..write(',')..write(current);
            lastWritten = current;
          } else if (i == _ids.length - 1) {
            if (last == lastWritten) {
              buffer..write(',')..write(current);
            } else {
              buffer..write(':')..write(current);
            }
          }
          last = current;
        }
      }
    }
    if (_idsWithRange.isNotEmpty) {
      var addComma = buffer.length > 0;
      for (var key in _idsWithRange.keys) {
        if (addComma) {
          buffer.write(',');
        }
        var value = _idsWithRange[key];
        buffer..write(key)..write(':')..write(value);
        addComma = true;
      }
    }
    if (_idsWithRangeToLast.isNotEmpty) {
      var addComma = buffer.length > 0;
      for (var id in _idsWithRangeToLast) {
        if (addComma) {
          buffer.write(',');
        }
        buffer..write(id)..write(':*');
        addComma = true;
      }
    }
    if (_isLastAdded) {
      if (buffer.length > 0) {
        buffer.write(',');
      }
      buffer.write('*');
    }
    if (_isAllAdded) {
      if (buffer.length > 0) {
        buffer.write(',');
      }
      buffer.write('1:*');
    }
  }
}
