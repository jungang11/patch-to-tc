# Work Log

작업 일지. 새 세션 시작 시 가장 먼저 읽기.
Claude Code 세션은 로컬 머신 단위로 저장됨(`~/.claude/projects/...`) — 다른 머신에서는 이전 세션을 볼 수 없으므로 컨텍스트 복구는 이 파일이 담당.

시간 기록은 절대 날짜로.

---

## 2026-05-22 — 프로젝트 분석/시나리오 TC 양식 반영

### 의도

사용자 목표를 "diff 기반 TC 생성"에서 한 단계 확장: 임의의 모바일 게임 프로젝트를 먼저 가볍게 분석/역기획하고, 기능/콘텐츠/미니게임별로 "어떤 상황에서 성공/실패가 어떻게 보여야 하는지" 중심의 정량 TC를 뽑도록 문서와 skill 절차를 보강.

### 적용한 방향

| 옵션 | 판단 |
|---|---|
| A. 가이드 문서만 추가 | 너무 약함. SKILL이 안 읽으면 실제 출력이 안 바뀜 |
| B. 양식 문서 + SKILL 단계 연결 | 채택. 기존 slash command 유지하면서 출력 스타일을 바꿀 수 있음 |
| C. Claude/Codex core spec 대개편 | 보류. 구조 개편보다 TC 품질 축을 먼저 고정 |

### 변경 내용

- `references/scenario-tc-template.md` 신규: Reverse-spec snapshot, Scenario coverage matrix, 기능/상황/성공/실패 TC 작성 규칙, 미니게임/콘텐츠 다건 변경 시 최소 커버리지와 batch 기준.
- SKILL.md Stage 0 추가: project facts/docs/scene/prefab/script 구조를 근거로 짧은 역기획 스냅샷을 만든 뒤 TC 생성.
- SKILL.md Stage 3/5 갱신: Scenario coverage matrix를 상세 TC 앞에 출력하고, 콘텐츠/미니게임별 상황을 flatten하지 않도록 명시.
- `.claude/CLAUDE.md.example`에 `Game / content map` 추가: 메인 루프, 미니게임, 단계, 결과/보상, backend submission, 실패 시나리오를 downstream 프로젝트별로 기록.
- `docs/codex-portability.md` 신규: Codex에서 `.claude/skills` 자동 발견 없이 SKILL.md와 scenario template을 절차 문서로 읽어 실행하는 runbook.
- `sample-output-tc-table.md`에 Reverse-spec snapshot / Scenario coverage matrix 예시 추가.
- `functional-evals.yaml`에 미니게임 단계 진행 + backend submission 시나리오 케이스 추가.
- README/AGENTS/CHANGELOG 동기화.

### 남은 판단

- `.agents/skills` mirror는 아직 보류. 지금은 `docs/codex-portability.md` adapter 방식으로 drift를 줄임.
- Windows/PowerShell 전용 diff 수집 스크립트와 TC lint gate는 별도 후속 후보.

---

## 2026-05-22 — downstream 프로젝트 경로 registry 추가

### 의도

coggames_Unity6 / bomphago_Unity6처럼 이미 bootstrap으로 설치한 downstream 프로젝트들을 이후 patch-to-tc 세션에서 반복 업데이트하기 쉽게 로컬 경로 registry를 둠.

### 결정

| 옵션 | 판단 |
|---|---|
| 실제 경로를 tracked docs에 저장 | 거부. 회사/개인 로컬 경로 노출 위험 |
| gitignored local registry만 사용 | 채택 |
| 별도 스크립트로 일괄 업데이트까지 자동화 | 보류. 먼저 문서/registry 방식으로 충분 |

### 변경

- `docs/downstream-projects.md` 신규: registry 양식과 업데이트 요청 문구, bootstrap 실행 규칙 설명.
- `downstream-projects.local.md` 신규: gitignored 로컬 파일. 사용자가 실제 경로를 직접 채우는 위치.
- `.gitignore`에 `downstream-projects.local.md`, `docs/downstream-projects.local.md` 추가.
- README에 여러 downstream 프로젝트 관리 섹션 추가.

---

## 2026-05-15 — v0.1 안정화 세션

### 완료된 commits (origin/main push 완료)

