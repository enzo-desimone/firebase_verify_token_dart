import 'dart:convert';

/// Utilities for decoding segments of Firebase JWT tokens.
class FirebaseJWT {
  /// Parses the header segment of a Firebase JWT [token] and returns its values.
  ///
  /// Throws an [Exception] if the token does not have exactly three parts or if
  /// the decoded header cannot be represented as a [Map] of string keys. Throws
  /// a [FormatException] if the header segment is not valid Base64URL.
  static Map<String, dynamic> parseJwtHeader(String token) {
    final firstDot = token.indexOf('.');
    final secondDot = token.indexOf('.', firstDot + 1);
    if (firstDot == -1 ||
        secondDot == -1 ||
        token.indexOf('.', secondDot + 1) != -1) {
      throw Exception('invalid token');
    }

    final decoded = _decodeBase64(token.substring(0, firstDot));
    final headerMap = json.decode(decoded);
    if (headerMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return headerMap;
  }

  /// Decodes a Base64URL-encoded [str] into a UTF-8 string.
  ///
  /// Throws a [FormatException] if [str] is not properly Base64URL encoded.
  static String _decodeBase64(String str) {
    final normalized = base64Url.normalize(str);
    return utf8.decode(base64Url.decode(normalized));
  }
}
