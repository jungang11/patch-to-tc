# REFERENCES.md — What to read before you write

> **Instructions for Claude Code:** Before you write any file in `.claude/skills/`, you must `WebFetch` each URL listed below. Do not summarize from training-data memory — verify the actual current contents. If a URL is dead, note it and continue with the others.

These references are organized by what you should **extract**, not just what you should know.

---

## Tier 1 — Anthropic official (must read)

### 1. Skill format spec & best practices

| URL | What to extract |
|---|---|
| https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview | Exact frontmatter field rules (name length, description length, character restrictions). Progressive disclosure 3-tier model. |
| https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices | SKILL.md size limits (500 lines body). Description writing rules (third person, what + when). MCP tool naming (fully qualified). |
| https://code.claude.com/docs/en/skills | Project skill vs personal skill discovery paths. `allowed-tools` syntax (e.g., `Bash(git diff*)`). `disable-model-invocation` semantics. Dynamic context injection (`` !`cmd` `` syntax). |

### 2. Anthropic's own reference skills (read at least 3 SKILL.md files)

| URL | What to extract |
|---|---|
| https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md | How Anthropic teaches the model to write skills. Frontmatter style. |
| https://github.com/anthropics/skills/blob/main/skills/doc-coauthoring/SKILL.md | **Most important.** 3-stage workflow (Context Gathering → Refinement → Reader Testing). This pattern maps directly to our (collect → triage → generate → output) flow. |
| https://github.com/anthropics/skills/blob/main/skills/brand-guidelines/SKILL.md | How to encode team/company conventions as a skill without hardcoding them. |
| https://github.com/anthropics/claude-code/blob/main/plugins/plugin-dev/skills/skill-development/SKILL.md | The "skill that teaches you to write skills" — references/, scripts/, assets/ structure decisions. |

---

## Tier 2 — Community gold standard

### 3. obra/superpowers (Jesse Vincent, ex-Anthropic, MIT licensed, 3.7k+ stars)

| URL | What to extract |
|---|---|
| https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md | **TDD for skills.** Write pressure scenarios → watch agent fail without skill → write skill → watch tests pass. This is how we will structure `evals/`. |
| https://github.com/obra/superpowers/blob/main/skills/using-superpowers/SKILL.md | How to layer skills with CLAUDE.md instructions when they conflict. User-in-control principle. |
| https://github.com/obra/superpowers-skills | Two-tier structure: core skills (in plugin) vs personal skills (in `~/.config/superpowers/skills/`). Maps to our "shippable template" vs "downstream customization" split. |

### 4. shinpr/claude-code-workflows

| URL | What to extract |
|---|---|
| https://github.com/shinpr/claude-code-workflows | How they split `docs/plans/` (ephemeral, gitignored) vs `docs/prd/` `docs/adr/` (committed). Useful for thinking about what stays in repo. |

---

## Tier 3 — Domain (mobile QA, TC generation)

### 5. TestCollab — Claude Code + MCP for test case generation

| URL | What to extract |
|---|---|
| https://testcollab.com/blog/automated-test-case-generation-claude-code-mcp | The "code-change-based risk-based test planning" pattern. How they prompt for happy path + negative + edge cases per feature. |
| https://testcollab.com/claude-code-for-qa-testing | Six use cases for Claude Code in QA. Patterns for batch-size control ("start with 5 TCs, then expand"). |

### 6. Manual TC structure (QA industry standard fields)

| URL | What to extract |
|---|---|
| https://katalon.com/resources-center/blog/manual-test-case-template | Single-purpose principle: 1 TC = 1 validation. Required fields: ID / Title / Preconditions / Steps / Test Data / Expected Result / Status / Priority. |
| https://www.softwaretestinghelp.com/test-case-template-examples/ | Standard field examples. We'll use this to define our output schema. |

### 7. Notion MCP — official server (`makenotion/`)

| URL | What to extract |
|---|---|
| https://github.com/makenotion/notion-mcp-server | Setup commands. Auth model. Read/write scope distinction. |
| https://github.com/makenotion/claude-code-notion-plugin | Notion's own pattern: ship **Skills + MCP** as a bundle. Confirms that "MCP for data, Skill for procedure" is the official recommended split. |

---

## Tier 4 — Concept / background (skim, do not deep-read)

| URL | What to extract |
|---|---|
| https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills | Anthropic's own framing of progressive disclosure. One sentence: "skills load only relevant content into context." |
| https://dev.to/shipwithaiio/the-complete-claude-code-harness-engineering-guide-5-layers-8-deep-dives-3d4j | The 5-layer harness model (Memory / Tools / Permissions / Hooks / Observability). Use as mental model only. |
| https://www.langchain.com/blog/the-anatomy-of-an-agent-harness | Why the harness matters more than model choice. Background only. |

---

## What to do with what you read

After fetching these, before writing any file, produce in chat:

1. **A 1-paragraph synthesis** of the doc-coauthoring 3-stage workflow and how it maps to our (collect → triage → generate → output) flow.
2. **A list of frontmatter fields** you intend to use, each with a sentence on why and a citation.
3. **A delta list**: what we're doing differently from Anthropic's template-skill, and why.
4. **A risk list**: things from the references that LOOK applicable but actually don't fit our use case, and why we're rejecting them.

Then wait for approval before creating any file in `.claude/skills/`.

---

## Anti-patterns observed in references (do NOT copy)

- **Over-bundled skills**: some community repos bundle 30+ skills under one umbrella. Each skill description still loads ~80 tokens, so this bloats context. We want **one focused skill**.
- **Excessive scripts/**: scripts that just wrap a single shell command add complexity without value. Only create a script if it produces non-trivial transformation.
- **`references/` as a dumping ground**: every file in `references/` should answer a specific question the SKILL.md raises. If a file isn't referenced from SKILL.md, it should not exist.
- **Hardcoded company data in examples/**: every example must use generic placeholder data (e.g., "ExampleApp", "SampleProject"). Never real company names, real Notion URLs, real version numbers.
