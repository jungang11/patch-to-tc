# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

For session-level internal notes, see `WORK_LOG.md`.

---

## [Unreleased]

### Considered (not yet implemented)
- xlsx / csv output option (Stage 5 extension or external converter script)
- Project-format branching (separate skill per domain, or `--format` option)
- Self-update mechanism (skill checks remote and prompts user on version mismatch; requires frontmatter write permission — security review needed)
- Eval cases (`evals/{trigger,functional}-evals.yaml` are scaffolding only)
- Downstream-adoption verification (real project trial with bootstrap script)

---

## [0.2.0] - 2026-05-18

Usability release. Adds one-line install/update via bootstrap scripts and removes the need to remember argument order when invoking the skill.

### Added
- `bootstrap.ps1` (PowerShell 7+) and `bootstrap.sh` (bash) — one-line installer that copies `.claude/skills/mobile-build-tc-from-diff/` into a downstream project. SHA-256 hash comparison skips unchanged files on re-run, so the same command serves both install and update.
  - Options: `-Force` / `--force` (skip prompts), `-WhatIf` (PowerShell) / `--dry-run` (bash).
  - Safety: refuses to target patch-to-tc itself; warns if target is not a git repository.
- SKILL.md Stage 1 step 0 — interactive argument prompt. When the user invokes `/mobile-build-tc-from-diff` without one or more of `platform`, `commit-range`, `notion-mode`, the skill asks via `AskUserQuestion` before proceeding.
  - `notion-write` is never offered as an interactive default — it requires explicit per-invocation user confirmation.

### Changed
- README.md Quick start rewritten with four explicit installation methods (bootstrap script / symlink / git submodule / user skill) in a comparison table, plus interactive invoke documentation and the update procedure.
- README.md Repository structure diagram now lists `bootstrap.ps1`, `bootstrap.sh`, and `CHANGELOG.md`.

---

## [0.1.1] - 2026-05-18

Stabilization release. No new features; addresses security gaps and clarity issues identified by an external security audit and a self-reviewer simulation that ran the skill end-to-end as a first-time reader.

### Security
- `references/notion-output-schema.md` Source/Risk row: explicit "Must not include" list (environment variables, absolute filesystem paths outside the repo, API tokens/keys, user identity, internal URLs). Prevents exfiltration-via-writeback through the free-form column.
- SKILL.md Anti-patterns "Real data in output": expanded to cover env vars, filesystem paths outside the repo, and user identity (name, email) extracted from local files.
- SKILL.md Constraints: explicit warning that `allowed-tools` is pre-approval, not a sandbox. Enforcement depends on the workflow rules in the file body.
- `docs/notion-mcp-safety.md`: confirmed the current `.gitignore` includes both `.mcp.json` and `.mcp.local.json`. Downstream forks must re-verify their own `.gitignore` retains these entries.
- `references/notion-output-schema.md` schema-confirmation protocol: limit CLAUDE.md hint reading to the working-directory project's `CLAUDE.md` only. Parent, global (`~/.claude/CLAUDE.md`), and nested CLAUDE.md files are explicitly excluded to prevent accidental ingestion of user identity unrelated to Notion schema.

### Fixed
- **Stage 1 input defaults** — explicit relationship between `platform` argument and output sections: `android` produces Android executable TCs only (no iOS Prepared section), `ios` produces only iOS Prepared, `both` produces both with the Stage 3 step 3 cross-platform filter.
- **Notion-mode-omitted behavior** — Stage 1 Notion fetch, Stage 4 cross-source verification against Notion claims, and Stage 5 Notion write are all bypassed when Notion mode is not specified; output is Markdown only and Cross-source flags reduce to diff-internal consistency.
- **Source/Risk commit-to-file mapping** — explicit extraction rule: commit hashes from `collect_diff_context.sh` "Commit messages (full)" section (`### <hash> — <subject>` format), file mapping from "Changed files (full list)" section (`git diff --name-status`).
- **Stage 3 iOS Prepared mirror criteria** — emit an iOS Prepared row only when the change involves an explicit cross-platform divergence axis (path resolution, lifecycle/suspend, safe-area, iOS-specific capability/permission, or platform-specific timing/memory). Android-only signals do not produce iOS Prepared rows.
- **Stage 2 TC count estimation** — explicit heuristic (2–4 TCs per matched category) for the scope check.
- **Stage 3 / Stage 5 cap-30 ordering** — explicit: when generation would exceed 30 TCs, pause before emitting any TC; render Markdown only after user-agreed scope.
- **Anti-pattern patch-note vs dev-note distinction** — patch-note claim unsupported by diff is a Cross-source flag; dev-note claim unsupported by diff produces a TC tagged `dev-note only, diff unverified` in Source/Risk.
- **Stage 4 "substantive claim" definition** — user-observable behavior, measurable performance change, specific bug fix, or permission/capability change. Release dates, copy variations, and document metadata are not substantive.
- **`scripts/collect_diff_context.sh` heuristic labels** vs taxonomy categories — labels are hints, not classifications. Always re-match files against canonical taxonomy.
- **Pairwise Edge separation** — `references/pairwise-strategy.md` anti-pattern: focused Edge TCs targeting specific failure modes stay separate from the pairwise scenario matrix.

