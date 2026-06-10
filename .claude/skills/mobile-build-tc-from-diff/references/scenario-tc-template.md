# Scenario TC Template

이 문서는 `SKILL.md` Stage 0/3에서 읽는 시나리오 TC 양식이다. 목적은 QA 전문 문서처럼 과하게 쓰는 것이 아니라, 실제 빌드 테스트자가 바로 따라갈 수 있을 정도로 **기능, 상황, 성공/실패 흐름**을 정량적으로 정리하는 것이다.

---

## Core Rule

TC는 아래 질문에 답해야 한다.

| 질문 | TC에 들어갈 내용 |
|---|---|
| 어떤 기능인가? | 기능/콘텐츠/미니게임/화면/서버 연동 단위 |
| 어떤 상황인가? | 정상 진행, 실패 입력, 네트워크 실패, 중단/복귀, 단계 진행, 보상 수령 등 |
| 어떻게 실행하는가? | 사용자가 실제로 하는 단계 |
| 성공하면 무엇이 보여야 하는가? | 화면, 점수, 보상, 저장, 서버 전송, 로그 등 관찰 가능한 결과 |
| 실패하면 어떻게 처리되어야 하는가? | 에러 메시지, 재시도, 롤백, 중복 방지, 데이터 미전송/재전송 등 |

내부 구현명만으로 TC를 만들지 않는다. 내부 구현명은 `Source/Risk`나 `Notes`에 두고, TC 본문은 사용자가 관찰하는 흐름 중심으로 쓴다.

---

## Reverse-Spec Snapshot

TC 생성 전에 프로젝트를 짧게 역기획한다. 완벽한 기획서가 아니라, 테스트 범위를 정하기 위한 스냅샷이다.

| 항목 | 작성 기준 |
|---|---|
| Project type | Unity mobile game, native Android game, React Native app 등 |
| Main loop | 앱/게임을 켜서 사용자가 반복적으로 수행하는 핵심 루프 |
| Content groups | 미니게임, 스테이지, 퀴즈 묶음, 월드, 시즌 콘텐츠 등 |
| Progression | 1단계~10단계, 튜토리얼~고급, 라운드 시작~종료~결과 등 |
| Data persistence | 로컬 저장, 서버 전송, 보상 지급, 재접속 후 복원 |
| Failure surfaces | 네트워크 끊김, 입력 실패, 앱 중단/복귀, 저사양 지연, 중복 요청 |
| Changed scope | 이번 diff가 실제로 건드린 기능/콘텐츠/위험 축 |

프로젝트에 미니게임이 여러 개 있으면 `Content groups`를 반드시 분리한다. 예: `MiniGame01`, `MiniGame02`, `MiniGame03`처럼 이름이 불명확하면 파일명/씬명/프리팹명 기준으로 임시 식별자를 붙이고, 실제 이름은 사용자 확인 대상으로 남긴다.

---

## Scenario Coverage Matrix

최종 TC 표 앞에 아래 matrix를 만든다. 이 matrix는 "왜 이 TC들이 나왔는지"를 사람이 빠르게 검토하는 인덱스다.

| Feature / Content | Situation | Success path | Failure / edge path | TC IDs |
|---|---|---|---|---|
| `<feature>` | `<상황>` | `<성공 시 관찰 결과>` | `<실패/예외 처리>` | `AND-...` |

예시:

| Feature / Content | Situation | Success path | Failure / edge path | TC IDs |
|---|---|---|---|---|
| MiniGame-A | Stage 1~10 full progression | 각 단계 완료 후 점수/결과 화면 표시, 최종 결과가 서버에 전송됨 | 중간 이탈 후 재진입 시 진행 상태가 깨지지 않음 | `AND-minigame-a-001`, `AND-minigame-a-002` |
| Referral reward | Valid code redemption | 보상 지급 toast와 보상함 반영 | invalid code / network drop에서 중복 지급 없이 재시도 가능 | `AND-referral-001`, `AND-referral-002` |

---

## Scenario TC Fields

