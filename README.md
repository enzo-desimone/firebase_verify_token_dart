# 🔥 Firebase Verify Token (Dart)

<p align="center">
  <img src="https://raw.githubusercontent.com/enzo-desimone/firebase_verify_token_dart/master/example/firebase-verify-token-dart.webp" alt="Firebase Verify Token Preview" width="420" style="border-radius: 16px; box-shadow: 0 8px 24px rgba(0,0,0,0.12);" />
</p>

<p align="center">
  <a href="https://pub.dev/packages/firebase_verify_token_dart"><img src="https://img.shields.io/pub/v/firebase_verify_token_dart?style=for-the-badge&logo=dart&color=0052CC" alt="Pub Version" /></a>
  <a href="https://pub.dev/packages/firebase_verify_token_dart/score"><img src="https://img.shields.io/pub/points/firebase_verify_token_dart?style=for-the-badge&color=0052CC" alt="Pub Points" /></a>
  <a href="https://pub.dev/packages/firebase_verify_token_dart"><img src="https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-0052CC?style=for-the-badge" alt="Platform Support" /></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-333333?style=for-the-badge" alt="License" /></a>
</p>

---

**Firebase Verify Token** is a secure, lightweight, and pure Dart library designed to verify and decode **Firebase Authentication ID tokens (JWTs)** using Google's public certificates.

No backend servers or Firebase Admin SDK service account keys required! Works seamlessly on client applications and server-side Dart backends (Dart Frog, Shelf, Serverpod, Cloud Functions).

---

## 📑 Table of Contents

