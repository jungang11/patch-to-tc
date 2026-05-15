# Harness Engineering Notes

This document captures the **mental model** behind this repo. It is not a tutorial; it is the rationale for design choices made elsewhere in the codebase.

---

## The core claim

> **Agent = Model + Harness**

The model (Claude, GPT, Gemini) is commodity. Any team using Sonnet 4.6 or Opus 4.7 gets the same raw capability. **The harness — the configuration, tools, permissions, hooks, and feedback loops surrounding the model — is what produces differentiated output.**

LangChain demonstrated this empirically by changing only their harness (keeping the model fixed) and improving Terminal Bench 2.0 results from 52.8% to 66.5% — a 13.7-point jump from configuration alone.

This repo is an applied experiment in that idea, scoped to one concrete problem: turning mobile patch changes into test cases.

---

## The 5 harness layers (Claude Code-specific)

| Layer | What lives there | Our repo's instance |
|---|---|---|
| **Memory** | `CLAUDE.md`, `MEMORY.md` | `CLAUDE.md` (working rules), `.claude/CLAUDE.md.example` (downstream template) |
| **Tools** | MCP servers, built-in tools | Notion MCP (read patch notes, optionally write TCs), Bash (read-only git) |
| **Permissions** | `allowed-tools`, deny rules | `allowed-tools` in SKILL.md pre-approves git read commands |
| **Hooks** | PreToolUse / PostToolUse | (not used in v0.1 — could add a hook that runs evals on commit) |
| **Observability** | Session logs, evals | `.claude/skills/.../evals/` directory with trigger + functional eval YAMLs |

This split comes from harness engineering discussions in 2026 (most notably the public summaries by Addy Osmani and LangChain). The point of naming the layers is to make design choices **legible**: when something feels off, you can ask "which layer is wrong?" instead of randomly tweaking prompts.

---

## Progressive disclosure — why SKILL.md must stay small

Skills work in three loading tiers:

1. **Tier 1 (always loaded)**: YAML frontmatter `name` + `description`. ~80 tokens per skill.
2. **Tier 2 (loaded when triggered)**: SKILL.md body. Target: under 500 lines. Anthropic's official skills average ~2,000 tokens.
3. **Tier 3 (loaded on demand)**: files in `references/`, `scripts/`, `assets/`. Zero context cost until read.

If you put everything in SKILL.md, every triggered invocation costs full body tokens. If you split into `references/`, the agent only loads what it actually needs for the current task. That's why `references/tc-taxonomy.md` exists separately from SKILL.md — most invocations don't need the full taxonomy details.

**Practical rule**: when SKILL.md hits 400 lines, split. Move detail to `references/X.md` and replace it in SKILL.md with one line: "For X, see references/X.md."

---

## OODA loop — why the LLM is only part of the work

Skills implement an Observe → Orient → Decide → Act loop:

- **Observe**: collect git diff, read Notion (this is mostly tools, not model)
- **Orient**: classify changes against the risk taxonomy (model + references/tc-taxonomy.md)
- **Decide**: pick which TC types to generate (model + SKILL.md procedure)
- **Act**: write the output table (model + assets/template)

Three of the four phases are scaffolding — that's harness work. Only "Decide" is genuine model reasoning. The harness is doing most of the lifting.

---

## Why this matters for our project specifically

Without a harness, asking Claude "generate test cases for this patch" gets you generic output that QA can't trust because it has no traceability. With a harness:

- **Inputs are bounded**: git diff + Notion pages + commit range. Not "everything you can find."
- **Output is schematized**: Source/Risk column makes every TC auditable back to a file/commit/Notion section.
- **Failure modes are documented**: when Notion and git diff disagree, the disagreement itself becomes a TC, not a guess.
- **The skill is testable**: `evals/` lets us check whether the skill produces stable output across model versions.

Each of those properties comes from a specific harness layer. None of them come from prompting alone.

---

## What this project is teaching, beyond TC generation

Building this repo gives you four reusable abilities:

1. **Skill authoring**: SKILL.md / references / scripts / evals 4-layer structure
2. **Role separation**: "MCP for data, Skill for procedure, CLAUDE.md for project facts" — applies to any AI-in-the-loop workflow
3. **Validation discipline**: Claude A (writer) / Claude B (fresh reviewer) pattern via `/clear`, auto-eval via YAML
4. **Permission design**: pre-approval (`allowed-tools`) vs. automatic vs. manual (`disable-model-invocation`) — and which to use when

These transfer to any other AI-assisted engineering task you build. The TC generator is the worked example; the real artifact is the way of thinking.

---

## Further reading

- `docs/REFERENCES.md` — the actual reference repos and what to extract from each
- `docs/eval-strategy.md` — how we test that the skill works
- `docs/notion-mcp-safety.md` — read-vs-write, prompt injection, schema confirmation
