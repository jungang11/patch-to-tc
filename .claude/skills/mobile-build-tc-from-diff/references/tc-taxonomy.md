# TC Taxonomy

This taxonomy is used by SKILL.md Stage 2 (Triage). It defines: **given a changed file or pattern, what risk categories apply, and what Test Case (TC) types should be generated.**

Each category below lists the diff signals that map to it, the risk it surfaces, the TC types to generate, Android-specific considerations, iOS Prepared flags to attach, and example TC titles. The skill matches changed files against the `Signals` field; a single file may match multiple categories (typical).

---

## Category structure

Each entry follows this shape:

- **Signals** — diff patterns (file path globs, code-content greps, commit-message keywords) that map to this category.
- **Risk** — 1-2 sentences on why this category is risky.
- **TC types to generate** — Build Gate / Smoke / Regression / Edge (one or more).
- **Android considerations** — platform-specific signals to attach to Android TCs.
- **iOS Prepared flags** — risk flags to attach to iOS Prepared rows (always populate, even if iOS isn't actively tested).
- **Example TC titles** — anchor structure for the skill's generation step.

---

## Categories

### data-schema-change

**Signals:**
- File names containing `Migrator` or `Migration`
- ScriptableObject `.asset` modifications
- Changed `[SerializeField]` lines on persisted types
- Save-format version constants bumped
- Commit messages mentioning "migrate", "schema", "save format"

**Risk:** Existing users' saves can fail to migrate to the new schema, causing data loss or crashes. Mid-migration corruption is a separate failure path that is easily missed.

**TC types to generate:** Build Gate, Regression, Edge

**Android considerations:** Save files live in `Application.persistentDataPath`. Low-storage state during migration, force-kill mid-migration, and Auto Backup restore on a different device are all relevant.

**iOS Prepared flags:** `cross-platform-path-divergence`, `data-schema-change` — iOS backup/restore behavior differs, and iCloud/CloudKit usage may complicate recovery semantics.

**Example TC titles:**
- "v1 save migrates to v2 without losing claimed rewards"
- "Force-kill mid-migration recovers on next launch, no corruption"

---

### async-refactor

**Signals:**
- New `async`/`await` keywords on previously sync methods
- `UniTask`, `UniTaskCompletionSource` introduced
- `IEnumerator` → `async Task` conversions
- `StartCoroutine` removals paired with await additions

**Risk:** Race conditions, double-fire on rapid input, missing cancellation handling, deadlock on awaited main-thread calls.

**TC types to generate:** Smoke, Regression, Edge

**Android considerations:** Main-thread blocking causes ANR. Background entry should cancel in-flight awaits, not silently complete after resume.

**iOS Prepared flags:** `lifecycle-async-divergence` — iOS suspends faster than Android; awaits resolving post-suspend may behave differently.

**Example TC titles:**
- "Double-tapping action button does not double-fire request"
- "App pause cancels pending async load, no orphaned state on resume"

---

### new-feature

**Signals:**
- New Scene, Prefab, or UI controller files
- New service classes (e.g., `*Service.cs`, `*Manager.cs`)
- Commit messages starting with `feat:` or describing additions
- Significant additions to entry-point screens

**Risk:** Newly added code is unvalidated surface area. Adjacent existing features may regress if the new code shares dependencies (singletons, event buses).

**TC types to generate:** Build Gate, Smoke, Regression, Edge

**Android considerations:** Device rotation during new flows, soft-keyboard interaction, back-button navigation out of new screens.

**iOS Prepared flags:** `new-feature`, `safe-area-handling` — safe-area insets often break new layouts.

**Example TC titles:**
- "Feature entry point reachable from main menu after cold start"
- "Back navigation from new feature returns to expected screen"

---

### server-dependent

**Signals:**
- HTTP client invocations (`UnityWebRequest`, `HttpClient`)
- New API URL constants
- DTO / response-model schema changes
- New endpoints referenced in code or docs

**Risk:** Server downtime, latency, and error responses must each have user-visible handling. Response-schema changes can silently break parsing.

**TC types to generate:** Smoke, Regression, Edge

**Android considerations:** Slow network simulation (3G), captive portal, network permission state, airplane mode toggle mid-request.

**iOS Prepared flags:** `ats-restriction`, `cellular-vs-wifi-divergence` — iOS App Transport Security may block non-HTTPS endpoints.

**Example TC titles:**
- "Server 500 surfaces user-readable error, not raw stack"
- "Timeout shows retry UI and recovers on retry"

---

### permission-flow

**Signals:**
- `AndroidManifest.xml` permission additions
- `Permission.RequestUserPermission` calls
- `Info.plist` keys like `NSCameraUsageDescription`
- Notification permission handling

**Risk:** Permission denial often leads to dead-end UX or crashes. "Don't ask again" state is easy to forget. Missing iOS usage-description keys cause immediate crash on access.

**TC types to generate:** Build Gate, Smoke, Edge

**Android considerations:** API 23+ runtime permission flow, scoped storage (API 29+), permission revoked-from-settings while app is backgrounded.

**iOS Prepared flags:** `permission-flow`, `missing-usage-description-crash`.

**Example TC titles:**
- "Camera permission denied shows fallback explainer, no crash"
- "Permission revoked from system settings is handled on resume"

---

### lifecycle

**Signals:**
- `OnApplicationPause`, `OnApplicationFocus`
- `AppDelegate.applicationWillResign`, `applicationDidBecomeActive`
- GL context re-initialization code
- Background-task scheduling

**Risk:** **High blast radius.** Pause/resume defects manifest across many screens; one regression can affect every flow.

**TC types to generate:** Build Gate, Regression (broad sweep), Edge

**Android considerations:** Doze mode, multi-window, picture-in-picture, OEM-specific aggressive killers (Xiaomi, OnePlus battery savers).

**iOS Prepared flags:** `lifecycle-broad-regression`.

**Example TC titles:**
- "Resume from camera intent preserves in-progress state"
- "Deep background (10+ min) restores session without re-login"

---

### addressables-cache

**Signals:**
- `Addressables.LoadAssetAsync` calls
- `AssetBundle` references
- `catalog.json`, `RemoteCatalog` URL constants
- Bundle build settings changed

**Risk:** Catalog mismatch between client and server causes load failures. Cache corruption or download interruption leaves the app in an unrecoverable state without explicit handling.

**TC types to generate:** Smoke, Regression, Edge

**Android considerations:** App-specific external cache availability (no storage permission required on API 19+ for app-specific paths), cache eviction under low storage, download interruption, and cellular vs Wi-Fi behavior.

**iOS Prepared flags:** `cross-platform-path-divergence` — iOS sandbox path differs; cache location is per-app.

**Example TC titles:**
- "First-run downloads remote catalog successfully on 3G"
- "Cleared cache re-downloads required bundles without dead-end"

---

### cross-platform-path-divergence

**Signals:**
- `Application.persistentDataPath` references
- `StreamingAssets` usage
- Hardcoded path separators (`/` vs `\`)
- `File.ReadAllText` with relative paths

**Risk:** Android and iOS resolve paths differently (case sensitivity, sandbox layout). Code that works on one platform can silently fail on the other.

**TC types to generate:** Regression, Edge

**Android considerations:** Scoped storage rules (API 29+), legacy external storage compatibility.

**iOS Prepared flags:** `cross-platform-path-divergence` (mandatory).

**Example TC titles:**
- "User data file reads correctly after app upgrade across platforms"
- "Special-character filename does not crash on either platform"

---

### idempotency

**Signals:**
- Retry loops, exponential backoff
- Transaction or receipt code (`IAP`, `Billing`, `StoreKit`)
- Dedup-key parameters in requests

**Risk:** Duplicate execution causes double charges or double reward grants. Network hiccups during purchase are the highest-stakes failure path.

**TC types to generate:** Build Gate, Edge

**Android considerations:** Google Play Billing acknowledgement timing, pending purchase recovery on relaunch.

**iOS Prepared flags:** `iap-idempotency`, `storekit-queue-replay`.

**Example TC titles:**
- "Double-tap on purchase button grants single reward, single charge"
- "Network drop mid-purchase recovers without double-charge on retry"

---

### timing

**Signals:**
- `WaitForSeconds`, `Thread.Sleep`
- Frame-rate-dependent logic (`Time.deltaTime` thresholds)
- Handshake or ordering code (login → fetch → render)

**Risk:** Device performance variance can break ordering assumptions. Rapid input may skip required animations or state transitions.

**TC types to generate:** Regression, Edge

**Android considerations:** Low-end device frame drops (sub-30fps), background CPU throttling.

**iOS Prepared flags:** `timing-device-divergence` — iOS performance characteristics differ, especially on older iPads.

**Example TC titles:**
- "Login completes before initial content renders, no flash of empty state"
- "Rapid tap during animation does not skip required step"

---

### localization

**Signals:**
- `Resources/Strings/` or locale directory additions
- `.po`, `.csv` locale file changes
- `LocalizationSettings` calls
- New font assets

**Risk:** Translation gaps, RTL layout breakage, font fallback missing for non-Latin scripts.

**TC types to generate:** Smoke, Regression, Edge

**Android considerations:** Locale change triggers Activity recreate — state must persist. System font scaling (large-text accessibility) interacts with layout.

**iOS Prepared flags:** `localization-rtl`, `font-fallback`.

**Example TC titles:**
- "Each supported locale renders without truncation on standard device"
- "RTL layout mirrors correctly in cart and settings flows"

---

### manifest-change

**Signals:**
- `AndroidManifest.xml` modifications
- `Info.plist` modifications
- Intent filter additions, URL scheme registrations

**Risk:** Manifest changes affect installation, store review (rejection risk on new sensitive permissions), and inter-app communication (deeplinks). Easy to miss until reproducing on a real install.

**TC types to generate:** Build Gate, Smoke

**Android considerations:** Target SDK version changes alter runtime behavior. New permissions trigger store-review questionnaires.

**iOS Prepared flags:** `plist-change`, `url-scheme-handler`, `capability-change-if-entitlements-changed` — purpose-string additions (e.g., `NSCameraUsageDescription`) are plist changes, not capability changes.

**Example TC titles:**
- "Custom URL scheme opens app to expected screen from external link"
- "New runtime permission triggers system dialog on first relevant action"

---

### capability-change

**Signals:**
- iOS entitlements file changes
- Android `<uses-feature>` additions
- Push notification certificate / token handling
- Background mode capability changes

**Risk:** Missing capability causes silent feature failure. iOS provisioning profile must be re-issued; mismatch fails install on TestFlight.

**TC types to generate:** Build Gate, Regression

**Android considerations:** `<uses-feature required="true">` removes devices from Play Store availability.

**iOS Prepared flags:** `capability-change` (mandatory), `provisioning-profile-mismatch`.

**Example TC titles:**
- "Push notification delivered after new capability is added"
- "Bluetooth-dependent flow works after entitlement update"

---

### large-data-load

**Signals:**
- Large JSON/CSV asset additions, especially files parsed on the main thread or loaded during startup
- `JsonUtility.FromJson` on large strings
- Texture atlas size increases
- New high-resolution media

**Risk:** Out-of-memory crashes on low-RAM devices. Long load times cause user drop-off and may interact with timeout / idle-kill behavior.

**TC types to generate:** Regression, Edge

**Android considerations:** 1GB-RAM Go-Edition devices, background OOM-killer, large-asset download over metered networks.

**iOS Prepared flags:** `large-data-load`, `older-ipad-memory`.

**Example TC titles:**
- "Asset loads on 1GB RAM device without OOM"
- "Foreground return mid-load completes load without crash"

---

### error-recovery

**Signals:**
- New `try`/`catch` blocks with fallback paths
- Default-value injection on parse failure
- Error-state UI additions

**Risk:** Error paths are typically less tested than success paths. Silent fallbacks may hide bugs; loud fallbacks may break user trust.

**TC types to generate:** Edge

**Android considerations:** Storage-full and network-blocked states must produce user-readable errors, not silent failure.

**iOS Prepared flags:** `error-recovery-ios-divergence`.

**Example TC titles:**
- "Storage full during save shows user-readable error with retry"
- "Parse failure falls back to default profile without dead-end"

---

## How the skill uses this

When processing a diff:

1. For each changed file, match against `Signals` across all categories.
2. A file may match multiple categories — record all matches.
3. For each matched category, generate TCs of the listed types.
4. Apply `Android considerations` to the Android section, `iOS Prepared flags` to the iOS Prepared section.
5. De-duplicate at the end (same TC generated from two categories → keep one row, merge Source/Risk).

If a real diff reveals patterns not covered above, add a new category here rather than forcing the change into an ill-fitting existing one. If a category never applies to this project, mark it as `Not applicable to this project` rather than deleting it — keeps the taxonomy reusable across projects.

---

## Anti-patterns

- **Over-categorization.** A single TC tagged with 5+ risk categories means the taxonomy is too granular for the change. Target: 1-3 categories per TC.
- **Vague signals.** "Anything in `Assets/Scripts/`" is not a signal — be specific (file-name patterns, code-content greps, commit-message keywords).
- **Missing iOS flags.** If a category could affect iOS, list the flag even when iOS isn't actively tested. The iOS Prepared section depends on these flags being present.
- **Inflating TC types.** Not every category needs all four types. `error-recovery` is usually Edge-only; `idempotency` is usually Build Gate + Edge. Match types to actual risk.
