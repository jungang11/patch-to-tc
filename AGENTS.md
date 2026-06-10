# AGENTS.md — Cross-agent working rules

This file is a lightweight compatibility layer for coding agents other than Claude Code (e.g., Codex CLI, Gemini CLI, OpenCode). The Agent Skills standard at agentskills.io is portable across these tools, and `AGENTS.md` is the conventional name many of them look for at session start.

> **Claude Code is still the primary runtime.** This file exists so that if another agent opens this repo, especially Codex, it can follow the same procedure without relying on Claude-specific auto-discovery.

---

## If you are NOT Claude Code

1. Read `docs/codex-portability.md` first. It is the adapter runbook for non-Claude agents.
2. Read `.claude/skills/mobile-build-tc-from-diff/SKILL.md` as the canonical procedure.
3. Read `.claude/skills/mobile-build-tc-from-diff/references/scenario-tc-template.md` before generating TC output. The expected style is feature/content + situation + success/failure handling, not generic QA boilerplate.
4. The skill at `.claude/skills/mobile-build-tc-from-diff/` is designed for Claude Code's project skill discovery. The Agent Skills format (SKILL.md with YAML frontmatter + markdown) is portable as content, but Claude-Code-specific frontmatter fields (`disable-model-invocation`, `allowed-tools`, `argument-hint`) may behave differently or not at all in your environment.
5. Honor the same design constraints listed in `CLAUDE.md`. They are not Claude-specific; they are good harness design.

---

## What does NOT transfer cleanly to other agents

| Feature | Claude Code | Codex CLI | Gemini CLI |
|---|---|---|---|
| `.claude/skills/` auto-discovery | ✅ | ❌ (uses `.agents/skills/` or its own path) | ✅ via `activate_skill` |
| `disable-model-invocation` | ✅ | unknown | unknown |
| `allowed-tools` pre-approval | ✅ | different mechanism | different mechanism |
| Dynamic context injection (`` !`cmd` ``) | ✅ | unknown | unknown |
| MCP support | ✅ | ✅ | ✅ |

If you are running this repo through a non-Claude agent and something fails, fall back to: open `SKILL.md` manually, follow the steps as a written procedure, and use your agent's native tools for git diff / Notion access. If Notion access is not available, ask the user to paste the patch note and developer note as Markdown.

---

## v0.2 plans (not implemented)

- `.agents/skills/` mirror of the Claude skill, with Codex-compatible frontmatter
- `docs/codex-portability.md` documenting Codex runbook and tool mapping
- Cross-agent eval matrix

These are deliberately out of scope for v0.1. The principle: prove the harness works in one environment before claiming it works in many.
