import 'dart:convert';
import 'dart:developer';

import 'package:firebase_verify_token_dart/firebase_jwt.dart';
import 'package:firebase_verify_token_dart/models/firebase_mock.dart';
import 'package:http/http.dart' as http;
import 'package:jose_plus/jose.dart';
import 'package:ntp_dart/ntp_dart.dart';

/// This class handles the verification of Firebase JWT tokens,
/// including caching and retrieval of Google's public keys
/// for signature validation.
class FirebaseVerifyToken {
  /// List of accepted Firebase project IDs used to validate
  /// the `aud` claim of the token.
  static List<String> projectIds = <String>[];

  /// Cached public keys used for verifying the token's signature.
  static Map<String, String>? _cachedKeys;

  /// Expiration timestamp for the cached public keys.
  static DateTime? _cacheExpiration;

  /// URL to retrieve Google's public keys used for Firebase token verification.
  static const String _googleUrlKeys =
      'https://www.googleapis.com/robot/v1/metadata/x509/'
      'securetoken@system.gserviceaccount.com';

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
  /// 4. Expiration (`exp`), "issued at" (`iat`), and auth time (`auth_time`).
  /// 5. Issuer (`iss`) and subject (`sub`) claims.
  ///
  /// If an optional [onVerifyCompleted] callback is provided, it will be
  /// called at the end of the process with:
  /// - `status`: `true` if verification succeeded, `false` otherwise.
  /// - `projectId`: the matching Firebase project ID (only on success).
  /// - `duration`: the time taken (in milliseconds) for the verification.
  ///
  /// Throws no exceptions; failures return `false` and invoke the callback.
  static Future<bool> verify(
    String token, {
    List<String>? projectIds,
    Duration clockSkew = const Duration(minutes: 5),
    bool useNtp = true,
    void Function({required bool status, String? projectId, int duration})?
        onVerifyCompleted,
  }) async {
    final startTime = DateTime.now();
    var isVerified = false;
    String? projectId;

    try {
      final activeProjectIds = projectIds ?? FirebaseVerifyToken.projectIds;
      if (activeProjectIds.isEmpty) {
        throw Exception('Project IDs list is empty');
      }

      final publicKeys = await _fetchPublicKeys();
      final jwt = JsonWebToken.unverified(token);
      final header = FirebaseJWT.parseJwtHeader(token);

      final firebaseMock = FirebaseMock.fromValue(header, jwt.claims.toJson());
      projectId = firebaseMock.projectID;

      if (!publicKeys.containsKey(firebaseMock.kid)) {
        throw Exception('Public key not found for KID: ${firebaseMock.kid}');
      }

      if (!firebaseMock.validateAlg) {
        throw Exception(
          'Token uses an unsupported algorithm: ${firebaseMock.alg}',
        );
      }

      if (!firebaseMock.validateKeysByKid(publicKeys.keys.toList())) {
        throw Exception('KID not found in public keys');
      }

      final publicKey = JsonWebKey.fromPem(
        publicKeys[firebaseMock.kid]!,
        keyId: firebaseMock.kid,
      );
      final keyStore = JsonWebKeyStore()..addKey(publicKey);

      if (!await jwt.verify(keyStore)) {
        throw Exception('JWT signature verification failed');
      }

      if (!firebaseMock.validateProjectID(activeProjectIds)) {
        throw Exception(
          'Token audience mismatch. Expected one of: $activeProjectIds, '
          'but got: ${firebaseMock.aud}',
        );
      }

      // Retrieve time based on useNtp setting with try-catch fallback
      DateTime now;
      if (useNtp) {
        try {
          now = await AccurateTime.now(isUtc: true);
        } catch (e) {
          log('NTP synchronization failed, falling back to system clock: $e');
          now = DateTime.now().toUtc();
        }
      } else {
        now = DateTime.now().toUtc();
      }

      if (!firebaseMock.validateClaimsTime(now, clockSkew: clockSkew)) {
        throw Exception('Token expired or time validation failed');
      }

      if (!firebaseMock.validateIss) {
        throw Exception('Token issuer mismatch');
      }

      if (!firebaseMock.validateSub) {
        throw Exception('Token subject (sub) is empty');
      }

      isVerified = true;
      return true;
    } catch (e) {
      log('Error verifying token: ($e)');
      return false;
    } finally {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      onVerifyCompleted?.call(
        status: isVerified,
        projectId: projectId,
        duration: duration,
      );
    }
  }

  /// Retrieves and caches Google's public keys for Firebase token validation.
  ///
  /// If cached keys are still valid (based on HTTP headers),
  /// they are returned directly.
  static Future<Map<String, String>> _fetchPublicKeys() async {
    if (_cachedKeys != null &&
        _cacheExpiration != null &&
        DateTime.now().isBefore(_cacheExpiration!)) {
      return _cachedKeys!;
    }

    final response = await http.get(Uri.parse(_googleUrlKeys));

    if (response.statusCode == 200) {
      _cachedKeys = Map<String, String>.from(
        json.decode(response.body) as Map,
      );
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
    String? cacheControl;
    String? expires;

    for (final entry in headers.entries) {
      final key = entry.key.toLowerCase();
      if (key == 'cache-control') {
        cacheControl = entry.value;
      } else if (key == 'expires') {
        expires = entry.value;
      }
    }

    if (cacheControl != null) {
      final maxAgeMatch = _maxAgeRegExp.firstMatch(cacheControl);
      if (maxAgeMatch != null) {
        final maxAge = int.parse(maxAgeMatch.group(1)!);
        return DateTime.now().add(Duration(seconds: maxAge));
      }
    }
    if (expires != null) {
      return DateTime.parse(expires);
    }
    return DateTime.now().add(const Duration(minutes: 10));
  }

  /// Extracts the user ID (`sub` claim) from a Firebase JWT
  /// without verifying the token.
  ///
  /// Useful for quickly retrieving the authenticated user's UID.
  static String getUserID(String token) {
    final jwt = JsonWebToken.unverified(token);
    return jwt.claims['sub'] as String;
  }

  /// Extracts the Firebase project ID (`aud` claim) from a JWT
  /// without verifying the token.
  ///
  /// Returns `null` if the claim is missing.
  static String? getProjectID(String token) {
    final jwt = JsonWebToken.unverified(token);
    return jwt.claims['aud'] as String?;
  }
}
