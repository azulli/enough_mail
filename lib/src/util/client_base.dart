import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';

class ConnectionInfo {
  final String host;
  final int port;
  final bool isSecure;
  const ConnectionInfo(this.host, this.port, this.isSecure);
}

typedef LoggerFn = void Function(LogRecord);

/// Base class for socket-based clients
abstract class ClientBase {
  static const String initialClient = 'C';
  static const String initialServer = 'S';
  static const String initialApp = 'A';

  String? logName;
  bool isLogEnabled;
  late Socket _socket;
  bool isSocketClosingExpected = false;
  bool isLoggedIn = false;
  bool _isServerGreetingDone = false;
  late ConnectionInfo connectionInfo;
  late Completer<ConnectionInfo> _greetingsCompleter;
  final Duration? connectionTimeout;

  bool _isConnected = false;

  void onDataReceived(Uint8List data);
  void onConnectionEstablished(
      ConnectionInfo connectionInfo, String serverGreeting);
  void onConnectionError(dynamic error);

  late StreamSubscription _socketStreamSubscription;

  late final Logger logger;
  StreamSubscription<LogRecord>? _loggerSubscription;

  /// Creates a new base client
  ///
  /// Set [isLogEnabled] to `true` to see log output.
  /// Set the [logName] for adding the name to each log entry.
  /// Set the [connectionTimeout] in case the connection connection should timeout automatically after the given time.
  ClientBase(
      {this.isLogEnabled = false, this.logName, this.connectionTimeout}) {
    logger = Logger.detached(logName ?? '$runtimeType');
    _loggerSubscription = logger.onRecord.listen(_logDispatcher);
  }

  /// Connects to the specified server.
  ///
  /// Specify [isSecure] if you do not want to connect to a secure service.
  Future<ConnectionInfo> connectToServer(String host, int port,
      {bool isSecure = true}) async {
    log('connecting to server $host:$port - secure: $isSecure',
        initial: initialApp);
    connectionInfo = ConnectionInfo(host, port, isSecure);
    final socket = isSecure
        ? await SecureSocket.connect(host, port)
        : await Socket.connect(host, port);
    _greetingsCompleter = Completer<ConnectionInfo>();
    _isServerGreetingDone = false;
    connect(socket);
    return _greetingsCompleter.future;
  }

  /// Starts to liste on [socket].
  ///
  /// This is mainly useful for testing purposes, ensure to set [connectionInformation] manually in this  case.
  void connect(Socket socket, {ConnectionInfo? connectionInformation}) {
    if (connectionInformation != null) {
      connectionInfo = connectionInformation;
      _greetingsCompleter = Completer<ConnectionInfo>();
    }
    _socket = socket;
    _writeFuture = null;
    if (connectionTimeout != null) {
      final timeoutStream = socket.timeout(connectionTimeout!);
      _socketStreamSubscription = timeoutStream.listen(
        _onDataReceived,
        onDone: onConnectionDone,
        onError: _onConnectionError,
      );
    } else {
      _socketStreamSubscription = socket.listen(
        _onDataReceived,
        onDone: onConnectionDone,
        onError: _onConnectionError,
      );
    }
    _isConnected = true;
    isSocketClosingExpected = false;
  }

  void _onConnectionError(dynamic e) async {
    log('Socket error: $e', initial: initialApp);
    isLoggedIn = false;
    _isConnected = false;
    _writeFuture = null;
    if (!isSocketClosingExpected) {
      isSocketClosingExpected = true;
      try {
        await _socketStreamSubscription.cancel();
      } catch (e, s) {
        log('Unable to cancel stream subscription: $e $s', initial: initialApp);
      }
      try {
        onConnectionError(e);
      } catch (e, s) {
        log('Unable to call onConnectionError: $e, $s', initial: initialApp);
      }
    }
  }

  Future<void> upradeToSslSocket() async {
    _socketStreamSubscription.pause();
    final secureSocket = await SecureSocket.secure(_socket);
    log('now using secure connection.', initial: initialApp);
    await _socketStreamSubscription.cancel();
    isSocketClosingExpected = true;
    _socket.destroy();
    isSocketClosingExpected = false;
    connect(secureSocket);
  }

  void _onDataReceived(Uint8List data) async {
    if (_isServerGreetingDone) {
      onDataReceived(data);
    } else {
      _isServerGreetingDone = true;
      final serverGreeting = String.fromCharCodes(data);
      log(serverGreeting, isClient: false);
      onConnectionEstablished(connectionInfo, serverGreeting);
      _greetingsCompleter.complete(connectionInfo);
    }
  }

  void onConnectionDone() {
    log('Done, connection closed', initial: initialApp);
    isLoggedIn = false;
    _isConnected = false;
    if (!isSocketClosingExpected) {
      isSocketClosingExpected = true;
      onConnectionError('onDone not expected');
    }
  }

  Future<void> disconnect() async {
    if (_isConnected) {
      log('disconnecting', initial: initialApp);
      isLoggedIn = false;
      _isConnected = false;
      isSocketClosingExpected = true;
      try {
        await _socketStreamSubscription.cancel();
      } catch (e) {
        print('unable to cancel subscription $e');
      }
      try {
        await _socket.close();
      } catch (e) {
        print('unable to close socket $e');
      }
    }
  }

  Future? _writeFuture;

  /// Writes the specified [text].
  ///
  /// When the log is enabled it will either log the specified [logObject] or just the [text].
  Future writeText(String text, [dynamic logObject]) async {
    final previousWriteFuture = _writeFuture;
    if (previousWriteFuture != null) {
      try {
        await previousWriteFuture;
      } catch (e, s) {
        print('Unable to await previous write future: $e $s');
        _writeFuture = null;
      }
    }
    if (isLogEnabled) {
      logObject ??= text;
      log(logObject);
    }
    _socket.write(text + '\r\n');
    final future = _socket.flush();
    _writeFuture = future;
    await future;
    _writeFuture = null;
  }

  /// Writes the specified [data].
  ///
  /// When the log is enabled it will either log the specified [logObject] or just the length of the data.
  Future writeData(List<int> data, [dynamic logObject]) async {
    final previousWriteFuture = _writeFuture;
    if (previousWriteFuture != null) {
      try {
        await previousWriteFuture;
      } catch (e, s) {
        print('Unable to await previous write future: $e $s');
        _writeFuture = null;
      }
    }
    if (isLogEnabled) {
      logObject ??= '<${data.length} bytes>';
      log(logObject);
    }
    _socket.add(data);
    final future = _socket.flush();
    _writeFuture = future;
    await future;
    _writeFuture = null;
  }

  Level get logLevel => logger.level;
  set logLevel(Level level) => logger.level = level;

  LoggerFn? _loggerHandlerFn;

  void setLoggerHandler(LoggerFn? handler) => _loggerHandlerFn = handler;

  void removeLoggerHandler() => _loggerHandlerFn = null;

  /// Determina quale funzione di logging utilizzare
  void _logDispatcher(LogRecord record) {
    if (record.loggerName != logName) return;
    if (_loggerHandlerFn != null) {
      _loggerHandlerFn!(record);
    } else {
      print(
          '[${record.loggerName}] ${record.level.name}: ${record.time}: ${record.message}');
    }
  }

  void log(dynamic logObject,
      {bool isClient = true, String? initial, Level level = Level.INFO}) {
    if (isLogEnabled) {
      initial ??= (isClient == true) ? initialClient : initialServer;
      logger.log(level, '$initial: $logObject');
    }
  }
}

// class _QueuedText {
//   final String text;
//   final dynamic logObject;
//   _QueuedText(this.text, this.logObject);
// }
