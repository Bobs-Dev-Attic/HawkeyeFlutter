# Hawkeye Flutter Review

## Scope reviewed

- Core app flow, repositories, models, and services.
- Existing setup and handoff docs.
- Focus areas: security, privacy, memory/performance, reliability, UX, and strategic/product fit.

## Executive summary

The project is a good prototype baseline, but not production-safe yet. The highest-risk gaps are in backend authorization, key-management model maturity, error handling, and incomplete encrypted-data lifecycle. The app also has a concrete implementation defect where mock location writes can target an incorrect circle path.

## Findings by perspective

### 1) Senior software engineering perspective

**Strengths**
- Clean project shape and separation by service/repository/screen.
- Reasonable prototype abstractions for Auth, Storage, and Crypto.
- Straightforward stream-based auth gate.

**Issues / improvements**
- Controllers are not disposed in `LoginScreen` and `HomeScreen` (`TextEditingController` leak risk over screen rebuilds/navigation loops).
- `authService.currentUser!` is used heavily without defensive guards in repositories; race/null edge cases can crash.
- Async operations in UI are fire-and-forget without loading disablement, error mapping, or idempotency protections.
- Data mapping assumes fields always present (`AppUser.fromMap`) and can throw if backend schema drifts.
- No app-wide error boundary, crash reporting, or structured logging.

### 2) Security analyst / white-hat perspective

**Critical risks**
- Documentation suggests permissive rules for circles/places/locations; without strict membership validation, users can read/write unauthorized data.
- App Check is not enforced, enabling scripted abuse of backend endpoints from non-genuine clients.
- Encryption is write-only in code path and currently user-key scoped, not circle-key scoped; this cannot support robust sharing and revocation semantics.
- Single avatar path (`avatar.jpg`) allows overwrite races and weak auditability/versioning.

**Pen-test style concerns**
- Lack of server-side schema validation in rules invites malformed document injection.
- No rate-limit strategy for auth brute-force and spam writes.
- Potential metadata leakage: ciphertext protected, but document-level metadata patterns remain queryable.

### 3) UX design perspective

- Login and home flows are highly technical and do not communicate trust/privacy model clearly.
- Critical actions (create/join/share/post location) lack progress indicators and success/failure feedback.
- Current IA conflates circle-name input with action that posts location by circleId (error-prone mental model).
- Accessibility baseline needs work (validation copy, keyboard hints, semantics).

### 4) Founder / executive / marketer perspective

- Product narrative should emphasize "private-by-default" but must match true implementation status to avoid trust debt.
- North-star metrics should include trust/reliability signals (successful secure share, failed decrypt rate, support tickets).
- A growth feature (invite codes) exists but lacks abuse controls and analytics instrumentation.

### 5) Legal / privacy perspective

- Needs explicit privacy notice for location processing purposes, retention, and lawful basis (where required).
- Must define data-subject rights workflows (access, delete, portability).
- Should avoid overstating "end-to-end encryption" until key exchange/rotation/revocation and decrypt lifecycle are complete.

## Concrete code issues spotted

1. `HomeScreen` uses `_circleName.text` as `circleId` for mock location send; this can write to wrong path and create data inconsistencies.
2. `TextEditingController` instances are not disposed in `HomeScreen` and `LoginScreen`.
3. Auth and repository calls have no visible try/catch + user-safe error mapping.
4. `CryptoService` currently only encrypts; no decrypt utility for retrieval/verification flows.
5. Storage upload path/versioning is static and does not constrain content type/size at code layer.

## Recommended architecture hardening

1. **Security-first backend contract**
   - Rule-enforced ownership and circle membership checks.
   - Immutable and schema-validated critical fields (senderUid, createdAt).
2. **Crypto maturity**
   - Per-circle DEK encrypted for each member (envelope model).
   - Key rotation + member revocation process.
3. **Reliability layer**
   - Typed failures (`AuthFailure`, `StorageFailure`, etc.), retries, and UX-safe messaging.
4. **Operational readiness**
   - Crash reporting, structured logs, audit trails, and security monitoring.
5. **Quality gates**
   - Unit + integration tests, lint + analyzer + dependency vulnerability checks in CI.

## Better options / services to consider

- **Firebase App Check** with Play Integrity / DeviceCheck.
- **Cloud Functions / Cloud Run mediator** for sensitive membership mutations and invite workflows.
- **Remote Config + Feature Flags** to stage risky rollout.
- **Secret Manager / KMS-backed services** for server-side cryptographic workflows where needed.
- **Analytics + product telemetry** (privacy-preserving event model) for UX optimization.

## Suggested phased rollout

- **Phase 1 (2–4 weeks):** authorization rules hardening, bug fixes, error handling, controller disposal, test scaffold.
- **Phase 2 (4–8 weeks):** envelope encryption, decryption pipeline, App Check, observability.
- **Phase 3 (ongoing):** compliance artifacts, incident readiness, growth experiments with abuse controls.
