import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:firebase_verify_token_dart/firebase_jwt.dart';

class ParseJwtHeaderBenchmark extends BenchmarkBase {
  ParseJwtHeaderBenchmark() : super('ParseJwtHeader');

  // Example token with dummy header and payload segments.
  static const _token =
      'eyJhbGciOiJSUzI1NiIsImtpZCI6Ijg5NzY1NCJ9.eyJhdWQiOiJwcm9qZWN0SWQiLCJleHAiOjE2MDAwMDAwMDB9.signature';

  @override
  void run() {
    FirebaseJWT.parseJwtHeader(_token);
  }
}

void main() {
  ParseJwtHeaderBenchmark().report();
}
