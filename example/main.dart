import 'package:firebase_verify_token_dart/firebase_verify_token_dart.dart';

void main() async {
  // Set your Firebase project IDs
  FirebaseVerifyToken.projectIds = ['cbes-c64d6', 'test-1'];

  // Sample Firebase JWT token
  const token = 'eyJhbGciOiJSUzI1NiIsImtpZCI6ImE4Z...'; // shortened for clarity

  // Verify the token with callback
  await FirebaseVerifyToken.verify(
    token,
    onVerifySuccessful: (
        {required bool status, String? projectId, int? duration}) {
      if (status) {
        print('✅ Token verified for project: $projectId (${duration} ms)');
      } else {
        print('❌ Token verification failed (${duration} ms)');
      }
    },
  );
}
