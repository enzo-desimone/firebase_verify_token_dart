# Firebase Verify Token

A plugin that allows you to verify a **Firebase JWT Token** for a specific firebase project.

[![Pub Version](https://img.shields.io/pub/v/firebase_verify_token?style=flat-square&logo=dart)](https://pub.dev/packages/firebase_verify_token)
![Pub Likes](https://img.shields.io/pub/likes/firebase_verify_token)
![Pub Likes](https://img.shields.io/pub/points/firebase_verify_token)
![Pub Likes](https://img.shields.io/pub/popularity/firebase_verify_token)
![GitHub license](https://img.shields.io/github/license/enzo-desimone/check_app_version?style=flat-square)

## Platform Support

| Android | iOS | MacOS | Web | Linux | Windows |
|:-------:|:---:|:-----:|:---:|:-----:|:-------:|
|   ✔️    | ✔️  |  ✔️   | ✔️  |  ✔️   |   ✔️    |

## About

Token verification involves the following steps:

- Check if the token was generated by the same project id.
- Check if the token was generated by firebase authentication.
- Check if the token has expired

## Install

### Import the Check App Version package

To use the Firebase Verify Token package, follow
the [plugin installation instructions](https://pub.dev/packages/firebase_verify_token/install).

### Use the package

Add the following import to your Dart code:

```dart
import 'package:firebase_verify_token/firebase_verify_token.dart';
```

Now we need to initialize the static variable **projectId** in the **FirebaseVerifyToken** class.
You need to enter the firebase project ID.

```dart
FirebaseVerifyToken.projectId = 'my-project-id';
```

At this point, we can call the **verify** method from the **FirebaseVerifyToken** class, passing the
**string token** that we want to verify, as a parameter. The method will return **TRUE** if the
token is valid, **FALSE** if it is not.

```dart
await FirebaseVerifyToken.verify('my-token-string');
```