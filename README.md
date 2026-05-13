# Hawkeye Flutter

A secure, Firebase-backed Flutter starter app for circle-based location sharing with end-to-end encrypted location payloads.

## Features

- Email/password sign in and registration with Firebase Auth.
- Group circles (family, friends, coworkers) with invite/share codes.
- Encrypted location updates and saved places persisted in Firestore.
- Avatar selection using built-in icons or uploaded image to Firebase Storage.
- Place management and quick-create mock location entries.

## Setup

1. Install Flutter and Firebase CLI.
2. Configure your app with FlutterFire:
   ```bash
   flutterfire configure
   ```
3. Ensure Firestore + Storage security rules are configured for your project.
4. Run:
   ```bash
   flutter pub get
   flutter run
   ```

## End-to-end encryption model

- A per-user symmetric key is generated and stored in `flutter_secure_storage`.
- Location and place payloads are encrypted on-device before upload.
- Firebase stores only ciphertext, nonce, and metadata.
- Group sharing is represented in app model; production apps should add key-exchange / per-circle key wrapping (e.g. X25519 + envelope encryption).
