import 'package:firebase_verify_token_dart/firebase_jwt.dart';
import 'package:firebase_verify_token_dart/firebase_verify_token_dart.dart';
import 'package:firebase_verify_token_dart/models/firebase_mock.dart';
import 'package:test/test.dart';

void main() {
  group('FirebaseJWT Tests', () {
    test('parseJwtHeader decodes valid JWT header', () {
      // Header: {"alg":"RS256","kid":"key123"}
      const headerStr = 'eyJhbGciOiJSUzI1NiIsImtpZCI6ImtleTEyMyJ9';
      const token = '$headerStr.payload.signature';

      final header = FirebaseJWT.parseJwtHeader(token);
      expect(header['alg'], 'RS256');
      expect(header['kid'], 'key123');
    });

    test('parseJwtHeader throws on invalid token format', () {
      expect(
        () => FirebaseJWT.parseJwtHeader('invalidTokenNoDots'),
        throwsException,
      );
    });
  });

  group('FirebaseMock Tests', () {
    test('fromValue parses safely with missing keys', () {
      final mock = FirebaseMock.fromValue(const {}, const {});
      expect(mock.alg, '');
      expect(mock.kid, '');
      expect(mock.aud, '');
      expect(mock.exp, 0);
      expect(mock.iat, 0);
      expect(mock.authTime, 0);
      expect(mock.iss, '');
      expect(mock.sub, '');
    });

    test('fromValue parses values correctly', () {
      final mock = FirebaseMock.fromValue(
        const {'alg': 'RS256', 'kid': 'kid1'},
        const {
          'aud': 'my-proj',
          'exp': 2000,
          'iat': 1000,
          'auth_time': 900,
          'iss': 'https://securetoken.google.com/my-proj',
          'sub': 'user123',
        },
      );
      expect(mock.alg, 'RS256');
      expect(mock.kid, 'kid1');
      expect(mock.aud, 'my-proj');
      expect(mock.exp, 2000);
      expect(mock.iat, 1000);
      expect(mock.authTime, 900);
      expect(mock.iss, 'https://securetoken.google.com/my-proj');
      expect(mock.sub, 'user123');
    });

    test('validateAlg validates RS256 algorithm', () {
      final mockTrue = FirebaseMock(
        alg: 'RS256',
        kid: '',
        aud: '',
        exp: 0,
        iat: 0,
        authTime: 0,
        iss: '',
        sub: '',
      );
      final mockFalse = FirebaseMock(
        alg: 'HS256',
        kid: '',
        aud: '',
        exp: 0,
        iat: 0,
        authTime: 0,
        iss: '',
        sub: '',
      );

      expect(mockTrue.validateAlg, isTrue);
      expect(mockFalse.validateAlg, isFalse);
    });

    test('validateClaimsTime verifies exp, iat, and authTime with clock skew',
        () {
      // Current UTC time: 1000 seconds since epoch
      final now = DateTime.fromMillisecondsSinceEpoch(1000 * 1000, isUtc: true);

      // Token claims:
      // exp is 1200 (future)
      // iat is 800 (past)
      // authTime is 700 (past)
      final mockValid = FirebaseMock(
        alg: '',
        kid: '',
        aud: '',
        exp: 1200,
        iat: 800,
        authTime: 700,
        iss: '',
        sub: '',
      );

      expect(mockValid.validateClaimsTime(now), isTrue);

      // Token has expired (exp = 900, which is in the past)
      // iat and authTime are in the past
      final mockExpired = FirebaseMock(
        alg: '',
        kid: '',
        aud: '',
        exp: 900,
        iat: 800,
        authTime: 700,
        iss: '',
        sub: '',
      );

      // Without clockSkew leeway or when clockSkew is too small (e.g. 30 sec)
      expect(
        mockExpired.validateClaimsTime(
          now,
          clockSkew: const Duration(seconds: 30),
        ),
        isFalse,
      );

      // With enough clockSkew leeway (e.g. 3 minutes / 180 seconds,
      // so exp 900 + 180 = 1080 > 1000)
      expect(
        mockExpired.validateClaimsTime(
          now,
          clockSkew: const Duration(minutes: 3),
        ),
        isTrue,
      );

      // Token is issued in the future (iat = 1100, which is in the future)
      final mockFutureIat = FirebaseMock(
        alg: '',
        kid: '',
        aud: '',
        exp: 2000,
        iat: 1100,
        authTime: 700,
        iss: '',
        sub: '',
      );

      // Without leeway:
      expect(
        mockFutureIat.validateClaimsTime(
          now,
          clockSkew: Duration.zero,
        ),
        isFalse,
      );

      // With leeway (clockSkew = 3 minutes / 180 seconds):
      expect(
        mockFutureIat.validateClaimsTime(
          now,
          clockSkew: const Duration(minutes: 3),
        ),
        isTrue,
      );
    });
  });

  group('FirebaseVerifyToken Parameter Tests', () {
    test('verify can be called with useNtp = false', () async {
      FirebaseVerifyToken.projectIds = ['some-project'];
      // A structurally invalid token to check that it fails fast and gracefully
      final result = await FirebaseVerifyToken.verify(
        'invalid.token.here',
        useNtp: false,
      );
      expect(result, isFalse);
    });
  });
}
