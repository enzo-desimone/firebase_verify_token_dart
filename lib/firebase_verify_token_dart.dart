import 'dart:convert';
import 'dart:developer';

import 'package:firebase_verify_token_dart/firebase_jwt.dart';
import 'package:firebase_verify_token_dart/models/firebase_mock.dart';
import 'package:http/http.dart' as http;
import 'package:jose_plus/jose.dart';

/// This class handles the verification of Firebase JWT tokens,
/// including caching and retrieval of Google's public keys for signature validation.
class FirebaseVerifyToken {
  /// List of accepted Firebase project IDs used to validate the `aud` claim of the token.
  static List<String> projectIds = <String>[];

  /// Cached public keys used for verifying the token's signature.
  static Map<String, String>? _cachedKeys;

  /// Expiration timestamp for the cached public keys.
  static DateTime? _cacheExpiration;

  /// URL to retrieve Google's public keys used for Firebase token verification.
  static const String _googleUrlKeys =
      'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com';

  /// Verifies a Firebase JWT token.
  ///
  /// Returns `true` if the token is valid, `false` otherwise.
  ///
  /// Validations include:
  /// - Token algorithm (`alg`)
  /// - Key ID (`kid`) presence in Google public keys
  /// - Signature verification using Google's public keys
  /// - Audience (`aud`) matches one of the configured [projectIds]
  /// - Issued at (`iat`), expiration (`exp`), and auth time (`auth_time`) validity
  /// - Issuer (`iss`) matches expected Firebase format
  /// - Subject (`sub`) is not empty
  ///
  /// Optionally invokes [onVerifySuccessful] callback with verification result and project ID.
  static Future<bool> verify(
    String token, {
    void Function({required bool status, String? projectId})?
        onVerifySuccessful,
  }) async {
    if (projectIds.isEmpty) return false;

    try {
      final publicKeys = await _fetchPublicKeys();
      final jwt = JsonWebToken.unverified(token);
      final header = FirebaseJWT.parseJwtHeader(token);

      final firebaseMock = FirebaseMock.fromValue(header, jwt.claims.toJson());

      if (!publicKeys.containsKey(firebaseMock.kid)) return false;

      if (!firebaseMock.validateAlg) {
        log('Token uses an unsupported algorithm: ${firebaseMock.alg}');
        return false;
      }

      if (!firebaseMock.validateKeysByKid(publicKeys.keys.toList())) {
        return false;
      }

      final publicKey = JsonWebKey.fromPem(
        publicKeys[firebaseMock.kid]!,
        keyId: firebaseMock.kid,
      );
      final keyStore = JsonWebKeyStore()..addKey(publicKey);

      if (!await jwt.verify(keyStore)) return false;
      if (!firebaseMock.validateProjectID(projectIds)) return false;
      if (!await firebaseMock.validateExpIatAuthTime) return false;

      if (!firebaseMock.validateIss || !firebaseMock.validateSub) return false;

      onVerifySuccessful?.call(
        status: true,
        projectId: firebaseMock.projectID,
      );
      return true;
    } catch (e) {
      onVerifySuccessful?.call(status: false);
      log('Error verifying token: ($e)');
      return false;
    }
  }

  /// Retrieves and caches Google's public keys for Firebase token validation.
  ///
  /// If cached keys are still valid (based on HTTP headers), they are returned directly.
  static Future<Map<String, String>> _fetchPublicKeys() async {
    if (_cachedKeys != null &&
        _cacheExpiration != null &&
        DateTime.now().isBefore(_cacheExpiration!)) {
      return _cachedKeys!;
    }

    final response = await http.get(Uri.parse(_googleUrlKeys));

    if (response.statusCode == 200) {
      _cachedKeys = Map<String, String>.from(json.decode(response.body) as Map);
      _cacheExpiration = _getCacheExpirationFromHeaders(response.headers);
      return _cachedKeys!;
    } else {
      throw Exception('Failed to load public keys');
    }
  }

  /// Determines cache expiration time based on HTTP response headers.
  ///
  /// Returns a [DateTime] representing the cache validity.
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
    return DateTime.now().add(const Duration(minutes: 10));
  }

  /// Extracts the user ID (`sub` claim) from a Firebase JWT without verifying the token.
  ///
  /// Useful for quickly retrieving the authenticated user's UID.
  static String getUserID(String token) {
    final jwt = JsonWebToken.unverified(token);
    return jwt.claims['sub'] as String;
  }

  /// Extracts the Firebase project ID (`aud` claim) from a JWT without verifying the token.
  ///
  /// Returns `null` if the claim is missing.
  static String? getProjectID(String token) {
    final jwt = JsonWebToken.unverified(token);
    return jwt.claims['aud'] as String?;
  }
}
