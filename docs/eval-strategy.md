# Eval Strategy

This document defines (a) the sequence in which the repo is built, (b) how each phase is validated, and (c) how `evals/` files are structured and run.

---

## Build sequence (v0.1)

Each phase ends with a checkpoint. Do not proceed until the previous checkpoint is approved.

### Phase 1 — Research synthesis (no files created)

- Claude `WebFetch`es every URL in `docs/REFERENCES.md`
- Claude produces (in chat) the four deliverables listed in `docs/REFERENCES.md` "What to do with what you read"
- Human reviews and approves

**Checkpoint 1**: human says "go" → proceed to Phase 2.

### Phase 2 — Skeleton

- Create `.claude/skills/mobile-build-tc-from-diff/SKILL.md` with frontmatter only + a stub body listing intended sections
- Create empty placeholder files in `references/` (filenames only, with one-line description at top of each)
- Show the file tree to human

**Checkpoint 2**: human reviews skeleton → proceed.

### Phase 3 — SKILL.md body

- Fill in the SKILL.md body (workflow steps, constraints, output format)
- Keep under 400 lines
- Reference `references/*.md` files even though they're stubs

**Checkpoint 3**: human reviews SKILL.md → proceed.

### Phase 4 — references/

- Fill in each `references/*.md` file
- `tc-taxonomy.md` (the risk classification)
- `notion-context-policy.md` (the safety rules, in skill voice)
- `notion-output-schema.md` (the database mapping)
- `pairwise-strategy.md` (TC reduction strategy for high-combination changes)

**Checkpoint 4**: `/clear` and start Phase 5 with fresh context.

### Phase 5 — scripts/

- `collect_diff_context.sh` — shell script that gathers git log, git diff, file list, ready for SKILL.md to consume
- Idempotent, no side effects beyond stdout
- Tested with: `bash collect_diff_context.sh HEAD~1..HEAD`

**Checkpoint 5**: script runs cleanly on this repo → proceed.

### Phase 6 — examples/

- `sample-patch-note.md`, `sample-dev-note.md`, `sample-diff-summary.md` (all fictional, generic placeholder data)
- `sample-output-tc-table.md` showing what the skill should produce given those inputs

**Checkpoint 6**: examples are internally consistent.

### Phase 7 — evals/

- `trigger-evals.yaml` — test cases for whether the skill **activates** on the right prompts
- `functional-evals.yaml` — test cases for whether output **matches expected structure**

**Checkpoint 7**: human reviews → repo ready for first real run.

### Phase 8 — Dogfood

- Human runs `/mobile-build-tc-from-diff android HEAD~3..HEAD` against this repo's own commits
- Output is reviewed
- Failures captured back into `evals/` for future iteration

This phase is permanent — every time the skill misfires in real use, the failure becomes a new eval case.

---

## Role separation via `/clear`

Same Claude instance evaluating its own work is overly generous. Use `/clear` between roles:

### Session A — Writer
- Reads references
- Writes files
- Output: file changes, summary of choices

`/clear`

### Session B — Reviewer
- Reads files Session A produced, with no memory of why
- Tries to use the skill end-to-end on a mock input
- Reports: what's unclear, what's missing, what assumes context not in the files

`/clear`

### Session C — Security auditor
- Reads only with these questions in mind:
  - Is any real company / project / personal data in here?
  - Are there real Notion URLs, real keystore paths, real account IDs?
  - Could the skill be tricked into reading more than it should?
  - Could the skill be tricked into writing where it shouldn't?
- Output: list of leaks (must fix) and risks (worth noting)

This pattern comes from `obra/superpowers/skills/writing-skills/SKILL.md` — TDD for skills. It works because each role has different priors and catches different mistakes.

---

## `trigger-evals.yaml` — does the skill activate?

YAML format. Each entry is a user prompt + whether the skill SHOULD trigger.

```yaml
- prompt: "이번 패치노트 기반으로 빌드 테스트 TC 만들어줘"
  should_trigger: true
  reason: "Explicit TC generation request mentioning patch notes"

- prompt: "오늘 날씨 어때"
  should_trigger: false
  reason: "Unrelated to mobile testing"

- prompt: "Generate test cases from main..HEAD"
  should_trigger: true
  reason: "Explicit commit range, English equivalent"

- prompt: "코드 리뷰 해줘"
  should_trigger: false
  reason: "Code review is a different task — would conflict with code-review skills if both fire"
```

These exist because skill description quality directly determines routing accuracy. If trigger evals fail, fix the `description:` field in SKILL.md, not the user's prompts.

---

## `functional-evals.yaml` — does the output match expectations?

Each entry is a mock input + assertions about what the output must contain.

```yaml
- id: scriptableobject-json-change
  description: "Patch changes how content JSON is loaded"
  inputs:
    diff_summary: "Modified Assets/Scripts/ContentLoader.cs and Assets/Data/contents.json"
    commit_messages:
      - "Switch content load to async JSON parsing"
    patch_note: "Faster content loading"
    dev_note: "Replaced sync IO with async; backward compat preserved for v1 saves"
  must_include:
    - "missing key handling test"
    - "fallback to default content test"
    - "Android content path validation"
    - "iOS Prepared row tagged 'cross-platform-path-divergence'"
    - "automation candidate label on every row"
    - "Source/Risk column populated for every TC"
  must_not_include:
    - "Android and iOS combined in one row"
    - "TC for code that has no observable user behavior"
    - "Real Notion URL"
```

---

## How to run evals

For v0.1, evals are **human-driven**:

1. Open a fresh Claude Code session in a sample-data directory
2. Paste the eval prompt
3. Manually compare output against `must_include` / `must_not_include`
4. Record pass/fail

For v0.2 (not in scope now): wire evals into a GitHub Action using the Claude Code SDK in non-interactive mode (`claude -p`). Inputs streamed in, outputs grep'd for assertions.

---

## When evals fail

| Failure | Likely cause | Where to fix |
|---|---|---|
| Skill doesn't trigger | Description too vague or doesn't match user phrasing | `SKILL.md` frontmatter `description` |
| Output missing a required field | SKILL.md output schema unclear | `SKILL.md` "Output format" section |
| Wrong risk classification | Taxonomy incomplete | `references/tc-taxonomy.md` |
| Combined Android + iOS rows | Constraint not enforced in SKILL.md | `SKILL.md` "Constraints" section, made explicit |
| Real data leaked | Examples used real values | `examples/*.md`, replace with generic placeholders |

The rule: **fix the file, not the prompt.** If a real user has to phrase their request a specific way to get good output, the skill is broken, not the user.

---

## Anti-patterns

- **Self-evaluation without `/clear`**: Same context, same biases. Will pass everything.
- **One eval per concept**: One example each for Android + iOS + Notion. Not enough variance to surface bugs.
- **Evals that test the model, not the skill**: "Does Claude know what unit tests are?" — yes, irrelevant. Test whether the skill produces YOUR schema.
- **Mocking too much**: If the mock input is unrealistic, output quality on real inputs won't be predictable. Mocks should look like real artifacts.
