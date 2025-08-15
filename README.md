# Firebase Verify Token

<p align="left">
  <img src="https://raw.githubusercontent.com/enzo-desimone/firebase_verify_token_dart/master/firebase_verify_token_dart.png" alt="NTP Dart" width="50%" />
</p>

A Dart/Flutter plugin to **verify Firebase JWT tokens**, supporting multiple Firebase projects across any platform.

[![Pub Version](https://img.shields.io/pub/v/firebase_verify_token_dart?style=flat-square&logo=dart)](https://pub.dev/packages/firebase_verify_token_dart)
![Pub Likes](https://img.shields.io/pub/likes/firebase_verify_token_dart)
![Pub Points](https://img.shields.io/pub/points/firebase_verify_token_dart)
![GitHub license](https://img.shields.io/github/license/enzo-desimone/firebase_verify_token_dart?style=flat-square)

---

## 📱 Supported Platforms

| Android | iOS | macOS | Web | Linux | Windows |
|:-------:|:---:|:-----:|:---:|:-----:|:-------:|
|   ✔️    | ✔️   |  ✔️   | ✔️   |  ✔️   |   ✔️    |

---

## 🔍 Overview

`firebase_verify_token_dart` verifies **Firebase JWT tokens** entirely in Dart without relying on backend services. It performs:

- ✅ **Project ID validation** against a whitelist
- ✅ **Issuer check** to ensure token is from Firebase
- ✅ **Expiration check**
- ✅ **JWT structure validation**

---

## ⚙️ Installation

Add the dependency:

```yaml
dependencies:
  firebase_verify_token_dart: ^latest
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Quick Start

### 1. Import the package

```dart
import 'package:firebase_verify_token/firebase_verify_token.dart';
```

### 2. Initialize with your Firebase project IDs

```dart
FirebaseVerifyToken.projectIds = [
  'project-id-1',
  'project-id-2',
];
```

---

## 🔐 Token Verification

### ✅ Basic Verification

```dart
final isValid = await FirebaseVerifyToken.verify('your-firebase-jwt-token');

if (isValid) {
  // Token is valid
}
```

### 🧠 With Callback (for project ID and duration)

```dart
await FirebaseVerifyToken.verify(
  'your-firebase-jwt-token',
  onVerifySuccessful: ({required bool status, String? projectId, int? duration}) {
    if (status) {
      print('Valid token for project: $projectId in ${duration}ms');
    } else {
      print('Invalid token (checked in ${duration}ms)');
    }
  },
);
```

---

## 📘 API Reference

| Method | Description |
|--------|-------------|
| `Future<bool> FirebaseVerifyToken.verify(String token, { void Function({required bool status, String? projectId, int? duration})? onVerifySuccessful })` | Verifies the JWT token and optionally provides project ID and verification duration. |
| `String FirebaseVerifyToken.getUserID(String token)` | Extracts the user ID (`sub` claim) from a JWT without verifying it. |
| `String? FirebaseVerifyToken.getProjectID(String token)` | Extracts the Firebase project ID (`aud` claim) from a JWT without verifying it. |

---


## 🔄 Complete Example

```dart
import 'package:firebase_verify_token/firebase_verify_token.dart';

void main() async {
  // Set your Firebase project IDs
  FirebaseVerifyToken.projectIds = ['cbes-c64d6', 'test-1'];

  // Sample Firebase JWT token
  const token = 'eyJhbGciOiJSUzI1NiIsImtpZCI6ImE4Z...'; // shortened for clarity

  // Verify the token with callback
  await FirebaseVerifyToken.verify(
    token,
    onVerifySuccessful: ({
      required bool status,
      String? projectId,
      required int duration,
    }) {
      if (status) {
        print('✅ Token verified for project: \$projectId (\$duration ms)');
      } else {
        print('❌ Token verification failed (\$duration ms)');
      }
    },
  );
}
```


## 💡 Common Use Cases

- 🔐 **Cross-project auth**: Accept users from multiple Firebase projects
- 🔑 **Secure APIs**: Verify Firebase tokens server-side or client-side
- 🌐 **Multi-app integration**: Authenticate users across a shared ecosystem

---

## 🤝 Contributing

Issues and pull requests are welcome!  
→ [Open an issue](https://github.com/enzo-desimone/firebase_verify_token_dart/issues)  
→ [Submit a PR](https://github.com/enzo-desimone/firebase_verify_token_dart/pulls)

---

## 📃 License

MIT — See [LICENSE](https://github.com/enzo-desimone/firebase_verify_token_dart/blob/master/LICENSE)
