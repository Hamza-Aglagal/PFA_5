import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Connection Status
enum ConnectionStatus {
  connected,
  disconnected,
  checking,
}

/// Connectivity Service - Monitors network connectivity
class ConnectivityService extends ChangeNotifier {
  ConnectionStatus _status = ConnectionStatus.checking;
  Timer? _checkTimer;
  bool _isInitialized = false;

  // Getters
  ConnectionStatus get status => _status;
  bool get isConnected => _status == ConnectionStatus.connected;
  bool get isDisconnected => _status == ConnectionStatus.disconnected;
  bool get isChecking => _status == ConnectionStatus.checking;

  /// Initialize connectivity monitoring
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    
    // Initial check
    await checkConnectivity();
    
    // Periodic check every 30 seconds
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      checkConnectivity();
    });
  }

  /// Check current connectivity
  Future<bool> checkConnectivity() async {
    _setStatus(ConnectionStatus.checking);
    
    try {
      // Try to lookup google.com
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _setStatus(ConnectionStatus.connected);
        return true;
      }
    } on SocketException catch (_) {
      _setStatus(ConnectionStatus.disconnected);
    } on TimeoutException catch (_) {
      _setStatus(ConnectionStatus.disconnected);
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      _setStatus(ConnectionStatus.disconnected);
    }
    
    return false;
  }

  /// Force a connectivity check
  Future<bool> refresh() async {
    return checkConnectivity();
  }

  void _setStatus(ConnectionStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}
