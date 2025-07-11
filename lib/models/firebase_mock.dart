import 'dart:developer';

import 'package:firebase_verify_token_dart/models/models.dart';

/// A class that represents and validates claims extracted from a Firebase JWT token.
class FirebaseMock {
  /// Constructs a [FirebaseMock] with the decoded JWT header and payload values.
  FirebaseMock({
    required this.alg,
    required this.kid,
    required this.aud,
    required this.exp,
    required this.iat,
    required this.authTime,
    required this.iss,
    required this.sub,
  });

  /// The algorithm used to sign the token (should be RS256).
  final String alg;

  /// The key ID used to match the correct public key for signature verification.
  final String kid;

  /// The audience claim, usually the Firebase project ID.
  final String aud;

  /// The expiration time (`exp` claim) of the token.
  final int exp;

  /// The issued-at time (`iat` claim) of the token.
  final int iat;

  /// The authentication time (`auth_time` claim) of the token.
  final int authTime;

  /// The issuer claim (`iss`), should match the Firebase issuer URL.
  final String iss;

  /// The subject claim (`sub`), represents the user's UID.
  final String sub;

  /// The expected algorithm for Firebase tokens.
  static const String defaultAlg = 'RS256';

  /// Creates a [FirebaseMock] from the token header and payload maps.
  static FirebaseMock fromValue(
    Map<String, dynamic> headers,
    Map<String, dynamic> payload,
  ) {
    return FirebaseMock(
      alg: headers['alg'] as String,
      kid: headers['kid'] as String,
      aud: payload['aud'] as String,
      exp: payload['exp'] as int,
      iat: payload['iat'] as int,
      authTime: payload['auth_time'] as int,
      iss: payload['iss'] as String,
      sub: payload['sub'] as String,
    );
  }

  /// Validates the algorithm used in the token.
  bool get validateAlg => alg == defaultAlg;

  /// Checks whether the token's `kid` is present in the list of known public keys.
  bool validateKeysByKid(List<String> keys) {
    return keys.contains(kid);
  }

  /// Validates that the `aud` claim matches one of the provided Firebase project IDs.
  bool validateProjectID(List<String> projectIds) => projectIds.contains(aud);

  /// Validates `exp`, `iat`, and `auth_time` claims using the current accurate
  /// time. The `exp` claim must be in the future, while `iat` and `auth_time`
  /// must be in the past.
  Future<bool> get validateExpIatAuthTime async {
    final now = await AccurateTime.now();

    final validateExp = _isClaimDateValid(exp, now);
    final validateIat = _isClaimDateValid(iat, now);
    final validateAuthTime = _isClaimDateValid(authTime, now, mustBePast: true);

    if (!validateExp) log('Token expired');
    if (!validateIat) log('Token issued in the future');
    if (!validateAuthTime) log('Token issued before authentication');

    return validateExp && validateIat && validateAuthTime;
  }

  /// Validates that the issuer matches the expected Firebase URL format.
  bool get validateIss => iss == 'https://securetoken.google.com/$aud';

  /// Validates that the subject claim (`sub`) is not empty.
  bool get validateSub => sub.isNotEmpty;

  /// Returns the project ID from the `aud` claim.
  String get projectID => aud;

  /// Internal method to check if a claim's timestamp is valid.
  static bool _isClaimDateValid(
    dynamic claim,
    DateTime now, {

        bool mustBePast = false,
  }) {
    if (claim == null) return false;
    final claimDate =
        DateTime.fromMillisecondsSinceEpoch((claim as int) * 1000, isUtc: true);
    return mustBePast ? claimDate.isBefore(now) : claimDate.isAfter(now);
  }

  @override
  String toString() {
    return 'FirebaseMock('
        'alg: $alg, '
        'kid: $kid, '
        'aud: $aud, '
        'exp: $exp, '
        'iat: $iat, '
        'authTime: $authTime, '
        'iss: $iss, '
        'sub: $sub'
        ')';
  }
}
