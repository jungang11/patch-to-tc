# Sample diff summary

> Output from `scripts/collect_diff_context.sh release/v2.3.x..release/v2.4.0`
> ⚠️ Fictitious sample. Not real code.
> ⚠️ **Abridged for reviewer convenience.** The actual script also outputs: full commit messages (`git log --format=...%b`), per-file `git diff --name-status` mapping, and detailed heuristic signals. Stage 3's Source/Risk column relies on the full per-commit / per-file mapping that this abridged sample omits — when generating TCs against a real diff, consult the actual script output, not this sample alone.

---

## Commit log (oneline, 120 commits)

```
e3f1a2c chore: bump version to v2.4.0
a1b2c3d feat(seasonpass): add SeasonPassMigrator for v1→v2 schema
9f8e7d6 refactor(content): switch ContentLoader to async with UniTask
5c4b3a2 feat(referral): add ReferralService and entry UI
8d7e6f5 fix(lifecycle): re-init GL context on resume to prevent black screen
6c5b4a3 feat(notification): per-category notification toggles
... (and 114 more)
```

## Diff stat

```
 Assets/Scripts/SeasonPass/SeasonPassData.cs            |  47 ++--
 Assets/Scripts/SeasonPass/SeasonPassMigrator.cs        |  89 +++++++ (new)
 Assets/Scripts/Content/ContentLoader.cs                | 134 ++++++---
 Assets/Scripts/Referral/ReferralService.cs             | 156 ++++++++++ (new)
 Assets/Scripts/Referral/ReferralEntryView.cs           |  72 ++++++ (new)
 Assets/Scripts/Notification/NotificationCategoryToggleManager.cs | 118 +++++ (new)
 Assets/Scripts/Lifecycle/AppLifecycleHandler.cs        |  23 ++-
 Assets/UI/Referral/ReferralEntryView.prefab            | 312 +++++ (new)
 Assets/UI/Notification/NotificationSettingsView.prefab |  88 ++--
 Assets/Data/SeasonPass/season5.asset                   | 245 +++++ (new)
 ProjectSettings/AndroidManifest.xml                    |   3 +
 13 files changed, 1289 insertions(+), 122 deletions(-)
```

## File-level classification (by extension/path heuristic)

| File | Category |
|---|---|
| `Assets/Scripts/SeasonPass/SeasonPassData.cs` | data-schema-change |
| `Assets/Scripts/SeasonPass/SeasonPassMigrator.cs` | new-file, migration-logic |
| `Assets/Scripts/Content/ContentLoader.cs` | core-loading-path |
| `Assets/Scripts/Referral/ReferralService.cs` | new-file, server-dependent |
| `Assets/Scripts/Notification/NotificationCategoryToggleManager.cs` | new-file, permission-related |
| `Assets/Scripts/Lifecycle/AppLifecycleHandler.cs` | lifecycle, OnApplicationPause |
| `Assets/UI/Referral/*.prefab` | new-UI |
| `Assets/Data/SeasonPass/season5.asset` | content-data |
| `ProjectSettings/AndroidManifest.xml` | android-manifest-change |

## Notable patterns detected

- ✅ Schema migration present (`SeasonPassMigrator.cs`) — migration path must be tested
- ✅ Sync → async refactor (`ContentLoader.cs`) — race condition risk
- ✅ Server-dependent feature (`ReferralService.cs`) — network failure modes
- ✅ Lifecycle handler change — broad regression surface (every screen)
- ✅ AndroidManifest change — permission flow review needed
- ⚠️ No tests added in diff (`*Test.cs` not present in new files) — note for QA prioritization
- ⚠️ No iOS-specific code changes detected — but `OnApplicationPause` and `Application.persistentDataPath` usage in ContentLoader may behave differently → iOS Prepared flags warranted

---

## How this maps to TC generation

The skill consumes this summary plus the patch note and dev note, then produces the output table shown in `sample-output-tc-table.md`.

Key signals the skill should extract from this summary:

1. **Migration logic** → 3+ TCs for v1→v2 data handling (happy path, edge case, corrupt save)
2. **Async refactor** → race condition tests, timeout tests, Addressables cache miss tests
3. **New UI screens** → smoke nav tests, accessibility/i18n checks
4. **Lifecycle changes** → regression sweep across major screens (highest blast radius)
5. **Manifest change** → permission grant/deny flow tests
6. **Cross-platform path code** → iOS Prepared rows with `cross-platform-path-divergence` flag