### Removed (from frontmatter)
- `mcp__notion__notion-create-comment` — unused write capability; pre-approval would have exposed an exfiltration-via-writeback path.
- `mcp__notion__notion-search` — unused; the Notion read policy already requires user-named URLs, making search unusable in practice.

---

## [0.1.0] - 2026-05-18

Initial public template for the `mobile-build-tc-from-diff` Claude Code skill.

### Added
- `.claude/skills/mobile-build-tc-from-diff/SKILL.md` — 5-stage workflow: Collect → Triage → Generate → Cross-source verify → Output.
- `.claude/skills/mobile-build-tc-from-diff/references/` — `tc-taxonomy.md` (file-signal → category → TC types), `notion-context-policy.md` (skill-voice Notion safety rules), `notion-output-schema.md` (Notion DB property mapping protocol), `pairwise-strategy.md` (TC reduction heuristic).
- `.claude/skills/mobile-build-tc-from-diff/examples/` — `sample-patch-note.md`, `sample-dev-note.md`, `sample-diff-summary.md`, `sample-output-tc-table.md` (fictitious examples illustrating the canonical input/output shape).
- `.claude/skills/mobile-build-tc-from-diff/scripts/collect_diff_context.sh` — git context aggregation for Stage 1 (commit log, diff stat, file list, commit messages, heuristic file-level signals).
- `.claude/skills/mobile-build-tc-from-diff/evals/` — `trigger-evals.yaml`, `functional-evals.yaml` (scaffolding for validation cases).
- `.claude/CLAUDE.md.example` — template that downstream users copy into their project's `.claude/CLAUDE.md` and fill in project-specific facts (Unity version, build commands, target devices, QA policy).
- `docs/` — `REFERENCES.md` (reference repos consulted during design), `eval-strategy.md`, `android-tc-guidelines.md`, `ios-prepared-guidelines.md`, `notion-mcp-safety.md`, `harness-engineering-notes.md`.
- `CLAUDE.md` (this repo's working rules for Claude Code), `AGENTS.md` (cross-agent rules for Codex / future agents), `LICENSE` (MIT), `.gitignore`, `.github/ISSUE_TEMPLATE.md`.

### Design constraints (non-negotiable)
- SKILL.md frontmatter `disable-model-invocation: true` — the skill cannot be auto-invoked; explicit user slash command required (Notion write capability demands deliberate invocation).
- `allowed-tools` minimum-required: only `notion-fetch` and `notion-create-pages` for Notion (no search, no comment write); git is read-only (`status`, `diff`, `show`, `log`, `rev-parse`, `merge-base`).
- Android executable TCs and iOS Prepared TCs always go in separate sections — never one combined row.
- Each TC has exactly one validation purpose; compound steps split into separate TCs.
- Notion content is context, not source of truth — disagreement between patch note / diff / dev note is surfaced as a Cross-source flag (Stage 4), not silently resolved.
- TC count cap: 30 per invocation; scope decision required if exceeded.
- No real data in output (generic placeholders only).
- Notion writes are gated by schema-confirmation protocol; never modify existing rows; never alter database properties.

---

[Unreleased]: https://github.com/jungang11/patch-to-tc/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/jungang11/patch-to-tc/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/jungang11/patch-to-tc/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/jungang11/patch-to-tc/releases/tag/v0.1.0
