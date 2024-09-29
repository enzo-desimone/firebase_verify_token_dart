import 'package:firebase_verify_token_dart/firebase_verify_token_dart.dart';

void main() async {
  FirebaseVerifyToken.projectIds = ['test', 'test-1'];

  final result = await FirebaseVerifyToken.verify(
    'token',
    onVerifySuccessful: ({required bool status, String? projectId}) {
      print('STATUS: $status');
      print('PROJECT ID: $projectId');
    },
  );
  await FirebaseVerifyToken.verify(
    'my-token-string',
    onVerifySuccessful: ({required bool status, String? projectId}) {
      if (status) {
        print('Token verified for project: $projectId');
      } else {
        print('Token verification failed');
      }
    },
  );
  if (result) {
    print('TOKEN IS VERIFIED');
  } else {
    print('TOKEN IS NOT VERIFIED');
  }
}
