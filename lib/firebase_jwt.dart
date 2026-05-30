import 'dart:convert';

/// Utility helpers for decoding Firebase JWT segments.
class FirebaseJWT {
  /// Decodes the header portion of a Firebase JWT token.
  ///
  /// Returns a map containing the header claims.
  ///
  /// Throws an [Exception] if [token] is malformed or cannot be decoded.
  static Map<String, dynamic> parseJwtHeader(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final headerJson = _decodeBase64(parts[0]);
    final headerMap = json.decode(headerJson);
    if (headerMap is! Map<String, dynamic>) {
      throw Exception('invalid header');
    }

    return headerMap;
  }

  static String _decodeBase64(String str) {
    var output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
      case 3:
        output += '=';
      default:
        throw Exception('Illegal base64url string!');
    }

    return utf8.decode(base64.decode(output));
  }
}
