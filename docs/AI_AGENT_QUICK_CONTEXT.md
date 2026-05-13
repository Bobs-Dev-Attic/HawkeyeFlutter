# AI Agent Quick Context (Token-Saving)

Purpose: help Codex/Claude quickly modify this repo with minimal re-reading.

## Project in 30 seconds

- Flutter prototype for circle-based location sharing.
- Backend: Firebase Auth + Firestore + Storage.
- Encryption: client-side AES-GCM helper for payload writes.
- Main UI: login/register and one home screen for circles/places/mock location.

## Fast file map

- App entry: `lib/main.dart`, `lib/src/app.dart`
- Auth flow: `lib/src/ui/screens/auth_gate.dart`, `lib/src/ui/screens/login_screen.dart`
- Main UX: `lib/src/ui/screens/home_screen.dart`
- Repositories: `lib/src/repositories/location_repository.dart`, `lib/src/repositories/user_repository.dart`
- Services: `lib/src/services/auth_service.dart`, `lib/src/services/crypto_service.dart`, `lib/src/services/storage_service.dart`
- Setup docs: `README.md`, `docs/FIREBASE_SETUP_STEP_BY_STEP.md`, `docs/PROTOTYPE_HANDOFF_GUIDE.md`

## Known high-priority pitfalls (read before coding)

- `HomeScreen` mock location action uses `_circleName.text` as `circleId` (bug).
- UI controllers currently lack `dispose()`.
- Repositories often force `currentUser!` and can throw if auth state changes.
- Setup docs include prototype-security rules that are not production-safe.

## Safe change strategy

1. Keep service/repository/screen boundaries.
2. Add failure handling and UX feedback before adding features.
3. Prefer typed models for Firestore payloads (avoid dynamic map sprawl).
4. Keep encryption claims precise; do not market as full E2EE until key exchange lifecycle exists.

## Definition of done for typical PR

- Analyzer passes.
- No new runtime exceptions in auth/circle/place flows.
- Security rules/docs updated if data model touched.
- Manual smoke checklist run (register → circle → place → location → relogin).

## Preferred commit/PR content

- Include: user impact, risk, rollback notes, and test evidence.
- Highlight any security-sensitive deltas explicitly.