- [✨ Features](#-features)
- [📦 Installation](#-installation)
- [🚀 Quick Start](#-quick-start)
- [📖 Usage Guide](#-usage-guide)
  - [1. Initialize Allowed Projects](#1-initialize-allowed-projects)
  - [2. Standard Token Verification](#2-standard-token-verification)
  - [3. Detailed Result Callback](#3-detailed-result-callback)
  - [4. Multi-Tenant & Thread-Safe Verification](#4-multi-tenant--thread-safe-verification)
  - [5. Ultra-Fast & Offline Mode (`useNtp: false`)](#5-ultra-fast--offline-mode-usentp-false)
  - [6. Clock Skew & Leeway Tolerance](#6-clock-skew--leeway-tolerance)
  - [7. Extract Claims Without Verification](#7-extract-claims-without-verification)
- [🔐 Verification & Security Checks](#-verification--security-checks)
- [⚙️ How Public Key Caching Works](#️-how-public-key-caching-works)
- [📄 API Reference](#-api-reference)
- [🤝 Contributing & License](#-contributing--license)

---

## ✨ Features

- 🛡️ **Zero Private Keys Needed**: Validates JWT signatures using Google's public X.509 certificates. Avoids bundling risky service account JSON keys into clients or edge microservices.
- ⚡ **Sub-Millisecond Execution**: In-memory caching of Google's public keys based on HTTP `Cache-Control` / `Expires` headers, with optional local clock mode (`useNtp: false`) for near-instant verification.
- ⏱️ **NTP Time Synchronization & Failover**: Eliminates client clock drift issues using `ntp_dart` for precise UTC time, with automatic and graceful fallback to the system clock when offline or behind firewalls.
- 🏢 **Multi-Tenant / Multi-Project**: Verify tokens across multiple Firebase projects in a single instance, or override project IDs per verification call for thread-safe concurrent requests.
- 🌍 **Pure Dart & 100% Cross-Platform**: Compatible with **Flutter** (Android, iOS, Web, macOS, Windows, Linux) and **Server-side Dart** (Dart Frog, Shelf, Serverpod, Docker, CLI).
- 🔄 **Configurable Leeway**: Built-in clock skew leeway (default 5 minutes) to absorb normal distributed server clock variances.

---

## 📦 Installation

Add `firebase_verify_token_dart` to your Flutter or Dart project:

```bash
# For Flutter projects:
flutter pub add firebase_verify_token_dart

# For pure Dart or Server-side projects:
dart pub add firebase_verify_token_dart
```

Or add it directly to your `pubspec.yaml`:

```yaml
dependencies:
  firebase_verify_token_dart: ^2.3.1
```

---

## 🚀 Quick Start

```dart
import 'package:firebase_verify_token_dart/firebase_verify_token_dart.dart';

void main() async {
  // 1. Configure accepted Firebase Project IDs (Audience)
  FirebaseVerifyToken.projectIds = ['my-firebase-project-id'];

  // 2. Verify an ID token
  final isValid = await FirebaseVerifyToken.verify(token);

  if (isValid) {
    print('✅ Token is authentic and valid!');
    final uid = FirebaseVerifyToken.getUserID(token);
    print('User UID: $uid');
  } else {
    print('❌ Token is invalid, expired, or untrusted.');
  }
}
```

---

## 📖 Usage Guide

### 1. Initialize Allowed Projects

Before validating tokens, configure the accepted Firebase Project IDs. The library checks that the token's `aud` claim matches one of these project IDs:

```dart
FirebaseVerifyToken.projectIds = [
  'my-production-app',
  'my-staging-app',
];
```

### 2. Standard Token Verification

The `verify()` method evaluates the token against Google's public certificates, cryptographic signatures, timestamp validity, audience, and issuer. It returns a boolean and never throws unhandled exceptions:

```dart
final bool isValid = await FirebaseVerifyToken.verify(token);

if (isValid) {
  // Grant access to protected resources
}
```

### 3. Detailed Result Callback

Pass an `onVerifyCompleted` callback to inspect verification metadata, such as the matched project ID and elapsed duration:

```dart
final isValid = await FirebaseVerifyToken.verify(
  token,
  onVerifyCompleted: ({
    required bool status,
    String? projectId,
    int duration = 0,
  }) {
    if (status) {
      print('✅ Verified for project "$projectId" in ${duration}ms');
    } else {
      print('❌ Verification failed after ${duration}ms');
    }
  },
);
```

> [!NOTE]
> `onVerifyCompleted` is always invoked upon completion, even if verification fails or an exception is caught internally.

### 4. Multi-Tenant & Thread-Safe Verification

In high-concurrency backends (e.g. Dart Frog, Shelf APIs), you might serve multiple tenants or distinct Firebase projects simultaneously. Rather than mutating the global `FirebaseVerifyToken.projectIds` list, pass `projectIds` directly to the `verify` call:

```dart
final isValid = await FirebaseVerifyToken.verify(
  token,
  projectIds: ['tenant-a-project', 'tenant-b-project'],
);
```

This prevents race conditions and makes your verification logic completely thread-safe.

### 5. Ultra-Fast & Offline Mode (`useNtp: false`)

By default, `verify()` queries an NTP server via `ntp_dart` to ensure the current UTC time is tamper-proof. For local testing, offline development, or ultra-low-latency API routes where NTP roundtrips are undesirable, disable NTP checks:

```dart
final isValid = await FirebaseVerifyToken.verify(
  token,
  useNtp: false, // Bypasses network NTP calls; executes in <1ms
);
```

#### Automatic NTP Failover
When `useNtp: true`, if the device is offline or UDP port 123 is blocked by a restrictive firewall, the library **automatically falls back to the system clock** to ensure your application continues working reliably.

### 6. Clock Skew & Leeway Tolerance

Distributed cloud systems can have minor clock differences. By default, a 5-minute leeway (`clockSkew`) is applied to timestamp comparisons (`exp`, `iat`, `auth_time`). You can adjust this duration as needed:

```dart
final isValid = await FirebaseVerifyToken.verify(
  token,
  clockSkew: const Duration(minutes: 2), // Custom leeway
);
```

### 7. Extract Claims Without Verification

To quickly inspect user metadata (like UID or Project ID) without performing a cryptographic verification:

```dart
// Extract Subject UID (`sub` claim)
final String uid = FirebaseVerifyToken.getUserID(token);

// Extract Audience Project ID (`aud` claim)
final String? projectId = FirebaseVerifyToken.getProjectID(token);
```

---

## 🔐 Verification & Security Checks

Under the hood, `FirebaseVerifyToken.verify()` enforces all strict requirements defined in the [official Firebase Auth specification](https://firebase.google.com/docs/auth/admin/verify-id-tokens#verify_id_tokens_using_a_third-party_jwt_library):

| Claim / Property | Validation Rule |
|---|---|
| **Algorithm (`alg`)** | Must be `RS256` (RSA SHA-256). |
| **Key ID (`kid`)** | Must correspond to one of Google's current public certificates. |
| **Cryptographic Signature** | Verified against Google's public key using `jose_plus`. |
| **Audience (`aud`)** | Must match one of the configured `projectIds`. |
| **Issuer (`iss`)** | Must strictly equal `https://securetoken.google.com/<projectId>`. |
| **Subject (`sub`)** | Must be a non-empty string identifying the authenticated user. |
| **Expiration Time (`exp`)** | Must be in the future (taking `clockSkew` leeway into account). |
| **Issued At (`iat`)** | Must be in the past (taking `clockSkew` leeway into account). |
| **Authentication Time (`auth_time`)** | Must be in the past (taking `clockSkew` leeway into account). |

---

## ⚙️ How Public Key Caching Works

Google rotates its public certificates regularly (usually every few hours). 

1. On the first verification call, `firebase_verify_token_dart` fetches Google's public certificates from:  
   `https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com`
2. It parses the HTTP `Cache-Control` (`max-age`) and `Expires` response headers.
3. Certificates are cached in memory until expiry. Subsequent token verifications reuse the cached keys in memory without initiating any HTTP network roundtrips.

---

## 📄 API Reference

### `FirebaseVerifyToken` Class

| Member | Type | Description |
|---|---|---|
| `projectIds` | `List<String>` | Global list of allowed Firebase project IDs. |
| `verify(token, ...)` | `Future<bool>` | Verifies JWT signature, issuer, audience, and timestamps. |
| `getUserID(token)` | `String` | Extracts the user UID (`sub` claim) unverified. |
| `getProjectID(token)` | `String?` | Extracts the project ID (`aud` claim) unverified. |

### `FirebaseVerifyToken.verify` Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `token` | `String` | *required* | The raw Firebase Auth JWT string. |
| `projectIds` | `List<String>?` | `null` | Optional list of project IDs to override global `projectIds`. |
| `clockSkew` | `Duration` | `Duration(minutes: 5)` | Clock drift tolerance leeway. |
| `useNtp` | `bool` | `true` | When `true`, uses NTP time synchronization with system clock fallback. |
| `onVerifyCompleted` | `Function?` | `null` | Callback returning `status`, `projectId`, and `duration`. |

---

## 🤝 Contributing & License

Contributions, feedback, and bug reports are welcome! Please feel free to open an issue or pull request on [GitHub](https://github.com/enzo-desimone/firebase_verify_token_dart).

Released under the [MIT License](https://opensource.org/licenses/MIT).

