# CLAUDE.md — Working rules for THIS repository

This file is read by Claude Code at the start of every session. It is the working agreement between you and Claude for **how to build this repo**, not how the resulting skill operates downstream.

> If you are using this repo as a downstream user (you cloned the skill into your project), this file does NOT apply to you. Use `.claude/CLAUDE.md.example` as your starting point instead.

---

## What this repo is

`mobile-tc-harness` is a public template repository for a Claude Code project skill that generates mobile app test cases from git diff + (optional) Notion patch notes. The goal is a **portable, learning-quality artifact** — not a one-click product.

The repo is currently at **v0.1 bootstrap**: most files contain placeholder structure that you (Claude) will fill in. Your job is to research the reference repos, then write the skill, references, scripts, and evals.

---

## Working mode — read this first

1. **Plan mode by default.** Use `Shift+Tab` to enter plan mode for any task that creates or modifies more than one file. Show me the plan and wait for approval before writing.

2. **Read before writing.** Before creating any file, you must:
   - Read `docs/REFERENCES.md` for the list of reference repos
   - Use `WebFetch` to actually pull the linked SKILL.md files (do NOT rely on training-data memory of these repos — there are reported failure cases of overconfident summarization from titles alone, e.g., [issue #50999](https://github.com/anthropics/claude-code/issues/50999))
   - Read any sibling files in this repo that already exist

3. **One step at a time.** Do not generate the entire skill in one pass. The intended sequence is documented in `docs/eval-strategy.md` under "Build sequence". Stop at each checkpoint for me to review.

4. **`/clear` between phases.** After completing a phase, I will run `/clear` and start a fresh session in a different role (writer → reviewer → security auditor). Do not assume your output is correct just because you wrote it.

5. **No silent assumptions.** If a design question is ambiguous, ask. Do not pick the most plausible interpretation and proceed.

---

## Design constraints (non-negotiable)

These come from upstream documentation and prior agreement. Do not relitigate them.

| Constraint | Source |
|---|---|
| SKILL.md body < 500 lines | Anthropic Skill best practices |
| `name`: lowercase, hyphens, ≤ 64 chars | Skill frontmatter spec |
| `description`: third person, ≤ 1024 chars, includes "what" + "when to use" | Skill frontmatter spec |
| Use `disable-model-invocation: true` for Notion-writing workflows | This skill can write to Notion; auto-invocation is unsafe |
| `allowed-tools` is **pre-approval**, NOT a security sandbox | Anthropic docs explicitly note this |
| Android-first, iOS-prepared | Per project requirements |
| Never merge Android + iOS into a single TC row | Per project requirements |
| Notion content is **context**, not source of truth | If `git diff` and Notion disagree, flag the disagreement |
| TCs must include a `Source/Risk` column referencing git files + commit + Notion sections | Auditability requirement |

---

## What goes where (CLAUDE.md vs SKILL.md split)

This is one of the most important design rules. Follow it strictly.

| Goes in `CLAUDE.md` (project-specific facts, always-loaded) | Goes in `SKILL.md` (reusable procedure, triggered) |
|---|---|
| Unity version, render pipeline | TC generation steps |
| Android build command, output type | Risk taxonomy (Android vs iOS vs Unity changes) |
| Target device matrix | Output schema (table columns, required fields) |
| Folder structure of THIS specific project | Notion safety rules |
| Company / team QA policy | Workflow stages: collect → triage → generate → output |
| Local-only conventions | Any logic that applies to every mobile project |

**For this repo specifically**: the public `CLAUDE.md` (this file) holds the meta-rules above. The `.claude/CLAUDE.md.example` holds the **template** that downstream users will copy into their own projects.

---

## Reference repos (must read before designing)

See `docs/REFERENCES.md` for the full list with URLs and what to extract from each. Top three to read first:

1. **anthropics/skills** — `skills/template-skill/`, `skills/skill-creator/`, `skills/doc-coauthoring/SKILL.md`
2. **obra/superpowers** — `skills/writing-skills/SKILL.md` (TDD pattern for skills)
3. **anthropics/claude-code** — `plugins/plugin-dev/skills/skill-development/SKILL.md`

---

## Tools you have

- File creation / editing in this repo (full permission)
- `Bash` — but **read-only git operations only** (`git status`, `git log`, `git diff`, `git show`). Do NOT commit or push unless I explicitly say "commit". Use `git add` only after I review.
- `WebFetch` — use this to pull reference repos' SKILL.md files. Required, not optional.
- `Grep` / `Glob` — for searching within reference materials once fetched.

Do NOT use:
- Network calls outside the listed reference repos without asking
- Any MCP server (this repo's purpose is to define how to use Notion MCP, but the bootstrap itself doesn't need it)
- Plugin marketplaces / installers

---

## Output style

- Korean is fine when explaining to me; SKILL.md and references that ship to users should be **English** (these are public, and English is the de facto language of the Agent Skills ecosystem).
- Code blocks for shell commands.
- Tables for comparisons.
- No unnecessary preamble like "Great question!" — just answer.
- When you're uncertain about a fact (e.g., a specific frontmatter field), say so and verify via WebFetch or by reading the actual reference file.

---

## When you are stuck

If you find yourself about to:
- Write a file that you haven't been asked to create yet → stop, ask
- Use a feature you're not 100% sure exists in Claude Code → fetch the docs first
- Generate more than ~300 lines in a single pass → stop, break into a smaller step
- Justify a choice with "best practice" without a citation → stop, find the citation

These are the failure modes we are explicitly trying to avoid.

---

## Final note

I am the human (이동원, Dongwon Lee). I am learning harness engineering through this project, not just trying to ship a tool. When you explain decisions, prioritize **why** over **what**. The "what" is in the file; the "why" is what I need from you.