| Hash | 의도 |
|---|---|
| `0376a05` | v0.1 bootstrap + 초기 보안/명확화 패치 (25 files) |
| `0660311` | 보안 보강 (R3 Source/Risk 컬럼 / R5 allowed-tools 경고 / R6 .gitignore 검증) |
| `074143a` | 명확화 보강 (script label 매핑 / pairwise Edge 분리 / substantive 정의) |

### 세션 입력

이 세션은 두 가지 input을 통합 처리:
1. **외부 보안 감사** (다른 세션 결과 import) — 2 LEAKS + 6 RISKS
2. **reviewer 시뮬 셀프 검증** — SKILL.md를 처음 보는 reviewer가 mock 패치를 처리하며 식별한 9개 막힘

### 처리 결과 — 보안 측

| ID | 항목 | 처리 |
|---|---|---|
| L1 | `mcp__notion__notion-create-comment` 미사용 권한 | 제거 (`0376a05`) |
| L2 | `mcp__notion__notion-search` 정책-도구 불일치 | 제거 (`0376a05`) |
| R3 | Source/Risk 컬럼 free-form text exfil 가능 | "Must not include" 룰 명시 (`0660311`) |
| R4 | notion-output-schema CLAUDE.md 읽기 범위 | working-directory only로 제한 (`0376a05`) |
| R5 | allowed-tools는 pre-approval, sandbox 아님 | SKILL.md Constraints 경고문 (`0660311`) |
| R6 | .gitignore가 `.mcp.*` 차단한다는 가정 | v0.1 확인됨 + fork 시 재검증 안내 (`0660311`) |
| R1 | suspicious content 판단 기준 부재 | 모델 행동 영역, 별도 보강 효과 제한적 → 보류 |
| R2 | property poisoning mitigation 추상적 | Bash read-only로 defense in depth 닫힘 → 보류 |

### 처리 결과 — reviewer 시뮬 측 (9개 막힘)

| # | 막힘 | 처리 |
|---|---|---|
| 1 | Stage 1 인수 default (platform/Notion mode) | 부분 해소 (iOS mirror 룰로 간접) |
| 2 | script label vs taxonomy 매핑 | 명시 (`074143a`) |
| 3 | TC types 추정 휴리스틱 | 추가 (`0376a05`) |
| 4 | iOS Prepared mirror 선별 기준 | 명시 (`0376a05`) |
| 5 | pairwise Edge 분리 | anti-pattern 추가 (`074143a`) |
| 6 | Source/Risk commit→file 매핑 | sample 디스클레이머로 부분 해소 |
| 7 | substantive claim 정의 | 명시 (`074143a`) |
| 8 | anti-pattern patch note vs dev note 구분 | 명시 (`0376a05`) |
| 9 | Stage 5 / Stage 3 cap 순서 충돌 | 명시 (`0376a05`) |

### 작성자 자체 점검 결과

다른 세션 감사가 "외부 식별 불가, 작성자 자기 점검 권장"한 sample 파일 placeholder 8개 항목 — 본인 점검 결과 **모두 일반적 패턴이라 교체 불필요**.

---

## 2026-05-18 — 부분 해소 #1+#6 마무리

### 신규 commit (이번 패치)

SKILL.md에만 3개 Edit. 어제 세션에서 "부분 해소"로 남았던 reviewer 시뮬 막힘 #1, #6을 완전 해소.

- **#1 마무리** — Inputs 섹션
  - Platform argument와 출력 섹션 관계 명시: `android` = Android only (iOS Prepared section 미생성), `ios` = iOS Prepared only, `both` = 양쪽 with Stage 3 step 3 cross-platform 필터.
  - Notion mode 미지정 시 동작 명시: Stage 1/4/5 Notion 동작 모두 bypass, Markdown only, Cross-source flags는 diff 내부 일관성 점검으로 축소.
- **#6 마무리** — Stage 3 step 2
  - Source/Risk 컬럼의 commit hash는 `collect_diff_context.sh` 출력의 "Commit messages (full, not truncated)" 섹션에서 `### <hash> — <subject>` 형식으로 추출.
  - file 매핑은 "Changed files (full list)" 섹션의 `git diff --name-status`.
  - 한 파일에 여러 commit이 걸치면 콤마로 나열.

### 결과

9개 reviewer 시뮬 막힘 전부 해소 (부분 해소 0건, 완전 해소 9건).

