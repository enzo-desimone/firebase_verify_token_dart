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

  /// Regular expression used to extract the `max-age` value from cache headers.
  static final RegExp _maxAgeRegExp = RegExp(r'max-age=(\d+)');

  /// Verifies a Firebase JWT token against a predefined list of project IDs
  /// and the corresponding public keys fetched from the authentication service.
  ///
  /// This method fetches the current public keys, parses the provided token,
  /// and validates:
  /// 1. Token algorithm support.
  /// 2. Signature correctness.
  /// 3. Project ID membership.
  /// 4. Expiration (`exp`), "issued at" (`iat`), and authentication time (`auth_time`).
  /// 5. Issuer (`iss`) and subject (`sub`) claims.
  ///
  /// If an optional [onVerifySuccessful] callback is provided, it will be called
  /// at the end of the process with:
  /// - [status]: `true` if verification succeeded, `false` otherwise.
  /// - [projectId]: the matching Firebase project ID (only on success).
  /// - [duration]: the time taken (in milliseconds) for the verification.
  ///
  /// Throws no exceptions; failures return `false` and invoke the callback if given.
  static Future<bool> verify(
    String token, {
    void Function({required bool status, String? projectId, int duration})?
        onVerifySuccessful,
  }) async {
    if (projectIds.isEmpty) return false;

    final startTime = DateTime.now();

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

      final duration = DateTime.now().difference(startTime).inMilliseconds;
      onVerifySuccessful?.call(
        status: true,
        projectId: firebaseMock.projectID,
        duration: duration,
      );
      return true;
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      onVerifySuccessful?.call(
        status: false,
        duration: duration,
      );
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
    final cacheControl = headers['cache-control'];
    if (cacheControl != null) {
      final maxAgeMatch = _maxAgeRegExp.firstMatch(cacheControl);
      if (maxAgeMatch != null) {
        final maxAge = int.parse(maxAgeMatch.group(1)!);
        return DateTime.now().add(Duration(seconds: maxAge));
      }
    }
    final expires = headers['expires'];
    if (expires != null) {
      return DateTime.parse(expires);
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
