# mobile-tc-harness

A reusable harness for turning mobile app patches into test cases.
First implementation: Claude Code project skill for Android-first, iOS-ready TC generation.

모바일 앱 업데이트 변경사항을 테스트케이스로 변환하는 재사용 가능한 하네스입니다.
첫 구현체는 Claude Code project skill이며, Android 실행 TC와 iOS Prepared TC를 분리합니다.

---

## Why this exists

This project is an experiment in **harness engineering**: instead of asking an AI model to "make test cases" in a chat-like way, we define a repeatable workflow, input boundaries, risk taxonomy, output schema, and evaluation cases so the model can produce consistent QA artifacts.

The hypothesis: **Agent = Model + Harness**. The model is commodity. The harness — memory, tools, permissions, hooks, evaluation — is what differentiates output quality.

This repo is a worked example of that idea, applied to a concrete problem: turning git diffs + release notes into review-ready test cases for mobile builds.

---

## What you get

- A Claude Code project skill (`/mobile-build-tc-from-diff`) that reads git changes and (optionally) Notion patch notes, then produces both automated test stubs and manual QA checklists.
- Documentation explaining the design choices, so you can adapt it to your own project rather than copy-pasting.
- Example inputs/outputs so you can see what good looks like before running it on real data.

---

## Quick start

1. Clone this repo into a fresh directory (do **not** copy it on top of your existing project until you've read the customization guide).
2. Open it with Claude Code (`claude` in the directory).
3. Read `CLAUDE.md` and `docs/REFERENCES.md` to understand the design.
4. Copy `.claude/CLAUDE.md.example` to `.claude/CLAUDE.md` in your real project and fill in the placeholders (Unity version, build commands, target devices, etc.).
5. Copy `.claude/skills/mobile-build-tc-from-diff/` into your real project's `.claude/skills/`.
6. In your project, invoke the skill with `/mobile-build-tc-from-diff android HEAD~1..HEAD`.

---

## Repository structure

```
mobile-tc-harness/
├── README.md                    ← you are here
├── LICENSE                      ← MIT
├── AGENTS.md                    ← cross-agent working rules (Codex, future agents)
├── CLAUDE.md                    ← Claude Code's working rules for THIS repo
├── WORK_LOG.md                  ← session work log (read first in a new session)
├── .gitignore
├── docs/
│   ├── REFERENCES.md            ← reference repos to read before designing
│   ├── harness-engineering-notes.md
│   ├── android-tc-guidelines.md
│   ├── ios-prepared-guidelines.md
│   ├── notion-mcp-safety.md
│   └── eval-strategy.md
└── .claude/
    ├── CLAUDE.md.example        ← template for downstream projects
    └── skills/
        └── mobile-build-tc-from-diff/
            ├── SKILL.md
            ├── references/
            │   ├── tc-taxonomy.md
            │   ├── notion-context-policy.md
            │   ├── notion-output-schema.md
            │   └── pairwise-strategy.md
            ├── examples/
            │   ├── sample-patch-note.md
            │   ├── sample-dev-note.md
            │   ├── sample-diff-summary.md
            │   └── sample-output-tc-table.md
            ├── scripts/
            │   └── collect_diff_context.sh
            └── evals/
                ├── trigger-evals.yaml
                └── functional-evals.yaml
```

---

## Claude Code safety notes

This template is intended to be used as a **project skill** under `.claude/skills/`.

The skill uses `disable-model-invocation: true` because Notion write workflows should be manually invoked. Do not assume the same behavior when packaging this as a Claude Code plugin — there are open GitHub issues reporting that plugin skills and some subagent flows do not fully respect this behavior yet ([#22345](https://github.com/anthropics/claude-code/issues/22345)).

For now, the recommended installation method is direct project-skill usage:
`.claude/skills/mobile-build-tc-from-diff/`

`allowed-tools` in the skill frontmatter is used to **pre-approve** read-only git inspection commands. It is **not** a security sandbox. Use Claude Code permission deny rules if you need to block tools globally.

---

## Notion MCP

This skill expects a Notion MCP connection if you want to pull patch notes / developer notes as context. Setup uses Notion's official MCP server:

```bash
claude mcp add --transport http notion https://mcp.notion.com/mcp --scope project
```

The skill treats Notion content as **context, not source of truth**. If `git diff` and the patch note disagree, the disagreement itself is flagged as a risk in the TC output. See `docs/notion-mcp-safety.md`.

---

## What this is NOT

- **Not a chat prompt.** This is a structured skill with input boundaries, output schema, and evaluation cases.
- **Not a one-size-fits-all generator.** You will customize `CLAUDE.md` and `references/tc-taxonomy.md` for your project. The template tells you what to fill in.
- **Not a replacement for human QA.** TCs go to humans for review. Source/Risk columns make the AI's reasoning auditable.
- **Not production-tested at scale.** This is v0.1. Use it as a learning artifact and a starting point.

---

## License

MIT. See `LICENSE`.

---

## Contributing

This is a personal learning project. Issues and discussions welcome. PRs accepted if they keep the harness portable (no project-specific data).
