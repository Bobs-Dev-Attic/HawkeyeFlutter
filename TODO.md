# TODO (Prioritized)

> **Status (May 13, 2026):** P0 and P1 remediation work has been completed in the codebase and validated in recent updates. The next execution phase is **P2** (UX, product, and observability), while continuing regression checks to ensure P0/P1 guarantees remain intact.

## P0 — Critical security, privacy, and data integrity

- [ ] **Replace prototype Firestore rules with membership/ownership-based authorization** (deny-by-default, per-collection checks, immutable fields, schema validation).
- [ ] **Add Firebase App Check** (DeviceCheck/Play Integrity/reCAPTCHA Enterprise) to reduce abuse of Auth, Firestore, and Storage APIs.
- [ ] **Move from single per-user key to per-circle envelope encryption** (X25519/ECDH + wrapped DEKs; support member add/revoke).
- [ ] **Implement decryption path + corruption handling** for encrypted payloads and telemetry for crypto failures.
- [ ] **Fix HomeScreen location write bug** (currently sends `_circleName.text` as `circleId`, causing writes to wrong document path).
- [ ] **Add input validation and exception handling** for auth, circle creation/join, avatar upload, and place/location write operations.
- [ ] **Remove permissive prototype guidance from setup docs or mark as unsafe for production**.

## P1 — Reliability, memory/performance, and best practices

- [ ] Dispose all `TextEditingController`s in `State` classes to avoid leaks.
- [ ] Add loading, empty, and error states for all async operations; prevent duplicate submits.
- [ ] Create user profile on first sign-in if missing (idempotent upsert).
- [ ] Introduce repository-level typed DTO validation and null-safe mapping guards.
- [ ] Add retry/backoff policy for transient Firebase failures.
- [ ] Add image constraints for avatar uploads (size, MIME whitelist, compression, EXIF strip).
- [ ] Use deterministic Storage file naming/versioning and cache headers.
- [ ] Add indexes + query budget review for expected growth.

## P2 — UX, product, and observability

- [ ] Add first-run onboarding and explicit privacy notice for location sharing + encryption limitations.
- [ ] Improve join/create flows with clearer IA, disabled buttons, and inline form errors.
- [ ] Add accessible UX improvements (semantic labels, contrast checks, larger tap targets).
- [ ] Add event instrumentation (funnel, drop-off, auth errors, upload failures).
- [ ] Add user controls: revoke sessions, rotate keys, delete account/data export requests.

## P3 — Governance, legal, and operational maturity

- [ ] Add threat model (STRIDE) and security test plan (SAST/DAST/dependency scanning).
- [ ] Add privacy program artifacts: data inventory, retention schedule, deletion SLAs.
- [ ] Add compliance mapping for target markets (CCPA/CPRA, GDPR, COPPA as applicable).
- [ ] Add incident response runbook and audit logging strategy.
- [ ] Add release gates in CI: static analysis, unit/integration tests, lint, and security checks.
