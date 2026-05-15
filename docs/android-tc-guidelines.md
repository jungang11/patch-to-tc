# Android TC Guidelines

Rules for generating **Android execution test cases**. These TCs are intended to be run against actual builds (real device or emulator).

> For iOS, see `ios-prepared-guidelines.md`. iOS TCs in v0.1 are "prepared but not executed" — separate column, never merged with Android rows.

---

## Test layers for Android

Every Android patch should produce TCs across these layers, **in this priority order**:

### 1. Build Gate (P0 — block release if any fails)

- Android build succeeds (Unity build → Gradle → APK/AAB)
- APK / AAB is generated at expected path
- Install succeeds on a real device (not just emulator)
- First-launch completes without crash within 10 seconds
- Required permission prompts appear and dismissable

### 2. Smoke (P0/P1)

- Changed feature's entry point is reachable from a cold start
- Main user flow that exists today still works (regression sanity)
- Background → foreground (pause/resume) doesn't lose state
- Logout / login (or equivalent session reset) works

### 3. Regression (P1/P2)

- For every modified file, identify which existing flows depend on it and verify those still work
- Use the risk taxonomy in `references/tc-taxonomy.md` to map files → flows

### 4. Edge / Stress (P2/P3)

- Low-end device performance (define a "low-end target" in your project's CLAUDE.md)
- Network: offline, slow (Network Link Conditioner-style), intermittent
- Memory: app behavior after backgrounding through 5+ other heavy apps
- Locale / language switching mid-session
- Date/time edge cases (timezone change, midnight rollover, leap day)

---

## What an Android TC must contain

| Field | Requirement |
|---|---|
| **TC ID** | `AND-<feature>-<NNN>` |
| **Platform** | `Android` (never "Android/iOS combined") |
| **Type** | Build Gate / Smoke / Regression / Edge |
| **Priority** | P0 / P1 / P2 / P3 |
| **Title** | One sentence, action-oriented. "Verify X when Y." |
| **Preconditions** | Build version, account state, device state, network state |
| **Steps** | Numbered. Each step is one user action. No compound steps. |
| **Test Data** | Specific values if needed (e.g., test account ID, payload JSON snippet) |
| **Expected Result** | Observable, unambiguous. No "should work properly." |
| **Automation Candidate** | `Unity EditMode` / `Unity PlayMode` / `Instrumented (Espresso)` / `CI Build Check` / `Device Smoke` / `Manual only` |
| **Source/Risk** | `git: <files>` + `commit: <hash range>` + `notion: <page/section>` + `risk: <category from taxonomy>` |

---

## Naming conventions

For automation candidates (when generating actual test stubs):

```kotlin
// Espresso / JUnit
@Test
fun should_<expectedBehavior>_when_<condition>() { ... }

// Example
@Test
fun should_showErrorDialog_when_loginCalledWithEmptyPassword() { ... }
```

For Unity test methods (PlayMode/EditMode):

```csharp
[Test]
public void Should_LoadContent_When_ValidJsonProvided() { ... }
```

Snake_case `should_X_when_Y` is intentional — it produces grep-friendly test names that read as sentences in CI output.

---

## What NOT to do

- **Do not** combine "valid login" and "invalid login" into one TC. One assertion per TC.
- **Do not** write Expected Results like "verify it works" or "user is satisfied". Always observable behavior.
- **Do not** assume device state. If the test requires a specific state, list it under Preconditions explicitly.
- **Do not** generate TCs for code paths that have no observable user-facing behavior (those go in unit tests, not in this skill's output).
- **Do not** copy the same Edge Case template to every TC. If there's no realistic edge case for a change, omit the row rather than padding.

---

## Granularity guidance

| Patch size | Expected TC count (Android only) |
|---|---|
| Single bug fix, ≤ 5 files | 3–8 TCs |
| New small feature, ≤ 20 files | 8–20 TCs |
| Major feature / refactor, ≤ 100 files | 20–50 TCs |
| Large patch, > 100 files | Stop and ask user to scope. Do not generate 200+ TCs in one pass. |

If the skill is about to generate more than ~30 TCs in a single invocation, it should pause and ask the user to confirm the scope or split into batches.

---

## Project-specific extension

This file is generic. Project-specific Android details (your Unity version, target API level, your specific low-end device, your build commands) live in `CLAUDE.md` — not here.

When the skill runs, it reads BOTH this file (for general rules) AND the downstream project's CLAUDE.md (for project facts). The combination produces TCs that follow good practice AND fit the actual project.
