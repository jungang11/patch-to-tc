# Work Log

작업 일지. 새 세션 시작 시 가장 먼저 읽기.
Claude Code 세션은 로컬 머신 단위로 저장됨(`~/.claude/projects/...`) — 다른 머신에서는 이전 세션을 볼 수 없으므로 컨텍스트 복구는 이 파일이 담당.

시간 기록은 절대 날짜로.

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

### 잔여 후보 갱신

- ~~Quick start 재작성~~ 완료
- ~~bootstrap 스크립트~~ 완료
- ~~인터랙티브 prompt~~ 완료
- **eval 케이스 작성** (남음)
- **다운스트림 적용 시도** (남음, 실제 프로젝트)
- **CHANGELOG.md 작성** (남음)
- **xlsx/csv 출력 옵션** (신규 후보, v0.3 검토)
- **프로젝트별 양식 분기** (신규 후보, v0.3 검토)
- **self-update 메커니즘** (선택, frontmatter write 권한 영향 있음)

---

## 새 세션을 시작할 때

1. **이 파일을 먼저 읽기** (위 표가 컨텍스트 전부)
2. `README.md` → 외부 사용자 시점 (현재 v0.1 bootstrap 상태)
3. `CLAUDE.md` → 이 repo 작업 룰 (이번 세션에서 변경 없음)
4. `.claude/skills/mobile-build-tc-from-diff/SKILL.md` → 본 skill 본문 (이번 세션에서 가장 많이 수정됨)

### 잔여 작업 후보

아래는 우선순위 없는 후보. 새 세션에서 선택.

- **eval 케이스 작성**: `.claude/skills/.../evals/{trigger,functional}-evals.yaml`은 골격만 있고 실제 케이스 미작성
- **다운스트림 적용 시도**: 실제 프로젝트에 bootstrap.ps1/sh로 설치해 동작 검증
- **CHANGELOG.md 작성**: 외부 reader용 변경 이력 (현재는 git log + 이 파일이 대체)
- **xlsx/csv 출력 옵션** (v0.3 검토): SKILL.md Stage 5에 새 모드 또는 외부 변환 스크립트
- **프로젝트별 양식 분기** (v0.3 검토): web-build-tc-from-diff 같은 별도 skill 또는 SKILL.md에 `--format` 옵션
- **self-update 메커니즘** (선택): skill이 patch-to-tc 원격과 자기 버전 비교 후 갱신 알림. frontmatter write 권한 필요 — 보안 영향 검토 필요

(2026-05-18 마무리: 부분 해소 #1+#6 / v0.2 사용성 개선 — bootstrap + 인터랙티브 prompt + Quick start rewrite)

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
