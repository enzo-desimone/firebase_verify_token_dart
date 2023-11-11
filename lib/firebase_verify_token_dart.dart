import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:jose_plus/jose.dart';
import 'package:ntp/ntp.dart';

import 'firebase_token.dart';

/// This class contains methods to verify a firebase token. Remember to initialize the projectId variable before proceeding to the verify method
class FirebaseVerifyToken {
  /// Your firebase project ID
  static late String projectId;

  /// Verify a firebase jwt token, is return true if is verified otherwise false
  static Future<bool> verify(String token) async {
    try {
      final keys = await _fetchPublicKeys();
      final jwt = JsonWebToken.unverified(token);
      final kid = FirebaseJWT.parseJwtHeader(token)['kid'] as String?;

      if (kid == null) {
        return false;
      }

      final publicKey = JsonWebKey.fromPem(keys[kid]!, keyId: kid);

      final keyStore = JsonWebKeyStore()
        ..addKey(JsonWebKey.fromJson(publicKey.toJson()));

      final isSignatureValid = await jwt.verify(keyStore);

      if (!isSignatureValid) {
        return false;
      }

      final now = (await NTP.now()).toUtc();

      if (jwt.claims['aud'] != projectId) {
        return false;
      }
      if (jwt.claims['exp'] == null ||
          DateTime.fromMillisecondsSinceEpoch(
            (jwt.claims['exp'] as int) * 1000,
            isUtc: true,
          ).isBefore(now)) {
        return false;
      }

      if (jwt.claims['iat'] == null) {
        return false;
      }

      if (!DateTime.fromMillisecondsSinceEpoch(
        (jwt.claims['iat'] as int) * 1000,
        isUtc: true,
      ).isAtSameMomentAs(now)) {
        if (DateTime.fromMillisecondsSinceEpoch(
          (jwt.claims['iat'] as int) * 1000,
          isUtc: true,
        ).isAfter(now)) {
          return false;
        }
      }

      if (jwt.claims['iss'] != 'https://securetoken.google.com/$projectId') {
        return false;
      }
      if (jwt.claims['sub'] == null || (jwt.claims['sub'] as String).isEmpty) {
        return false;
      }
      if (jwt.claims['auth_time'] == null) {
        return false;
      }

      if (!DateTime.fromMillisecondsSinceEpoch(
        (jwt.claims['auth_time'] as int) * 1000,
        isUtc: true,
      ).isAtSameMomentAs(now)) {
        if (DateTime.fromMillisecondsSinceEpoch(
          (jwt.claims['auth_time'] as int) * 1000,
          isUtc: true,
        ).isAfter(now)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      log('Error verify token: ($e)');
      return false;
    }
  }

  /// This method it is used to know the user firebase uid starting from the jwt token
  static String getIdByToken(String token) {
    final jwt = JsonWebToken.unverified(token);
    return jwt.claims['user_id'] as String;
  }

  static Future<Map<String, String>> _fetchPublicKeys() async {
    final response = await http.get(
      Uri.parse(
        'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com',
      ),
    );
    if (response.statusCode == 200) {
      return Map<String, String>.from(json.decode(response.body) as Map);
    } else {
      throw Exception('Failed to load public keys');
    }
  }
}
