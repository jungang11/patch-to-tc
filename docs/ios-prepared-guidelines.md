# iOS Prepared Guidelines

In v0.1, iOS TCs are **"prepared but not executed"**. They are recorded in a separate column / section, never merged into Android rows. When iOS builds become part of the workflow, this file becomes the iOS execution guideline.

> See `android-tc-guidelines.md` for the executable Android version.

---

## Why "prepared" instead of "executed"

If you don't currently build for iOS:

- You don't have the device, signing setup, or CI to actually run iOS TCs
- Generating TCs you can't run wastes review time
- But ignoring iOS entirely means when iOS shipping starts, you'll be writing TCs from scratch

The compromise: **identify the iOS-relevant changes now, record what would need to be tested, but mark them as `Status: Prepared (not run)`.** This is cheap when done alongside Android TC generation (the model is already looking at the diff), and expensive to do later.

---

## What goes in an iOS Prepared TC

Same fields as Android, with these differences:

| Field | Difference from Android |
|---|---|
| **TC ID** | `IOS-<feature>-<NNN>` |
| **Platform** | `iOS (Prepared)` |
| **Status** | Default: `Prepared — not run`. Future: `Run — passed` / `Run — failed` |
| **Automation Candidate** | `XCUITest` / `Unity PlayMode (cross-platform)` / `Manual only` |
| **iOS-specific risk flags** | See below |

---

## iOS-specific risk flags to surface (even without running)

The skill should detect these from the diff and flag them, even if no execution happens:

| Signal in diff | Flag |
|---|---|
| Changes to `Info.plist` (entry strings, permission descriptions) | `permission-string-change` → may need App Store review re-justification |
| Changes to entitlements / capabilities (push, background modes, in-app purchase) | `capability-change` → signing profile may need regeneration |
| Changes to safe area handling, status bar, notch logic | `layout-iOS-specific` |
| Network code that doesn't go through Unity's HTTP stack | `iOS-network-stack` → ATS (App Transport Security) review needed |
| Filesystem paths assumed to be `/sdcard/`-style | `iOS-filesystem-mismatch` |
| Use of Android-only APIs (`Application.persistentDataPath` behaves differently) | `cross-platform-path-divergence` |
| Lifecycle hooks (`OnApplicationPause`) — iOS has different semantics | `iOS-lifecycle-difference` |
| In-app purchase / receipts code | `IAP-receipt-validation` (iOS uses App Store receipts, fundamentally different from Google Play) |
| Push notification code | `APNS-vs-FCM` |

The skill should add these flags to the Source/Risk column when the diff touches matching patterns.

---

## What an iOS Prepared TC looks like

```
TC ID: IOS-content-load-007
Platform: iOS (Prepared)
Type: Smoke
Priority: P1
Title: Verify ScriptableObject content loads on iOS after JSON path change
Preconditions:
  - Build: <iOS build, not yet produced>
  - Account: any
Steps:
  1. Launch app
  2. Navigate to content screen
  3. Observe content load
Expected Result: Content list renders within 3 seconds, no errors in Xcode console
Status: Prepared — not run
Automation Candidate: XCUITest
Source/Risk:
  git: Assets/Scripts/ContentLoader.cs, Assets/Data/contents.json
  commit: a1b2c3d..HEAD
  notion: dev-note section "JSON path refactor"
  risk: cross-platform-path-divergence
```

The TC is complete; only execution is deferred.

---

## When to promote from Prepared to Run

When the project starts shipping iOS:

1. Move all `Prepared — not run` rows into the active QA queue
2. Add a `Run Date` column
3. Update Status to `Run — passed/failed`
4. If a TC turns out to be irrelevant on iOS (Android-only feature), mark `Not Applicable` rather than deleting (preserves audit trail)

---

## v0.1 limitation

The skill currently identifies iOS Prepared TCs by **filename / pattern matching against the diff**, not by static analysis. This means subtle iOS-relevant changes (e.g., a constant value that happens to matter only on iOS) may be missed. That's an acceptable v0.1 limitation — the goal is to catch the obvious 80%, not be exhaustive.

For v0.2, we could add a `references/ios-static-analysis.md` with heuristics for static-analysis-based detection. Not in scope now.