---

## 2026-05-18 (이어서) — v0.2 사용성 개선

### 의도

다운스트림 사용자가 patch-to-tc를 자기 프로젝트에 통합하기 쉽게. 사용자가 그린 그림: clone → 한 줄 부트스트랩 → 인자 없이 슬래시 명령 → 인터랙티브 prompt → TC 생성.

### 신규 commit 3개

| Hash | 의도 | 파일 |
|---|---|---|
| `9929c57` | tools: bootstrap scripts | bootstrap.ps1, bootstrap.sh (신규) |
| `9beba80` | skill: interactive argument prompt | SKILL.md Stage 1 step 0 추가 |
| (이번) | docs: Quick start rewrite | README.md (Quick start + structure) + WORK_LOG.md |

### 처리 내역

- **bootstrap.ps1 / bootstrap.sh** — SHA-256 비교 기반 skill 복사/갱신 스크립트. 양쪽 동일 동작. `-Force` / `--force`, `-WhatIf` / `--dry-run` 옵션. 타겟이 patch-to-tc 자체면 거부 / git repo 아니면 경고.
- **SKILL.md Stage 1 step 0** — 인자 미지정 시 `AskUserQuestion`으로 사용자 의도 묻기. `notion-write`는 인터랙티브 옵션에 포함 안 함 (안전).
- **README.md Quick start** — 4가지 설치 방식 비교표 (bootstrap / symlink / submodule / user skill) + 부트스트랩 가이드 + 인터랙티브 invoke 안내 + 업데이트 방법. Repository structure에 bootstrap.* 추가.

### chicken-and-egg 한계 (해결 안 됨, 설계상)

skill이 자기 자신을 설치할 수는 없으므로 1회 부트스트랩은 수동. bootstrap.ps1/sh로 그 1회를 한 줄로 단축. 이후 갱신도 같은 명령 재실행 — 사용자가 패치 받았을 때는 `git pull && .\bootstrap.ps1 -TargetProject ...` 두 줄로 끝.

### 추가: CHANGELOG.md 도입

외부 reader용 변경 이력. Keep a Changelog 형식, v0.1.0 / v0.1.1 / v0.2.0 / Unreleased 분리. README structure 다이어그램에도 CHANGELOG.md 추가. commit `285d035`.

### 추가: git tag 3개 (annotated, local)

- `v0.1.0` → `0376a05` (Initial public template)
- `v0.1.1` → `0dbe6e5` (Stabilization)
- `v0.2.0` → `1b79aab` (Usability)

push 시 별도 (`git push origin v0.1.0 v0.1.1 v0.2.0` 또는 `--follow-tags`). 회사 계정 sign-in 상태에서는 보류 — personal sign-in 시점에 일괄 처리.

### 추가: eval 케이스 보강 (이번 entry 마지막 commit)

v0.1.1 / v0.2.0 신규 동작을 functional-evals.yaml에 케이스로 박음:
- **Case 6 interactive-arg-prompt**: 인자 없이 invoke 시 AskUserQuestion 호출 + notion-write 옵션 부재 검증
- **Case 7 dev-note-only-tc**: dev-note만 있고 diff 미증거인 fix가 TC로 생성되되 Source/Risk에 "dev-note only, diff unverified" 마킹 검증
- **Case 8 non-substantive-claim-not-flagged**: 릴리스 날짜/카피 변경 같은 비-substantive claim은 cross-source flag 안 됨 검증
- **Case 9 source-risk-leak-prevention**: 출력에 env var / 절대경로 / 토큰 / 개인 이메일 / 내부 URL 패턴이 없는지 regex sweep

기존 Case 1, 4 보강:
- Case 1 small-bugfix: must_not_include에 "IOS-login" 추가 (cross-platform 아닌 변경은 iOS Prepared row 없어야 함)
- Case 4 lifecycle-change: must_include에 "iOS Prepared" + "lifecycle-broad-regression" 추가

trigger-evals.yaml에 1개 추가:
- **slash-command-no-args**: 인자 없이 슬래시 명령 트리거 검증 (v0.2.0 interactive prompt로 연결됨)

### 잔여 후보 갱신

