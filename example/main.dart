import 'package:firebase_verify_token_dart/firebase_verify_token_dart.dart';

void main() async {
  // Set your Firebase project IDs
  FirebaseVerifyToken.projectIds = ['cbes-c64d6', 'test-1'];

  // Sample Firebase JWT token
  const token = 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjJiN2JhZmIyZjEwY2FlMmIxZjA3ZjM4MTZjNTQyMmJlY2NhNWMyMjMiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vY2Jlcy1jNjRkNiIsImF1ZCI6ImNiZXMtYzY0ZDYiLCJhdXRoX3RpbWUiOjE3NTQxNDM3ODksInVzZXJfaWQiOiJWU3FSeVp3Q0hjYkc3UHg5d1NGMElaUndwcUIyIiwic3ViIjoiVlNxUnlad0NIY2JHN1B4OXdTRjBJWlJ3cHFCMiIsImlhdCI6MTc1NTI0Nzk4NiwiZXhwIjoxNzU1MjUxNTg2LCJlbWFpbCI6ImJlc2ltc29mdEBvdXRsb29rLml0IiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZW1haWwiOlsiYmVzaW1zb2Z0QG91dGxvb2suaXQiXX0sInNpZ25faW5fcHJvdmlkZXIiOiJwYXNzd29yZCJ9fQ.Hh8uGCfNneDLL_NQncdo2g7c7cHGpDAu9sTY-xfWXQ3EWlaj9Ac5MKnuQJqTycZxyu8R43QvldbDx7-pWxIRwTc9gztvI_52ybUQ7PRX7zwJoPnBrcrXTfBYfavg1AH9ZkfDdvbnGMl1dVJWb580Wg_UfQ-MJK4LmiTNV0WRSYKgv-Olj3XETF1qgCCZZqZUbsliD1pHPPAZ_GH6rAPtgaOo5XwuG_5LSiYzfe1l0AdCxUl4AvRQlV2cfdkdUpWdifunFO-xq2YuiHWxAx-jVpDvbJpxz9re80kGrXn-ZN5e0yWrTPdT3f3DvZ4lC41j4dTBMRcdrl9uEvHq6NvcyQ';

  // Verify the token with callback
  await FirebaseVerifyToken.verify(
    token,
    onVerifySuccessful: (
        {required bool status, String? projectId, int? duration,}) {
      if (status) {
        print('✅ Token verified for project: $projectId ($duration ms)');
      } else {
        print('❌ Token verification failed ($duration ms)');
      }
    },
  );
}
