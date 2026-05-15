# Sample output: TC table

> Produced by `/mobile-build-tc-from-diff both release/v2.3.x..release/v2.4.0 notion-read`
> using the patch note + dev note + diff summary in the other example files.
> ⚠️ Fictitious sample. Not real test data.

This is the **target output format** of the skill. Reviewers and downstream users should look at this first to understand what success looks like.

---

## Summary

- **Total TCs**: 24
  - Android executable: 18
  - iOS Prepared: 6
- **By priority**: P0 = 7, P1 = 11, P2 = 5, P3 = 1
- **Cross-source flags**: 1 (patch note mentioned a Japanese localization fix; no matching change in diff — flagged for clarification)

---

## Android TCs

| TC ID | Type | Priority | Title | Preconditions | Steps | Expected Result | Automation Candidate | Source/Risk |
|---|---|---|---|---|---|---|---|---|
| AND-pass-001 | Build Gate | P0 | App boots after season pass v1→v2 migration | v2.3.x save file present on device | 1. Update app to v2.4.0<br>2. Launch app | App reaches main screen within 10s, no crash, season pass tab accessible | Manual + Device Smoke | git: SeasonPassMigrator.cs, SeasonPassData.cs<br>commit: a1b2c3d<br>notion: dev-note §1<br>risk: data-schema-change |
| AND-pass-002 | Smoke | P0 | Season 5 rewards display correctly after migration | v1 save with claimed s4 rewards | 1. Launch<br>2. Open season pass<br>3. View reward tiers | All s4 claims preserved, s5 tiers visible, no duplicate rewards | Instrumented (Espresso) | git: SeasonPassMigrator.cs<br>commit: a1b2c3d<br>notion: dev-note §1, patch-note "시즌 5"<br>risk: data-schema-change, duplicate-reward-history |
| AND-pass-003 | Edge | P1 | Corrupted v1 save handled gracefully | Manually corrupted save file | 1. Replace save with truncated JSON<br>2. Launch app | App shows error UI, no crash, recovery option presented | Instrumented (Espresso) | git: SeasonPassMigrator.cs<br>commit: a1b2c3d<br>risk: data-schema-change, error-recovery |
| AND-content-004 | Build Gate | P0 | Cold start content load completes | Fresh install, no cache | 1. Install app<br>2. Launch<br>3. Wait for main screen | Content list renders within 5s (low-end: 8s) | Device Smoke + CI Build Check | git: ContentLoader.cs<br>commit: 9f8e7d6<br>notion: dev-note §2, patch-note "콘텐츠 로딩"<br>risk: async-refactor, addressables-cache |
| AND-content-005 | Edge | P1 | Concurrent content load requests don't race | App in low-memory state | 1. Background 5 heavy apps<br>2. Launch SampleApp<br>3. Rapidly switch tabs that trigger loads | No duplicate loads, no orphaned UniTask warnings in logcat | Manual | git: ContentLoader.cs<br>commit: 9f8e7d6<br>risk: async-refactor, race-condition |
| AND-content-006 | Edge | P2 | Addressables cache miss handled | Clear Addressables cache before launch | 1. Clear cache (adb)<br>2. Launch app<br>3. Open content list | Content downloads with progress indicator, no error toast | Device Smoke | git: ContentLoader.cs<br>risk: addressables-cache |
| AND-referral-007 | Smoke | P1 | Referral entry screen reachable | Logged in account | 1. Open menu<br>2. Tap "친구 추천"<br>3. See entry screen | ReferralEntryView shown, input field focused | Instrumented (Espresso) | git: ReferralEntryView.cs, ReferralService.cs<br>commit: 5c4b3a2<br>notion: patch-note "친구 추천"<br>risk: new-feature |
| AND-referral-008 | Smoke | P1 | Valid referral code redemption | Test referral code "TESTCODE123" set up server-side | 1. Enter "TESTCODE123"<br>2. Tap redeem | Success toast, reward notification within 30s | Manual | git: ReferralService.cs<br>risk: new-feature, server-dependent |
| AND-referral-009 | Edge | P2 | Invalid referral code rejected | Logged in | 1. Enter "INVALID999"<br>2. Tap redeem | Inline error message, no reward, input cleared | Manual | git: ReferralService.cs<br>risk: server-dependent, input-validation |
| AND-referral-010 | Edge | P2 | Network failure during redemption | Airplane mode toggled mid-request | 1. Enter valid code<br>2. Tap redeem<br>3. Enable airplane mode within 1s | Retry-able error, no double-redemption when network returns | Manual | git: ReferralService.cs<br>risk: server-dependent, network-failure |
| AND-notif-011 | Smoke | P1 | Android 13+ notification permission prompted on first launch | Android 13+, app freshly installed | 1. Install<br>2. Launch<br>3. Wait for permission dialog | POST_NOTIFICATIONS prompt shown, accepting grants permission | Instrumented (Espresso) | git: AndroidManifest.xml, NotificationCategoryToggleManager.cs<br>commit: 6c5b4a3<br>notion: dev-note §4<br>risk: permission-flow, android-13 |
| AND-notif-012 | Regression | P1 | Android 12 and below: no new prompt | Android 12, app upgraded from v2.3.x | 1. Update to v2.4.0<br>2. Launch | No new permission prompt; existing notifications continue | Manual | git: AndroidManifest.xml<br>commit: 6c5b4a3<br>risk: permission-flow, android-version-split |
| AND-notif-013 | Smoke | P2 | Category toggles persist across restart | Logged in, permission granted | 1. Open notification settings<br>2. Toggle "이벤트" off<br>3. Kill app<br>4. Relaunch and verify | "이벤트" remains off after restart | Instrumented (Espresso) | git: NotificationCategoryToggleManager.cs<br>risk: persistence |
| AND-lifecycle-014 | Build Gate | P0 | Black screen fix verified — generic resume | Any screen open | 1. Press home<br>2. Wait 30s<br>3. Return to app | UI re-renders within 1s, no black screen | Device Smoke | git: AppLifecycleHandler.cs<br>commit: 8d7e6f5<br>notion: patch-note "검은 화면"<br>risk: lifecycle, broad-regression |
| AND-lifecycle-015 | Regression | P0 | Resume from camera intent | App invokes camera intent | 1. Open profile<br>2. Edit avatar<br>3. Take photo<br>4. Return to app | Avatar editor restored, no black screen | Manual | git: AppLifecycleHandler.cs<br>risk: lifecycle |
| AND-lifecycle-016 | Regression | P1 | Resume after deep background (1hr+) | App backgrounded for extended period | 1. Background app<br>2. Use phone for 1+ hour<br>3. Return | App restores state or shows clean re-entry, no crash | Manual | git: AppLifecycleHandler.cs<br>risk: lifecycle |
| AND-pass-017 | Regression | P2 | Reward claim idempotency under network retry | Server connection unstable | 1. Claim a reward<br>2. Force network toggle during request | Reward claimed exactly once, no duplicate | Manual | git: (server fix referenced)<br>commit: 8d7e6f5<br>notion: dev-note §5<br>risk: idempotency |
| AND-chat-018 | Regression | P3 | Login → chat message visibility | Account with active chat | 1. Logout<br>2. Login<br>3. Open chat | Recent messages visible within 3s of chat tab open | Manual | git: (chat handshake fix)<br>notion: patch-note "채팅 메시지"<br>risk: timing |

