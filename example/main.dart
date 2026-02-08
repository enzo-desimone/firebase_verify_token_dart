import 'package:firebase_verify_token_dart/firebase_verify_token_dart.dart';

void main() async {
  print('🚀 Starting Firebase Token Verification Example...\n');

  // 1. Set the accepted Firebase Project IDs (Audience)
  // detailed at: https://console.firebase.google.com/
  FirebaseVerifyToken.projectIds = ['my-awesome-project', 'test-env-project'];
  print('📋 Accepted Project IDs: ${FirebaseVerifyToken.projectIds}\n');

  // 2. Sample Firebase JWT token (Fake & Expired for safety)
  // This is a structurally correct but fake token for demonstration.
  const fakeToken =
      'eyJhbGciOiJSUzI1NiIsImtpZCI6ImZha2Vfa2lkXzEyMzQ1IiwidHlwIjoiSldUIn0.'
      'eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vbXktYXdlc29tZS1wcm'
      '9qZWN0IiwiYXVkIjoibXktYXdlc29tZS1wcm9qZWN0IiwiYXV0aF90aW1lIjoxNjIzODQ3'
      'ODMyLCJ1c2VyX2lkIjoiWGs4OTN1MjNIOVNJODkzIiwic3ViIjoiWGs4OTN1MjNIOVNJOD'
      'kzIiwiaWF0IjoxNjIzODQ3ODMyLCJleHAiOjE2MjM4NTE0MzIsImVtYWlsIjoidXNlckBl'
      'eGFtcGxlLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJmaXJlYmFzZSI6eyJpZGVudG'
      'l0aWVzIjp7ImVtYWlsIjpbInVzZXJAZXhhbXBsZS5jb20iXX0sInNpZ25faW5fcHJvdmlk'
      'ZXIiOiJwYXNzd29yZCJ9fQ.'
      'c2lnbmF0dXJlX2NvbnRlbnRfdmFsaWRfbGVuZ3RoXzEyMw';

  print('🔒 Verifying token...');

  // 3. Verify the token using the verify() method
  final isValid = await FirebaseVerifyToken.verify(
    fakeToken,
    onVerifyCompleted: ({
      required bool status,
      String? projectId,
      int duration = 0,
    }) {
      print(status);

      if (status) {
        print(
          '✅ SUCCESS: Token is valid!\n'
          '   - Project ID: $projectId\n'
          '   - Duration: ${duration}ms',
        );
      } else {
        print(
          '❌ FAILURE: Token is invalid or expired.\n'
          '   - Check if the token is formatted correctly.\n'
          '   - Ensure it is not expired.\n'
          '   - Duration: ${duration}ms',
        );
      }
    },
  );

  // 4. Extract claims without verification (Optional)
  if (!isValid) {
    print('\n⚠️  Note: Even if invalid, we can decode unverified claims:');
    try {
      final uid = FirebaseVerifyToken.getUserID(fakeToken);
      final projectId = FirebaseVerifyToken.getProjectID(fakeToken);
      print('   - Unverified UID: $uid');
      print('   - Unverified Project ID: $projectId');
    } catch (e) {
      print('   - Could not parse token: $e');
    }
  }

  print('\n🏁 Example finished.');
}
