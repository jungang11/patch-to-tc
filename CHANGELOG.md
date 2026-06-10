# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

For session-level internal notes, see `WORK_LOG.md`.

---

## [Unreleased]

### Added
- `references/scenario-tc-template.md`: canonical reverse-spec and scenario TC style. TCs now emphasize feature/content, situation, success path, failure/edge handling, staged mini-game progression, and backend result submission when relevant.
- SKILL.md Stage 0: lightweight project analysis / reverse-spec snapshot before TC generation. Final output now includes Reverse-spec snapshot and Scenario coverage matrix before detailed TC tables.
- `docs/codex-portability.md`: Codex adapter runbook for using the Claude skill as a procedure document when `.claude/skills` auto-discovery is unavailable.
- `.claude/CLAUDE.md.example`: new `Game / content map` and scenario coverage fields for content-heavy mobile games.
- `functional-evals.yaml`: new content-heavy mini-game scenario case that requires Reverse-spec snapshot, Scenario coverage matrix, staged progression, backend submission, retry, and duplicate-prevention coverage.
- **Stage 5 file output is now the default** (resolves the v0.2.0 design gap discovered during the first downstream trial). The skill saves the canonical Markdown to `<TC output directory>/TC_<YYYY-MM-DD>_<range-tag>.md` (default `Docs/QA/`) and echoes only a short summary + the file path to the chat. The previous behavior — full TC tables dumped into the conversation — burned conversation tokens and forced the user to hand-copy results into a file before they could be reused.
- SKILL.md frontmatter: `Write` added to `allowed-tools` (required for file save). Scope is explicitly limited to TC output only — see Constraints and Anti-patterns sections.
- `.claude/CLAUDE.md.example` QA policy section: new `TC output directory` field (default `Docs/QA/` if absent or left as placeholder).
- New SKILL.md anti-pattern: "Dumping the full TC tables into the chat instead of (or in addition to) the file."
- New SKILL.md anti-pattern: "Writing files outside the intended TC output directory."
- New SKILL.md anti-pattern: "Internal implementation detail in Expected Result." Expected Result is for QA-observable outcomes; engine-side detail (ONNX file names, internal method names, library versions) belongs in Steps or Notes. From first downstream trial external review.
- New SKILL.md anti-pattern: "Mismatched Automation Candidate column and Notes." If Notes says a TC is an automation candidate, the column must reflect that — same decision, two surfaces. From first downstream trial external review.
- SKILL.md Output format §3 (iOS Prepared TCs): explicit clarification that the `Status: Prepared — not run` value is a **category marker**, not a progress tracker. Per-execution progress (pass/fail/blocked) belongs in a separate checklist, kept distinct from the immutable TC definition tables.
- `bootstrap.ps1 -SetupClaudeMd` and `bootstrap.sh --setup-claude-md` options. When set, the bootstrap script also copies `.claude/CLAUDE.md.example` to the target's `.claude/CLAUDE.md`, but only if no `CLAUDE.md` exists there yet (existing files are never overwritten). Streamlines first-install onto a new downstream project.

### Changed
- README Quick start §3 (customize CLAUDE.md): now documents the `-SetupClaudeMd` / `--setup-claude-md` "easiest path" alongside the manual copy fallback.
- README Quick start §5 (Updating later): explicit "no automatic update notification" note. The skill does not check the remote on its own — adding that would require an external-fetch permission, which the v0.1.1 security tightening explicitly avoided. See `docs/v0.3-design.md` §3.
- `evals/{trigger,functional}-evals.yaml`: added coverage for v0.1.1/v0.2.0 behavior (interactive arg prompt, dev-note-only TC, non-substantive claim, Source/Risk leak prevention) and boosted existing cases (small-bugfix iOS-row absence, lifecycle iOS Prepared presence).
- `docs/v0.3-design.md` (new): trade-off analysis for xlsx/csv output, project-format branching, and self-update. Decisions: xlsx/csv and format-branching deferred to v0.4 (Option B in both cases); self-update rejected to preserve v0.1.1 security tightening.

### Considered (deferred or rejected — see docs/v0.3-design.md)
- xlsx / csv output — Option B (external converter `scripts/md_to_csv.py`) preferred; deferred to v0.4 pending downstream demand. **Note**: the `.md` file-save part of this design has been split out and shipped now (see Added section above) — only the xlsx/csv conversion step is still deferred.
- Project-format branching — Option B (separate skill per domain) preferred; deferred until non-mobile demand emerges.
- Self-update mechanism — rejected. Manual `git pull` + bootstrap re-run remains the only update path; README §5 documents this.

### Open
- Eval cases (cases now filled, but actual execution against real projects still pending — v0.1 manual eval format).
- Downstream-adoption verification (real project trial with bootstrap script).
- Tag push: local `v0.1.0` / `v0.1.1` / `v0.2.0` annotated tags are not yet pushed.

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