기본 TC table은 `SKILL.md`의 canonical columns를 유지한다. 다만 각 row는 아래 의미를 담아야 한다.

| Field | 작성 방법 |
|---|---|
| TC ID | `AND-<feature>-<NNN>` 또는 `IOS-<feature>-<NNN>` |
| Type | Build Gate / Smoke / Regression / Edge |
| Priority | P0~P3. 데이터 손실, 크래시, 결제/보상/서버 전송 실패는 P0/P1 |
| Title | `Verify <기능> when <상황>` 형태. 기능과 상황이 둘 다 보여야 함 |
| Preconditions | 빌드, 계정 상태, 콘텐츠 해금 상태, 네트워크, 기기 조건 |
| Steps | 사용자의 실제 행동. 한 step에 여러 행동을 섞지 않음 |
| Expected Result | 성공/실패 처리 중 관찰 가능한 결과. "정상 동작" 금지 |
| Automation Candidate | 자동화 가능성. 수동 실행이면 `Manual only` |
| Source/Risk | git path, commit, Notion section, risk category |

---

## Content-Heavy / Mini-Game Rule

미니게임, 콘텐츠, 스테이지가 여러 개인 프로젝트는 기능 단위 TC만으로 부족하다. 변경된 콘텐츠 묶음마다 아래 최소 시나리오를 검토한다.

| 상황 | 최소 TC 기준 |
|---|---|
| 신규/수정 미니게임 | 진입 → 1회 플레이 → 결과 화면까지 Smoke 1개 |
| 단계형 콘텐츠 | 변경 범위가 작으면 대표 단계 2~3개, 명시적으로 1~10단계가 중요하면 1~10 전체 진행 TC 1개 |
| 결과/점수/보상 | 성공 결과가 로컬 UI와 저장 데이터에 반영되는 TC 1개 |
| 서버 전송 | 결과가 프로젝트의 backend에 전송되고 재시도/중복 방지가 되는 TC 1개 |
| 실패 입력 | 시간 초과, 오답, 실패 판정, 포기/나가기 중 실제 게임에 있는 실패 상황 1개 |
| 중단/복귀 | 앱 background/foreground, 강제 종료 후 재진입, 라운드 중 네트워크 변경 중 해당 위험이 있으면 1개 |

10개 미니게임이 한 번에 바뀌면 10개를 모두 같은 깊이로 쓰지 않는다. 먼저 matrix를 만들고, 아래 기준으로 batch를 제안한다.

- P0/P1: 공통 엔진, 저장, 서버 전송, 보상, 로그인/계정 영향
- P1/P2: 변경된 미니게임별 대표 성공/실패 시나리오
- P2/P3: 장치/네트워크/저사양 edge

---

## Quantitative Budget

오버 생성하지 않기 위해 아래 기준을 사용한다.

| 변경 규모 | 권장 TC 수 |
|---|---|
| 단일 버그 수정 | 3~8 |
| 단일 기능/미니게임 수정 | 5~12 |
| 콘텐츠 2~5개 변경 | 10~25 |
| 콘텐츠 6개 이상 또는 파일 50개 초과 | 먼저 scope/batch 확인 |

TC가 30개를 넘을 것 같으면 `SKILL.md`의 cap 규칙을 따른다. 부분적으로 줄여서 몰래 내보내지 말고, 어떤 content group을 이번 batch에 넣을지 사용자에게 묻는다.

---

## Anti-Patterns

- 기능명만 있고 상황이 없는 TC: "Verify MiniGame works"
- 성공 시나리오만 있고 실패/중단/서버 실패가 없는 TC
- 미니게임 10개를 하나의 TC로 합치는 것
- 모든 미니게임에 같은 템플릿을 복붙하는 것
- 서버 전송이 중요한 게임에서 UI 결과만 보고 끝내는 것
- 내부 클래스명/파일명만 Expected Result에 쓰는 것
- 실제 계정 ID, 내부 서버 URL, 개인정보를 TC에 쓰는 것
