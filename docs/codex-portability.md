# Codex Portability

이 문서는 Claude Code 전용 project skill을 Codex에서 수동 절차로 실행하기 위한 adapter 문서다. 현재 저장소는 `.claude/skills/mobile-build-tc-from-diff/`를 canonical source로 둔다. `.agents/skills` mirror는 아직 만들지 않는다.

---

## Current Decision

| 옵션 | 결정 | 이유 |
|---|---|---|
| A. Adapter 문서만 제공 | 채택 | drift가 적고 기존 Claude skill을 그대로 검증할 수 있음 |
| B. `.agents/skills` mirror | 보류 | Claude/Codex 두 벌 문서가 어긋날 위험이 큼 |
| C. core spec + adapters 대개편 | 보류 | 지금은 프로젝트 분석/시나리오 TC 품질을 먼저 안정화해야 함 |

---

## Codex Invocation Pattern

Codex에서 아래처럼 요청한다.

```text
.claude/skills/mobile-build-tc-from-diff/SKILL.md를 절차 문서로 읽고 실행해줘.
특히 references/scenario-tc-template.md 양식을 따라 프로젝트를 먼저 분석하고,
<platform> <commit-range> 기준으로 모바일 빌드 TC를 Docs/QA/에 Markdown 파일로 만들어줘.
Notion은 사용하지 않고 diff와 로컬 문서만 봐줘.
```

Notion 문서가 있으면 URL을 주기보다, Codex 환경에서 Notion connector가 없을 수 있으므로 patch note/dev note 내용을 붙여 넣는 방식을 기본 fallback으로 둔다.

---

## File Reading Order

Codex는 자동으로 Claude skill을 발견하지 못할 수 있으므로 아래 순서대로 읽는다.

1. `.claude/skills/mobile-build-tc-from-diff/SKILL.md`
2. `.claude/skills/mobile-build-tc-from-diff/references/scenario-tc-template.md`
3. `.claude/skills/mobile-build-tc-from-diff/references/tc-taxonomy.md`
4. `.claude/skills/mobile-build-tc-from-diff/references/pairwise-strategy.md`
5. `.claude/CLAUDE.md` 또는 downstream 프로젝트의 project facts 문서
6. 변경 범위의 git diff / commit log

Notion write가 필요할 때만 `notion-context-policy.md`와 `notion-output-schema.md`를 읽는다.

---

## Tool Mapping

| Claude Code concept | Codex equivalent |
|---|---|
| Slash command `/mobile-build-tc-from-diff` | 사용자가 위 Invocation Pattern을 프롬프트로 명시 |
| `AskUserQuestion` | 필요한 값이 없으면 일반 질문으로 확인 |
| `Read` / `Glob` / `Grep` | Codex의 파일 읽기/검색 도구 또는 shell 기반 `rg` |
| `Bash(git diff*)` | 승인된 git read 명령 |
| `Write` | TC Markdown 파일만 생성 |
| Notion MCP | Codex connector가 있으면 사용, 없으면 사용자가 붙여 넣은 Markdown을 context로 사용 |

Codex는 Claude frontmatter의 `allowed-tools`, `argument-hint`, `disable-model-invocation`을 동일하게 해석한다고 가정하지 않는다. 본문 절차와 이 문서를 실제 계약으로 본다.

---

## Git Evidence Bundle

Codex는 bash script가 없거나 실행이 불편한 환경에서도 아래 정보를 직접 모은다.

```powershell
git status --short
git log --oneline <range>
git diff --stat <range>
git diff --name-status <range>
git log --format="### %h — %s%n%n%b%n%n---%n" <range>
git diff --unified=3 <range>
```

필요하면 변경 파일별로 commit mapping을 확인한다.

```powershell
git log --name-status --format="### %h — %s" <range> -- <path>
```

최종 TC의 `Source/Risk`에는 repo-relative path와 짧은 commit hash만 쓴다. 절대 경로, 사용자 이름, 내부 URL, 토큰은 쓰지 않는다.

---

## Codex Output Contract

Codex도 Claude skill과 같은 파일 산출물을 만든다.

```text
Docs/QA/TC_<YYYY-MM-DD>_<range-tag>.md
```

문서 안에는 최소한 아래 섹션이 있어야 한다.

1. Summary
2. Reverse-spec snapshot
3. Scenario coverage matrix
4. Android TCs 또는 iOS Prepared TCs
5. Cross-source flags
6. Notes for human reviewer

채팅에는 전체 TC 표를 덤프하지 말고 요약과 파일 경로만 남긴다.

---

## Known Gaps

- `.agents/skills` 자동 발견은 아직 지원하지 않는다.
- Notion MCP/connector 이름은 환경마다 다르므로 이 문서는 Notion 수동 붙여넣기를 기본 fallback으로 둔다.
- bash script와 PowerShell recipe가 완전히 같은 출력을 보장하지는 않는다. 중요한 것은 Stage 0~5가 요구하는 evidence를 빠뜨리지 않는 것이다.
