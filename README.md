# Firebase Verify Token

<p align="center">
  <img src="https://raw.githubusercontent.com/enzo-desimone/firebase_verify_token_dart/master/example/firebase_verify_token_dart.webp" alt="Firebase Verify Token" width="400" style="border-radius: 20px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);" style="border-radius: 10px;" />
</p>

<p align="center">
  <b>Secure, lightweight, and pure Dart solution for verifying Firebase JWT tokens.</b>
  <br>
  No backend required. Supports multi-project validation.
</p>

<p align="center">
  <a href="https://pub.dev/packages/firebase_verify_token_dart">
    <img src="https://img.shields.io/pub/v/firebase_verify_token_dart?style=flat-square&logo=dart&color=blue" alt="Pub Version" />
  </a>
  <a href="https://pub.dev/packages/firebase_verify_token_dart/score">
    <img src="https://img.shields.io/pub/points/firebase_verify_token_dart?style=flat-square&logo=dart" alt="Pub Points" />
  </a>
  <a href="https://pub.dev/packages/firebase_verify_token_dart">
    <img src="https://img.shields.io/pub/likes/firebase_verify_token_dart?style=flat-square&logo=dart" alt="Pub Likes" />
  </a>
  <a href="https://github.com/enzo-desimone/firebase_verify_token_dart/blob/master/LICENSE">
    <img src="https://img.shields.io/github/license/enzo-desimone/firebase_verify_token_dart?style=flat-square&color=purple" alt="License" />
  </a>
</p>

---

## ✨ Features

- 🛡️ **Pure Dart**: Verify tokens without exposing your private keys or using the Firebase Admin SDK.
- 🌍 **Multi-Platform**: Works on **Android**, **iOS**, **Web**, **macOS**, **Windows**, and **Linux**.
- ⏱️ **Accurate Timing**: Uses NTP synchronization to prevent issues with device clock drift.
- ⚡ **High Performance**: Caches Google's public keys for faster verification.
- 🔐 **Secure Validation**:
  - Checks **Signature** (RSA SHA-256)
  - Validates **Expiration** (`exp`), **Issued At** (`iat`), and **Auth Time** (`auth_time`).
  - Verifies **Audience** (`aud` / Project ID) and **Issuer** (`iss`).

---

## 🚀 Getting Started

### 1. Install via `pubspec.yaml`
```yaml
dependencies:
  firebase_verify_token_dart: ^2.3.0
```

### 2. Import the Package
```dart
import 'package:firebase_verify_token_dart/firebase_verify_token_dart.dart';
```

---

## 📖 Usage

### Initialize
Set the allowed Firebase Project IDs (Audience) before verifying tokens. This is usually done in your `main()` or initialization logic.

```dart
void main() {
  FirebaseVerifyToken.projectIds = ['my-firebase-project-id'];
}
```

### Verify a Token
Verify a raw JWT token string. This method is asynchronous and returns a `bool`.

```dart
final isValid = await FirebaseVerifyToken.verify(token);

if (isValid) {
  print("✅ Token is valid!");
} else {
  print("❌ Invalid token.");
}
```

### Get Verification Details
Pass an optional callback to get detailed results, including the matched project ID and verification duration.

```dart
final isValid = await FirebaseVerifyToken.verify(
  token,
  onVerifyCompleted: ({required bool status, String? projectId, int? duration}) {
    if (status) {
      print("✅ Verified for project '$projectId' inside ${duration}ms");
    } else {
      print("❌ Verification failed.");
    }
  },
);
```

### ⚙️ Advanced Configuration (Thread-Safe & Offline-Ready)

You can pass advanced arguments directly to the `verify` method. This is perfect for high-performance backends, offline development, or multi-tenant (multi-project) systems:

```dart
final isValid = await FirebaseVerifyToken.verify(
  token,
  // 1. Thread-safe project overriding (avoid race conditions in multi-tenant backends)
  projectIds: ['my-awesome-project', 'another-tenant-project'],

  // 2. Custom clock skew leeway (default is 5 minutes)
  clockSkew: const Duration(minutes: 2),

  // 3. High-performance / offline mode (defaults to true)
  // Set to 'false' to bypass all NTP network checks and use the system clock.
  // This executes validation locally and synchronously in under 1ms!
  useNtp: false,

  onVerifyCompleted: ({required bool status, String? projectId, int? duration}) {
    print("Verification completed in ${duration}ms.");
  },
);
```

#### NTP Failover (Always Reliable)
If `useNtp` is set to `true` (the default), the package will synchronize time using a precise network clock. However, if the server is offline or UDP port 123 is blocked by a restrictive firewall, the package **automatically and gracefully falls back to the system clock** rather than breaking your authentication flow.

### Extract Claims (Without Verification)
Sometimes you just need to read the token's content (e.g., User ID) without a full cryptographic check.

```dart
// Get User ID (sub)
final uid = FirebaseVerifyToken.getUserID(token);

// Get Project ID (aud)
final projectId = FirebaseVerifyToken.getProjectID(token);
```

---

## 🛠️ Advanced

**Why use this over the Firebase Admin SDK?**
The Firebase Admin SDK requires a service account with elevated privileges, which is dangerous to use in client-side applications. This package purely verifies the token's signature using Google's public keys, making it safe for client-side use or lightweight server-side Dart applications (e.g., Dart Frog, Shelf).

---

## 🤝 Contributing

We welcome contributions!
- 🐛 **Report Issues**: Submit bugs or feature requests on [GitHub Issues](https://github.com/enzo-desimone/firebase_verify_token_dart/issues).
- 💡 **Submit PRs**: Pull Requests are welcome. Please adhere to the existing code style.

---

## 📄 License

This project is licensed under the [MIT License](https://github.com/enzo-desimone/firebase_verify_token_dart/blob/master/LICENSE).
