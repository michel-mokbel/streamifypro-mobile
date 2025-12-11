import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigProvider extends ChangeNotifier {
  RemoteConfigProvider({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance {
    _init();
  }

  final FirebaseRemoteConfig _remoteConfig;
  bool _isInitialized = false;
  bool _guestLoginEnabled = false;

  bool get isInitialized => _isInitialized;
  bool get guestLoginEnabled => _guestLoginEnabled;

  Future<void> _init() async {
    _log('Initializing remote config');
    try {
      final Duration minFetchInterval = kDebugMode ? Duration.zero : const Duration(hours: 1);
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: minFetchInterval,
      ));
      _log('Config settings applied');
      await _remoteConfig.setDefaults(const {
        'enabled': false,
      });
      _log('Defaults set, fetching remote values');
      final bool fetched = await _remoteConfig.fetchAndActivate();
      _log('Fetch and activate completed (updated: $fetched)');
      _log('Last fetch status: ${_remoteConfig.lastFetchStatus} at ${_remoteConfig.lastFetchTime}');
      _guestLoginEnabled = _readGuestFlag();
    } catch (_) {
      _log('Failed to fetch remote config, using cached/defaults');
      _guestLoginEnabled = _readGuestFlag();
    } finally {
      _isInitialized = true;
      _log('Guest login enabled: $_guestLoginEnabled');
      notifyListeners();
    }
  }

  bool _readGuestFlag() {
    final value = _remoteConfig.getValue('enabled');
    _log('Enabled flag -> ${value.asBool} (source: ${value.source})');
    return value.asBool() ?? false;
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[RemoteConfig] $message');
    }
  }
}
