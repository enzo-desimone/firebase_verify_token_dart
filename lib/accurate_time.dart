import 'dart:async';
import 'dart:developer';

import 'package:ntp/ntp.dart';

/// A static class to manage accurate time using NTP synchronization and local caching.
class AccurateTime {
  /// Cached NTP time.
  static DateTime? _cachedNtpTime;

  /// Last time the NTP sync occurred.
  static DateTime? _lastNtpSync;

  /// The interval for NTP synchronization.
  static Duration syncInterval = const Duration(minutes: 10);

  /// Gets the current accurate time, using cached NTP time with local offset.
  /// If the cache is too old or not available, it will synchronize with NTP.
  static Future<DateTime> now() async {
    if (_cachedNtpTime == null ||
        _lastNtpSync == null ||
        DateTime.now().difference(_lastNtpSync!) > syncInterval) {
      await _syncNtpTime();
    }

    final timeDifference = DateTime.now().difference(_lastNtpSync!);
    return _cachedNtpTime!.add(timeDifference);
  }

  /// Forces synchronization with NTP and updates the cached time.
  static Future<void> _syncNtpTime() async {
    try {
      _cachedNtpTime = (await NTP.now()).toUtc();
      _lastNtpSync = DateTime.now();
    } catch (e) {
      log('Failed to sync with NTP: $e');
    }
  }

  /// Updates the sync interval duration if needed.
  static void setSyncInterval(Duration newInterval) {
    syncInterval = newInterval;
  }
}
