import 'dart:async';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// A static class to manage accurate UTC time using HTTP synchronization and local caching.
class AccurateTime {
  /// The last fetched accurate UTC time from the HTTP API.
  static DateTime? _cachedUtcTime;

  /// The local time when the last HTTP sync occurred.
  static DateTime? _lastHttpSync;

  /// The interval at which the time should be resynchronized.
  static Duration syncInterval = const Duration(minutes: 60);

  static String get _url => 'https://postman-echo.com/time/now';

  /// Returns the current accurate UTC time.
  ///
  /// If the cached time is outdated or not initialized, it fetches the time
  /// from an external HTTP API. Then it adjusts based on local time drift.
  static Future<DateTime> now() async {
    if (_cachedUtcTime == null ||
        _lastHttpSync == null ||
        DateTime.now().difference(_lastHttpSync!) > syncInterval) {
      await _syncHttpTime();
    }

    final timeDifference = DateTime.now().difference(_lastHttpSync!);
    return _cachedUtcTime!.add(timeDifference);
  }

  /// Returns the current accurate UTC time as an ISO 8601 string.
  static Future<String> nowToIsoString() async {
    return (await now()).toIso8601String();
  }

  /// Fetches the current UTC time from an external HTTP API and updates the cache.
  ///
  /// The endpoint used is: https://timeapi.io/api/Time/current/zone?timeZone=UTC
  /// If the request fails, the cached time will not be updated.
  static Future<void> _syncHttpTime() async {
    try {
      final response = await http.get(Uri.parse(_url));
      _lastHttpSync = DateTime.now();
      final stringDate = response.body;
      final format = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US');
      _cachedUtcTime = format.parseUTC(stringDate);
    } catch (e) {
      _cachedUtcTime = DateTime.now().toUtc();
      log('Failed to sync with HTTP time: $e');
    }
  }

  /// Updates the duration used to determine when to resync the time.
  static void setSyncInterval(Duration newInterval) {
    syncInterval = newInterval;
  }
}
