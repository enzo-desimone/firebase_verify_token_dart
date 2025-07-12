import 'package:firebase_verify_token_dart/firebase_verify_token_dart.dart';

void main() async {
  FirebaseVerifyToken.projectIds = ['cbes-c64d6', 'test-1'];

  await FirebaseVerifyToken.verify(
    'eyJhbGciOiJSUzI1NiIsImtpZCI6IjQ3YWU0OWM0YzlkM2ViODVhNTI1NDA3MmMzMGQyZThlNzY2MWVmZTEiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vY2Jlcy1jNjRkNiIsImF1ZCI6ImNiZXMtYzY0ZDYiLCJhdXRoX3RpbWUiOjE3NTIzMjcwMDQsInVzZXJfaWQiOiJWU3FSeVp3Q0hjYkc3UHg5d1NGMElaUndwcUIyIiwic3ViIjoiVlNxUnlad0NIY2JHN1B4OXdTRjBJWlJ3cHFCMiIsImlhdCI6MTc1MjMyNzAwNCwiZXhwIjoxNzUyMzMwNjA0LCJlbWFpbCI6ImJlc2ltc29mdEBvdXRsb29rLml0IiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZW1haWwiOlsiYmVzaW1zb2Z0QG91dGxvb2suaXQiXX0sInNpZ25faW5fcHJvdmlkZXIiOiJwYXNzd29yZCJ9fQ.u-SHph_82PZnSJDpA6LT1ZJuPYVhJvCKhzhWiThJHFzQ6f5dlEEoPbRBbfqfRPu94W-ULQR6DF2H88RSOMlZpgbTlOcVUX1yZOWpn2jyLX4frGpnmanRmtfyZpJukvqz9X8iadlk0f1NQ84x3_pzD7p-trp11OGcFn_XD_pVQREETIUCe-xP8FFXBiFMA_wdlLIqEkCBzdmVoGUxCjyMKS1EikWriX_gONOE1T0n3_-ht0G0qF6HLZf9tOKZh1IekTutwi26lIYpKThO0B39Tk3eMzbyGCe0FtPQ9pbd9aeBOhdjvA2oI-4g09RTAQcHCJNTmJsmi4Zb4Rg87mXg0Q',
    onVerifySuccessful: ({required bool status, String? projectId}) {
      if (status) {
        print('Token verified for project: $projectId');
      } else {
        print('Token verification failed');
      }
    },
  );
}
