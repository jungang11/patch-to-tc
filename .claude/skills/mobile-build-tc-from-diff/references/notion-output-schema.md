# Notion Output Schema

This file defines how the skill maps its **internal TC fields** to the **downstream user's actual Notion database property names** at write time. SKILL.md Stage 5 (Output) consults this file whenever Notion mode is `notion-draft` or `notion-write`.

---

## The mapping problem

Notion databases are user-customized. The skill produces these internal fields:

- `TC ID`, `Platform`, `Type`, `Priority`, `Title`, `Preconditions`, `Steps`, `Expected Result`, `Automation Candidate`, `Source/Risk`, `Status`

The downstream user's database might have property names like `Test Case ID`, `OS`, `Category`, `Pri`, `Name`. The skill must **discover** the mapping at runtime, not hardcode it.

---

## Schema-confirmation protocol

Run this protocol every invocation, before any write call:

1. **Read hints from CLAUDE.md.** Look for a `Notion workspace` section in the **working-directory project's `CLAUDE.md` only**. Do not read parent-directory CLAUDE.md, global `~/.claude/CLAUDE.md`, or any nested CLAUDE.md — the global file may contain user identity (name, email) unrelated to Notion schema and reading it widens context unnecessarily.
2. **Fetch actual schema.** If hints are insufficient or absent, call `Notion:notion-fetch` on the target database to retrieve property names and types.
3. **Match fields** — exact match first, then close-match (e.g., "TC ID" ≈ "Test Case ID", "Platform" ≈ "OS"). Stop short of fuzzy matching; if a field has no clear match, treat it as unmatched.
4. **Show the proposed mapping** to the user as a Markdown table (`Internal field | DB property | Match type: exact / close / unmatched`). Wait for explicit confirmation.
5. **Abort if blocked.** If any required field has no match after user input, abort the write and produce Markdown output only. Do not auto-create properties.

The user can correct the proposed mapping in a single message ("use 'Test ID' instead of 'TC ID'"). Re-show the corrected mapping and wait again.

---

## Markdown-fallback schema (canonical)

When write fails or is not requested, the skill outputs Markdown using this fixed column order:

```
| TC ID | Type | Priority | Title | Preconditions | Steps | Expected Result | Automation Candidate | Source/Risk |
```

iOS Prepared rows append `Status: Prepared — not run` either as an extra column or as a leading row prefix. See `examples/sample-output-tc-table.md` for the canonical example.

---

## Property type expectations

For Notion write, the skill expects these property types on the target database. Type mismatches abort the write:

| Internal field | Expected Notion property type | Notes |
|---|---|---|
| `TC ID` | Title (text) **or** unique-id | Either acceptable; unique-id preferred for stable references |
| `Platform` | Select | Options must include `Android` and `iOS` |
| `Type` | Select | Options must include `Build Gate`, `Smoke`, `Regression`, `Edge` |
| `Priority` | Select | Standard `P0`/`P1`/`P2`/`P3` or `High`/`Mid`/`Low` accepted |
| `Title` | Rich text **or** Title (if `TC ID` uses unique-id) | |
| `Preconditions`, `Steps`, `Expected Result` | Rich text (multi-line) | Inline test data goes here when needed; no separate `Test Data` column |
| `Automation Candidate` | Checkbox **or** Select (`Yes`/`No`) | |
| `Source/Risk` | Rich text | Free-form to allow git path + commit + risk categories in one field. **Must not include**: environment variables, absolute filesystem paths outside the repo, API tokens/keys, user identity (name, email), or internal-only URLs. The skill is responsible for keeping this column strictly limited before any Notion write. |
| `Status` | Status property **or** Select | Required for `notion-draft` to set the row to `Draft` |

If any actual property has an incompatible type, abort the write and output Markdown.

---

## What NEVER to do

- Never modify existing rows.
- Never create properties on the database — schema ownership stays with the user.
- Never assume a property exists without fetching the schema first in the current invocation.
- Never write to a database the user did not explicitly target by URL in the current invocation.
- Never auto-retry a failed write. Report failure and stop; the user decides whether to retry.
