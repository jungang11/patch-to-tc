# AGENTS.md — Cross-agent working rules

This file is a lightweight compatibility layer for coding agents other than Claude Code (e.g., Codex CLI, Gemini CLI, OpenCode). The Agent Skills standard at agentskills.io is portable across these tools, and `AGENTS.md` is the conventional name many of them look for at session start.

> **For v0.1, Claude Code is the primary target.** This file exists so that if another agent opens this repo in the future, it doesn't fly blind. Most of the depth lives in `CLAUDE.md`.

---

## If you are NOT Claude Code

1. Read `CLAUDE.md` — even though it is "Claude-flavored," most of its content (design constraints, what-goes-where, working mode) applies to you too.
2. The skill at `.claude/skills/mobile-build-tc-from-diff/` is designed for Claude Code's project skill discovery. The Agent Skills format (SKILL.md with YAML frontmatter + markdown) is the open standard, so the **content** transfers — but Claude-Code-specific frontmatter fields (`disable-model-invocation`, `allowed-tools`, `argument-hint`) may behave differently or not at all in your environment.
3. Honor the same design constraints listed in `CLAUDE.md`. They are not Claude-specific; they are good harness design.

---

## What does NOT transfer cleanly to other agents

| Feature | Claude Code | Codex CLI | Gemini CLI |
|---|---|---|---|
| `.claude/skills/` auto-discovery | ✅ | ❌ (uses `.agents/skills/` or its own path) | ✅ via `activate_skill` |
| `disable-model-invocation` | ✅ | unknown | unknown |
| `allowed-tools` pre-approval | ✅ | different mechanism | different mechanism |
| Dynamic context injection (`` !`cmd` ``) | ✅ | unknown | unknown |
| MCP support | ✅ | ✅ | ✅ |

If you are running this repo through a non-Claude agent and something fails, fall back to: open `SKILL.md` manually, follow the steps as a written procedure, and use your agent's native tools for git diff / Notion access.

---

## v0.2 plans (not implemented)

- `.agents/skills/` mirror of the Claude skill, with Codex-compatible frontmatter
- `docs/codex-portability.md` documenting what changes and why
- Cross-agent eval matrix

These are deliberately out of scope for v0.1. The principle: prove the harness works in one environment before claiming it works in many.
