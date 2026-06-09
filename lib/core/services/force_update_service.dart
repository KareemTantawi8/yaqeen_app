import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ForceUpdateService {
  static const _minVersionKey = 'min_required_version';

  /// Returns true if the installed version is below the minimum required
  /// version stored in Firebase Remote Config.
  static Future<bool> isUpdateRequired() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await remoteConfig.setDefaults({_minVersionKey: '1.0.0'});

      await remoteConfig.fetchAndActivate();

      final minVersion = remoteConfig.getString(_minVersionKey);
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      return _isVersionBelow(currentVersion, minVersion);
    } catch (e) {
      debugPrint('ForceUpdateService: check failed – $e');
      return false;
    }
  }

  /// Returns true if [current] is strictly less than [minimum].
  static bool _isVersionBelow(String current, String minimum) {
    final c = _parse(current);
    final m = _parse(minimum);

    for (var i = 0; i < 3; i++) {
      if (c[i] < m[i]) return true;
      if (c[i] > m[i]) return false;
    }
    return false;
  }

  static List<int> _parse(String version) {
    final parts = version.trim().split('.');
    return List.generate(3, (i) => i < parts.length ? int.tryParse(parts[i]) ?? 0 : 0);
  }
}