- ~~Quick start 재작성~~ 완료
- ~~bootstrap 스크립트~~ 완료
- ~~인터랙티브 prompt~~ 완료
- ~~CHANGELOG.md 작성~~ 완료
- ~~git tag 생성 (local)~~ 완료, push 보류
- ~~eval 케이스 보강~~ 완료 (이번 entry 마지막)
- **eval 실제 실행** (남음, v0.1 manual eval — 사용자가 다운스트림 환경에서 수동 실행)
- **다운스트림 적용 시도** (남음, 실제 프로젝트)
- **xlsx/csv 출력 옵션** (신규 후보, v0.3 검토)
- **프로젝트별 양식 분기** (신규 후보, v0.3 검토)
- **self-update 메커니즘** (선택, frontmatter write 권한 영향 있음)
- **tag push** (push 가능 시점, `git push origin v0.1.0 v0.1.1 v0.2.0`)

---

## 2026-05-18 (저녁) — v0.3 디자인 토론

`docs/v0.3-design.md` 신규 작성. 3개 후보 (xlsx/csv 출력 / 프로젝트별 양식 분기 / self-update)의 trade-off 정리.

### 결론

| 항목 | 결정 | 타겟 |
|---|---|---|
| xlsx/csv 출력 | Option B (외부 변환 스크립트) 권장, 단 다운스트림 수요 확인 후 | v0.4 |
| 양식 분기 | Option B (도메인별 별도 skill) 권장, 단 비-mobile 수요 발생 후 | v0.4+ |
| self-update | Option A (수동 유지) 채택, README 한 줄 추가 | v0.2.x patch |

### v0.3.0 scope 재정의

신규 큰 기능 없는 **maintenance release**:
- 다운스트림 적용 시도 + eval 실제 실행 결과를 v0.3에 반영
- README에 self-update 안내 한 줄 추가 (v0.2.x patch 가능)

### Self-update 거부 이유

option B/C는 frontmatter에 `WebFetch` 또는 `Bash(curl)` 권한 추가가 필요. v0.1.1 보안 보강에서 `allowed-tools`를 minimum-required로 축소했는데, version-toast UX를 위해 다시 확대하는 것은 보안 자세 후퇴.

### Reassessment triggers (재논의 트리거)

`docs/v0.3-design.md` 끝부분 참조 — CSV/xlsx 수요 확정 / 비-mobile 적용 요청 / 보안 보강 필요 사건 / Claude Code base-specialization 패턴 공식 지원 중 하나가 발생하면 본 결정 재검토.

---

## 2026-05-18 (저녁 이어서) — 회사 프로젝트 적용 준비 patch

오늘 사용자가 patch-to-tc를 실제 회사 프로젝트 여러 개에 적용해서 변경점에 대한 TC 뽑아 빌드테스트할 예정. 그 적용을 매끄럽게 만드는 patch.

### 신규 commit

- `55cea7b` docs: README self-update 안내 (v0.3-design.md Option A 후속)
- (이번 entry 마지막) bootstrap `-SetupClaudeMd` / `--setup-claude-md` 옵션 + README §3 갱신 + CHANGELOG Unreleased 갱신

### bootstrap 신규 옵션

- `-SetupClaudeMd` (PowerShell) / `--setup-claude-md` (bash)
- 동작: 타겟에 `.claude/CLAUDE.md`가 없을 때만 patch-to-tc의 `.claude/CLAUDE.md.example`을 복사. 이미 있으면 절대 덮어쓰지 않음.
- 적용 흐름: 회사 프로젝트마다 `.\bootstrap.ps1 -TargetProject <path> -SetupClaudeMd` 한 번으로 skill + CLAUDE.md 템플릿 동시 배치 → 사용자가 CLAUDE.md placeholder만 채우면 됨.

### 다음 단계

- 사용자가 실제 회사 프로젝트에 bootstrap 실행 → CLAUDE.md placeholder 채움 → `/mobile-build-tc-from-diff` invoke
- 적용 중 발견된 이슈는 이 세션으로 보고 → 즉시 patch

---

## 2026-05-18 (밤) — 첫 다운스트림 trial 발견 issue patch

bomphago_Unity6에 적용 후 첫 실행 결과: skill이 53 TC를 **채팅 안 markdown으로만 출력하고 파일로 저장하지 않음**. 사용자가 엑셀화 작업 위해 파일이 필요한데 매번 손으로 복사해야 하는 상태.

### 원인 진단

