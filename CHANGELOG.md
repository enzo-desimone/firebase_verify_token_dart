# Changelog

## 2.0.1
- Removed the `ntp` package to ensure full compatibility with WebAssembly (WASM).

## 2.0.0

- Improved the readability of the `verify()` method by introducing a dedicated helper class.
- Renamed the method `getUserIdByToken` to `getUserID` for clarity and consistency.
- The `getUserID` method now returns the correct value according to Google’s documentation (`sub claim`).
- Added the `getProjectID` method to extract the Firebase project ID (`aud claim`) from a token.
- Increased the default cache duration for accurate time resolution.
- Updated `http` and `jose_plus` packages.
- Added logging when JWT verification fails, to aid in debugging.
- Improved overall documentation for better understanding and usage of the class.
- Refactored and cleaned up the code for better performance and maintainability.

## 1.0.1

- Updated `http` package.
- Updated documentation.

## 1.0.0

- Replaced `projectId` with `projectIds` to support multi-project verification.
- Added the `onVerifySuccessful` callback function to execute code once the token is verified.
- Reduced verification times by caching Google `kids` and `NTP`.
- Updated dependencies.
- Optimized parsing algorithms.
- Clean code.
- Updated documentation.

## 0.0.7

- Publish package


