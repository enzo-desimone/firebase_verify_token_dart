import 'dart:convert';
import 'dart:developer';

import 'package:firebase_verify_token_dart/accurate_time.dart';
import 'package:firebase_verify_token_dart/firebase_token.dart';
import 'package:http/http.dart' as http;
import 'package:jose_plus/jose.dart';

/// This class is responsible for verifying Firebase JWT tokens and caching public keys.
class FirebaseVerifyToken {
  /// Firebase project IDs to verify against.
  static List<String> projectIds = <String>[];

  /// Cache for storing public keys.
  static Map<String, String>? _cachedKeys;
  static DateTime? _cacheExpiration;

  /// Verifies a Firebase JWT token. Returns true if valid, otherwise false.
  static Future<bool> verify(
    String token, {
    void Function({required bool status, String? projectId})?
        onVerifySuccessful,
  }) async {
    if (projectIds.isEmpty) return false;

    try {
      final keys = await _fetchPublicKeys();
      final jwt = JsonWebToken.unverified(token);
      final kid = FirebaseJWT.parseJwtHeader(token)['kid'] as String?;

      if (kid == null || !keys.containsKey(kid)) return false;

      final publicKey = JsonWebKey.fromPem(keys[kid]!, keyId: kid);
      final keyStore = JsonWebKeyStore()
        ..addKey(JsonWebKey.fromJson(publicKey.toJson()));
      final isSignatureValid = await jwt.verify(keyStore);

      if (!isSignatureValid) return false;

      final now = await AccurateTime.now();
      final projectId = jwt.claims['aud'] as String?;

      if (!projectIds.contains(projectId)) return false;

      if (!_isClaimDateValid(jwt.claims['exp'], now) ||
          !_isClaimDateValid(jwt.claims['iat'], now, isAfter: true) ||
          !_isClaimDateValid(jwt.claims['auth_time'], now, isAfter: true)) {
        return false;
      }

      if (jwt.claims['iss'] != 'https://securetoken.google.com/$projectId' ||
          jwt.claims['sub'] == null ||
          (jwt.claims['sub'] as String).isEmpty) {
        return false;
      }

      onVerifySuccessful?.call(status: true, projectId: projectId);
      return true;
    } catch (e) {
      onVerifySuccessful?.call(status: false);
      log('Error verifying token: ($e)');
      return false;
    }
  }

  /// Helper function to validate claims with date fields.
  static bool _isClaimDateValid(
    dynamic claim,
    DateTime now, {
    bool isAfter = false,
  }) {
    if (claim == null) return false;
    final claimDate =
        DateTime.fromMillisecondsSinceEpoch((claim as int) * 1000, isUtc: true);
    return isAfter ? claimDate.isBefore(now) : claimDate.isAfter(now);
  }

  /// Fetches public keys from Google or returns cached keys if still valid.
  static Future<Map<String, String>> _fetchPublicKeys() async {
    if (_cachedKeys != null &&
        _cacheExpiration != null &&
        DateTime.now().isBefore(_cacheExpiration!)) {
      return _cachedKeys!;
    }

    final response = await http.get(
      Uri.parse(
        'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com',
      ),
    );

    if (response.statusCode == 200) {
      _cachedKeys = Map<String, String>.from(json.decode(response.body) as Map);
      _cacheExpiration = _getCacheExpirationFromHeaders(response.headers);
      return _cachedKeys!;
    } else {
      throw Exception('Failed to load public keys');
    }
  }

  /// Determines cache expiration time from HTTP headers.
  static DateTime _getCacheExpirationFromHeaders(Map<String, String> headers) {
    if (headers.containsKey('cache-control')) {
      final cacheControl = headers['cache-control'];
      final maxAgeMatch = RegExp(r'max-age=(\d+)').firstMatch(cacheControl!);
      if (maxAgeMatch != null) {
        final maxAge = int.parse(maxAgeMatch.group(1)!);
        return DateTime.now().add(Duration(seconds: maxAge));
      }
    } else if (headers.containsKey('expires')) {
      return DateTime.parse(headers['expires']!);
    }
    return DateTime.now()
        .add(const Duration(minutes: 10)); // Default cache duration
  }

  /// Retrieves the user ID from the token's claims.
  static String getIdByToken(String token) {
    final jwt = JsonWebToken.unverified(token);
    return jwt.claims['user_id'] as String;
  }
}