SKILL.md Stage 5 step 1 원문이 "Always render the full Markdown document first ... The Markdown is the canonical output; Notion write is a downstream copy."였음 — "render"가 어디인지 명시 안 됨 → 모델은 자연스럽게 "현재 conversation"으로 해석. **skill의 design gap**. bomphago 세션은 SKILL.md 그대로 따랐을 뿐.

더 안 좋은 점: `docs/v0.3-design.md` §1에서 이 문제(파일 저장)를 xlsx/csv 변환과 묶어서 "v0.4 이연" 결정했었음. 둘은 다른 작업이었는데 묶여서 미뤄짐. **디자인 결정 실수**.

### 패치 내용 (이번 entry 마지막 commit)

| Edit # | 파일 | 변경 |
|---|---|---|
| 1 | SKILL.md frontmatter | `allowed-tools`에 `Write` 추가 |
| 2 | SKILL.md Stage 5 step 1 | 파일 저장 default로 rewrite. chat에는 Summary + 경로만 echo. |
| 3 | SKILL.md Stage 5 step 2 | `notion-read` only / 미지정 시 "Markdown 파일이 deliverable" 명시 |
| 4 | SKILL.md Stage 5 step 3 | Notion write는 파일 저장 후 추가 단계로 위치 명확화 |
| 5 | SKILL.md Constraints | "`Write`는 TC output 전용" 룰 |
| 6 | SKILL.md Anti-patterns | "Dumping full TC tables to chat" + "Writing files outside TC output directory" 2개 추가 |
| 7 | `.claude/CLAUDE.md.example` | QA policy에 `TC output directory` 항목 (default `Docs/QA/`) |
| 8-9 | CHANGELOG.md | Unreleased "Added"에 파일 저장 default + 관련 안전장치 명시. xlsx/csv는 여전히 v0.4 이연으로 표시 |

### 보안 영향 검토 (Write 권한 추가)

v0.1.1 보강에서 `allowed-tools`를 minimum-required로 축소한 원칙에 일부 거스르지만:
- 로컬 파일 쓰기는 exfiltration 경로 아님 (Notion-create-comment 같은 외부 writeback과 다름)
- 사용 범위를 SKILL.md Constraints + Anti-patterns 2곳에 명시적으로 박음 (Docs/QA/ 외 어디든 쓰기 금지)
- frontmatter는 여전히 pre-approval. 실 안전성은 본문 룰 + 모델 행동에 의존 (이건 v0.1.1 R5 경고문대로)

### 다음 회사 프로젝트 적용 시 자동 반영

bomphago_Unity6 등 이미 설치된 회사 프로젝트는 다음 적용 시 `bootstrap.ps1 -TargetProject <path>` 재실행 → 변경된 SKILL.md 자동 갱신. CLAUDE.md는 사용자가 `TC output directory` 항목 명시하면 그 경로, 아니면 default `Docs/QA/`.

### bomphago 이번 1회 처리

bomphago 세션은 사용자가 "Docs/QA/에 파일로 만들어줘"라고 이미 명시 → 그쪽 세션이 파일 만들고 있음. 이번 1회는 사용자가 수동 지시했으나 다음부터는 자동.

### 잔여 후보 갱신 (이번 entry 직전 작업)

- ~~Stage 5 파일 저장 default~~ 완료
- xlsx/csv 변환은 여전히 v0.4 이연 (별도 작업이므로 분리)

---

## 2026-05-18 (밤 이어서) — 외부 review (Claude Web) 반영 patch (A/B/D)

사용자가 Claude Web (사전 지식 없이 문서만 본 상태)에서 bomphago TC 파일에 대한 평가를 받아옴. 5개 지적 중 4개가 skill 본체와 연결됨. 우선순위 (A > B > D > C)로 정리.

### 진행 결정

| # | 지적 | 결정 |
|---|---|---|
| A | Expected Result 톤이 개발자 vs QA 혼재 (ONNX 같은 내부 구현 디테일이 expected에 들어감) | **반영** (anti-pattern 1줄, 안전) |
| B | Automation Candidate 컬럼 vs Notes 모순 | **반영** (anti-pattern 1줄, 안전) |
| D | Status 컬럼이 카테고리인지 진행인지 불명확 | **반영** (Stage 5 §3에 design intention 명시) |
| C | Cross-source flag에 Owner 컬럼 추가 | **보류** — owner 정의(commit author / QA lead / PM / unassigned) 디자인 결정 필요. 최소-안전 수정 원칙에 따라 별도 결정으로 미룸. |