---

## iOS Prepared TCs

| TC ID | Type | Priority | Title | Preconditions | Steps | Expected Result | Automation Candidate | Source/Risk | Status |
|---|---|---|---|---|---|---|---|---|---|
| IOS-content-001 | Smoke | P1 | Content load on iOS after async refactor | iOS build available (future) | 1. Launch<br>2. Open content list | Renders within 5s, no Xcode console errors | XCUITest | git: ContentLoader.cs<br>risk: cross-platform-path-divergence, async-refactor | Prepared — not run |
| IOS-lifecycle-002 | Regression | P1 | iOS background/foreground after lifecycle change | iOS build | 1. Background app<br>2. Return | UI restored, no rendering issues | XCUITest | git: AppLifecycleHandler.cs<br>risk: iOS-lifecycle-difference | Prepared — not run |
| IOS-notif-003 | Smoke | P1 | iOS notification category flow | iOS build, iOS 15+ | 1. Launch<br>2. Approve push prompt<br>3. Verify categories registered with UNUserNotificationCenter | All 4 categories registered | XCUITest | git: NotificationCategoryToggleManager.cs<br>risk: APNS-vs-FCM, capability-change | Prepared — not run |
| IOS-pass-004 | Smoke | P1 | Season pass migration on iOS | iOS build with v1 iOS save | 1. Update<br>2. Launch<br>3. View season pass | Same migration outcome as Android | XCUITest | git: SeasonPassMigrator.cs<br>risk: data-schema-change | Prepared — not run |
| IOS-referral-005 | Smoke | P2 | Referral entry UI on iOS safe area | iOS build, notch device | 1. Open referral screen | Input field not obscured by notch / home indicator | XCUITest | git: ReferralEntryView.cs<br>risk: layout-iOS-specific | Prepared — not run |
| IOS-content-006 | Edge | P2 | iOS persistentDataPath behavior | iOS build | 1. Launch<br>2. Verify content cache path | Files written under correct sandbox directory | Manual | git: ContentLoader.cs<br>risk: cross-platform-path-divergence | Prepared — not run |

---

## Cross-source flags (where Notion and git disagree)

| Flag | Notion says | Git says | Suggested action |
|---|---|---|---|
| `localization-mismatch` | Patch note: "다국어 텍스트 누락 수정 (영어, 일본어)" | No locale file changes in diff | Confirm with dev team — possibly a backend text change not reflected in app commits, or PR was reverted |

---

## Notes for human reviewer

- **24 TCs** is on the upper end for a single review session. Consider splitting Build Gate + Smoke (run first) from Regression + Edge (run second pass).
- **Lifecycle TCs (AND-lifecycle-014/015/016)** have broad blast radius. If any of these fail, expect cascading failures elsewhere — run them early.
- **No automated unit tests** added in this PR (per dev note). The Automation Candidate column reflects what COULD be automated, not what is.
- **Cross-source flag** is the most important output. It's the kind of thing a human reviewer might miss but the skill caught by cross-checking patch note vs. diff.
