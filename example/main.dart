import 'package:firebase_verify_token_dart/firebase_verify_token_dart.dart';

void main() async {
  FirebaseVerifyToken.projectIds = ['cbes-c64d6', 'test-1'];
  await FirebaseVerifyToken.verify(
    'eyJhbGciOiJSUzI1NiIsImtpZCI6ImE4ZGY2MmQzYTBhNDRlM2RmY2RjYWZjNmRhMTM4Mzc3NDU5ZjliMDEiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vY2Jlcy1jNjRkNiIsImF1ZCI6ImNiZXMtYzY0ZDYiLCJhdXRoX3RpbWUiOjE3NTI3NjcyODEsInVzZXJfaWQiOiIwWU4ybm5BakhLUU9xaHVRdWw5YjJWUlFYaUIzIiwic3ViIjoiMFlOMm5uQWpIS1FPcWh1UXVsOWIyVlJRWGlCMyIsImlhdCI6MTc1Mjc4MTQ4MiwiZXhwIjoxNzUyNzg1MDgyLCJlbWFpbCI6ImluZm9Ac2NvdHRvbGFiLml0IiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7ImVtYWlsIjpbImluZm9Ac2NvdHRvbGFiLml0Il19LCJzaWduX2luX3Byb3ZpZGVyIjoicGFzc3dvcmQifX0.SxibjUIi97bxjetCjgxVavar4-QqXak3oqoXrj4iQoMDph9jJj_glGzfKo2sVemf_7tO8Go6Yi8vl4v0DDe07Oi8gys1nSXtXFIGxGuTrm1UU_eCzHFr6fL_hISV0tCPZr4ZPActOd8m89ISFgkpcOXxsL-JawerWXKd3PLip8AadTnBNXTUg_eWI99ivOAuT914IbKnOJlzV4gpv-v1zyUHiriKQLrFAZsBn7aC1GDOmPAkjN1gbQ2sSIwp3skdu5dK68MoKQ2B5IssLBlW0PZ-4EBbqXLE6BANgBFvdRpNU5Ml03bM99pM_bTgGf1ztoHaOIMlST7hsCrA--ZXFQ',
    onVerifySuccessful: (
        {required bool status, String? projectId, int? duration}) {
      if (status) {
        print('Token verified for project: $projectId (${duration} ms)');
      } else {
        print('Token verification failed (${duration} ms)');
      }
    },
  );
}
