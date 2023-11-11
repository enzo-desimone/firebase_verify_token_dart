import 'package:firebase_verify_token_dart/firebase_verify_token_dart.dart';

void main() async {
  FirebaseVerifyToken.projectId = '';

  final result = await FirebaseVerifyToken.verify('token');

  if (result) {
    print('TOKEN IS VERIFIED');
  } else {
    print('TOKEN IS NOT VERIFIED');
  }
}
