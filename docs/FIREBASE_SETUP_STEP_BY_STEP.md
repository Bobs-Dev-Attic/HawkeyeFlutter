# Firebase Setup (Step-by-Step) for Hawkeye Flutter

This document provides a complete Firebase setup path for a working prototype.

---

## 0) Prerequisites

Install:

- Flutter SDK (stable channel)
- Dart SDK (bundled with Flutter)
- Firebase CLI (`npm i -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

Verify:

```bash
flutter --version
firebase --version
flutterfire --version
```

---

## 1) Create Firebase Project

1. Open Firebase Console: <https://console.firebase.google.com/>
2. Click **Create a project**.
3. Name it (example: `hawkeye-dev`).
4. Disable Google Analytics for fast prototype setup (optional).
5. Create project.

---

## 2) Register App Targets in Firebase

Register each platform you plan to run:

- Android app
- iOS app
- Web app (optional for prototype)

### Android

1. In Firebase project settings, click **Add app** → Android.
2. Use Android package name from Flutter project (check `android/app/build.gradle` if present).
3. Download `google-services.json`.
4. Place it in `android/app/google-services.json`.

### iOS

1. Add iOS app in Firebase.
2. Use iOS bundle ID from Xcode project (`ios/Runner.xcodeproj`).
3. Download `GoogleService-Info.plist`.
4. Place it in `ios/Runner/GoogleService-Info.plist`.

---

## 3) Enable Firebase Authentication

1. In Firebase Console → **Authentication** → **Get started**.
2. Open **Sign-in method** tab.
3. Enable **Email/Password** provider.
4. Save.

Recommended prototype setting:

- Keep “Email link (passwordless sign-in)” disabled unless explicitly implementing it.

---

## 4) Create Firestore Database

1. Firebase Console → **Firestore Database** → **Create database**.
2. Start in **Production mode** (recommended), then apply explicit rules below.
3. Pick a region close to users (e.g., `us-central1`).
4. Create database.

### Suggested Collections

- `users/{uid}`
- `circles/{circleId}`
- `locations/{locationId}`
- `places/{placeId}` (or nested under users/circles depending on repository design)

---

## 5) Enable Firebase Storage

1. Firebase Console → **Storage** → **Get started**.
2. Choose same region as Firestore when possible.
3. Create default bucket.

Use Storage for avatar images and optional attachments.

---

## 6) Configure Flutter with FlutterFire CLI

Run in repo root:

```bash
flutterfire configure
```

When prompted:

1. Select Firebase project (`hawkeye-dev`).
2. Select target platforms in use.
3. Confirm output file path for generated options (usually `lib/firebase_options.dart`).

Then fetch packages:

```bash
flutter pub get
```

---

## 7) Firestore Security Rules (Prototype Baseline)

Apply this baseline and then tighten as needed:

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(uid) {
      return isSignedIn() && request.auth.uid == uid;
    }

    match /users/{uid} {
      allow read, write: if isOwner(uid);
    }

    match /circles/{circleId} {
      allow read, create: if isSignedIn();
      allow update, delete: if isSignedIn();
    }

    match /locations/{locationId} {
      allow read, create: if isSignedIn();
      allow update, delete: if false;
    }

    match /places/{placeId} {
      allow read, write: if isSignedIn();
    }
  }
}
```

> Note: This is a prototype baseline. Production should enforce circle membership checks and stricter immutable write patterns.

---

## 8) Storage Security Rules (Prototype Baseline)

```txt
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    function isSignedIn() {
      return request.auth != null;
    }

    match /avatars/{uid}/{allPaths=**} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && request.auth.uid == uid;
    }
  }
}
```

---

## 9) Indexes (If Queries Require Them)

If Firestore returns an index error link:

1. Open generated index link from app logs.
2. Create the suggested composite index.
3. Wait for index build completion.

Common likely indexes for this app:

- `locations` by `circleId + createdAt desc`
- `places` by `uid + createdAt desc`

---

## 10) Local Validation Checklist

1. `flutter run`
2. Register user.
3. Confirm `users/{uid}` exists in Firestore.
4. Create circle.
5. Add place.
6. Upload avatar and verify file in Storage under `/avatars/{uid}/...`.
7. Create mock location and verify encrypted payload fields are stored.

---

## 11) Troubleshooting

- **`PERMISSION_DENIED`**
  - Recheck Firestore/Storage rules deployment and auth state.
- **`[core/no-app]` Firebase not initialized**
  - Ensure generated `firebase_options.dart` exists and is used in app initialization.
- **Upload succeeds locally but not visible**
  - Verify Storage path, metadata, and bucket rules.
- **iOS build issues after adding Firebase**
  - Run `cd ios && pod install`.

---

## 12) Recommended Next Hardening Steps

- Add App Check.
- Move from broad prototype rules to role/membership-based access.
- Add key-wrapping for per-circle encryption keys.
- Add CI check that validates required Firebase config files exist for target platforms.

