import 'package:firebase_verify_token_dart/firebase_verify_token_dart.dart';

void main() async {
  FirebaseVerifyToken.projectIds = ['cbes-c64d6', 'test-1'];

  await FirebaseVerifyToken.verify(
    'token',
    onVerifySuccessful: ({required bool status, String? projectId}) {
      if (status) {
        print('Token verified for project: $projectId');
      } else {
        print('Token verification failed');
      }
    },
  );
}
