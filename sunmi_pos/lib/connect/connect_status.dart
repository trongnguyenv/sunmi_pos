import 'dart:io'; //InternetAddress utility
import 'dart:async'; //For StreamController/Stream

import 'package:connectivity/connectivity.dart';

class ConnectionStatusSingleton {
  static final ConnectionStatusSingleton _singleton =
      new ConnectionStatusSingleton._internal();

  ConnectionStatusSingleton._internal();

  static ConnectionStatusSingleton getInstance() => _singleton;

  bool hasConnection = false;

  StreamController connectionChangeController =
      new StreamController.broadcast();

  void dispose() {
    connectionChangeController.close();
  }

  final Connectivity _connectivity = Connectivity();

  void initialize() {
    _connectivity.onConnectivityChanged.listen(_connectionChange);
  }

  Stream get connectionChange => connectionChangeController.stream;

  void _connectionChange(ConnectivityResult result) {
    checkConnection();
  }

  Future<bool> checkConnection() async {
    bool previousConnection = hasConnection;

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty)
        hasConnection = true;
      else
        hasConnection = false;
    } on SocketException catch (_) {
      hasConnection = false;
    }

    if (previousConnection != hasConnection)
      connectionChangeController.add(hasConnection);

    return hasConnection;
  }
}