### 신규 commit (이번 entry 마지막)

- SKILL.md anti-patterns 2개 추가 (A, B)
- SKILL.md Output format §3 iOS Prepared 설명 보강 (D)
- CHANGELOG Unreleased "Added" 3 줄 추가
- WORK_LOG 이번 entry

### 외부 review의 가치

웹 클로드 평가는 reviewer simulation과 결이 같음 — "사전 지식 없이 문서만 본 상태". 이번 세션 초반 셀프 시뮬에서 안 잡혔던 새 발견 3건 (A, B, D 영역). 외부 review가 셀프 시뮬을 보완하는 패턴 확인.

### bomphago 자동 갱신 안 됨

이번 patch가 적용되어도 bomphago의 `.claude/skills/mobile-build-tc-from-diff/`는 자동 갱신 X. 사용자가 patch-to-tc 디렉토리에서 `.\bootstrap.ps1 -TargetProject "E:\Unity_Research\bomphago_Unity6"` 재실행 시 SHA-256 비교로 변경된 SKILL.md만 복사. 현재 빌드 검증 진행 중인 세션에는 영향 없음 (메모리에 이미 로드된 SKILL.md 사용). 다음 TC 생성 invocation부터 새 anti-pattern 적용.

---

## 새 세션을 시작할 때

1. **이 파일을 먼저 읽기** (위 표가 컨텍스트 전부)
2. `README.md` → 외부 사용자 시점 (현재 pre-1.0 active template 상태)
3. `CLAUDE.md` → 이 repo 작업 룰 (이번 세션에서 변경 없음)
4. `.claude/skills/mobile-build-tc-from-diff/SKILL.md` → 본 skill 본문 (이번 세션에서 가장 많이 수정됨)

### 잔여 작업 후보

아래는 우선순위 없는 후보. 새 세션에서 선택.

- **eval 실제 실행**: trigger/functional evals.yaml은 케이스가 채워짐. 다운스트림 환경에서 수동으로 case 별 실행 + pass/fail 기록 필요 (v0.1 manual eval 형식)
- **다운스트림 적용 시도**: 실제 프로젝트에 bootstrap.ps1/sh로 설치해 동작 검증
- **tag push**: 로컬 v0.1.0 / v0.1.1 / v0.2.0 push 필요 (personal sign-in 시점에 `git push origin v0.1.0 v0.1.1 v0.2.0` 또는 `--follow-tags`)
- ~~README self-update 안내~~ 완료 (이번 entry 직전 commit, Quick start §5 끝에 추가)
- xlsx/csv 출력 옵션 → v0.3-design.md Option B 권장, v0.4 이연 (수요 확인 후)
- 양식 분기 → v0.3-design.md Option B 권장, v0.4+ 이연 (비-mobile 수요 후)
- self-update 메커니즘 → v0.3-design.md Option A 채택 (frontmatter 권한 확대 비용 회피), 별도 구현 없음

(2026-05-18 마무리: 부분 해소 #1+#6 / v0.2 사용성 개선 / CHANGELOG.md 도입 / git tag 3개 local / eval 케이스 보강 / v0.3 디자인 토론)

### 작업 방식 메모 (이 세션에서 효과적이었던 패턴)

- **보안 commit과 명확화 commit 분리** → commit 의도 명확화
- **같은 파일 여러 Edit는 별도 message로 sequential 호출** (한 message에 여러 tool call은 parallel 처리되므로 충돌 위험)
- **PowerShell here-string (`@'...'@`)** 으로 multiline commit message 전달
- **reviewer 시뮬을 self-review로** 활용 — 작성자 본인이 "처음 보는 사람" 입장으로 막힘을 식별하는 것이 효과적

---

## 진행 시 사용한 도구/세션 메타

- 사용자가 Windows + PowerShell 환경
- origin: `https://github.com/jungang11/patch-to-tc.git` (jungang11 계정)
- push는 사용자가 GitHub Desktop으로 진행 (credential 이슈로 CLI push 우회)
- 이 세션은 `E:\Personal\patch-to-tc\` 작업 디렉토리
