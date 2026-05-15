# [SampleApp] v2.4.0 — Developer Notes

> ⚠️ Fictitious example. Not a real product.

릴리스: 2026-MM-DD
대응 PR 범위: `release/v2.3.x` → `release/v2.4.0` (커밋 ~120건)

---

## Summary (technical view)

이번 릴리스의 주요 기술 변경은 다음과 같습니다.

### 1. 시즌 패스 데이터 구조 마이그레이션

- `SeasonPassData` ScriptableObject 스키마 변경
  - 보상 라인이 단일 배열 → `RewardTier[]` 중첩 구조로 변경
  - 기존 v1 저장본은 `SeasonPassMigrator`를 통해 자동 변환
- 일일 미션 슬롯 7개 지원을 위한 `DailyMissionSlotConfig` 도입

### 2. 콘텐츠 로딩 파이프라인 비동기화

- `ContentLoader.cs` — 동기 IO → `UniTask` 기반 비동기로 전환
- Addressables 사용 시 `LoadAssetAsync<T>().ToUniTask()` 패턴 적용
- 콜드 스타트 시 초기 로딩 시간 약 30% 단축 측정됨 (저사양 기준 4.2s → 2.9s)

### 3. 친구 추천 시스템 (서버 의존)

- 백엔드 신규 API: `POST /v1/referral/redeem`, `GET /v1/referral/status`
- 클라이언트 신규 화면: `Assets/UI/Referral/ReferralEntryView.prefab`
- 보상 자동 지급은 서버 측에서 처리, 클라이언트는 알림만 표시

### 4. 알림 권한 처리 변경

- Android 13+ `POST_NOTIFICATIONS` 권한 요청 흐름 추가
- 알림 카테고리별 토글: `NotificationCategoryToggleManager`
- iOS는 `UNUserNotificationCenter` 카테고리 기반 (v0.1 시점에서는 미실행)

### 5. 버그 수정 (선택)

- **검은 화면**: `Application.unityLogger` 비활성화 상태에서 GL Context 복원 실패. `OnApplicationPause(false)` 핸들러에서 강제 재초기화.
- **시즌 패스 중복 지급**: `RewardClaim` 트랜잭션 멱등성 키 누락. 서버 + 클라 양쪽 패치.
- **채팅 지연 표시**: 로그인 직후 채팅 소켓 핸드셰이크 완료 전 UI가 그려져 메시지 누락. `OnChatReady` 이벤트로 동기화.

---

## Risk areas (QA 우선순위)

| 영역 | 리스크 | 우선순위 |
|---|---|---|
| 시즌 패스 마이그레이션 | v1 저장본 보유 사용자에서 보상 누락/중복 가능성 | **P0** |
| 콘텐츠 로딩 비동기화 | 저사양 기기 race condition, Addressables 캐시 미스 | **P0** |
| 친구 추천 | 서버 API 의존, 네트워크 실패 시 동작 | P1 |
| 알림 권한 | Android 13+에서만 신규 흐름, Android 12 이하 영향 없는지 확인 필요 | P1 |
| 검은 화면 fix | OnApplicationPause 회귀 가능성 (전체 화면에 영향) | **P0** |

---

## 변경된 주요 파일 (요약)

```
Assets/Scripts/SeasonPass/SeasonPassData.cs            (스키마 변경)
Assets/Scripts/SeasonPass/SeasonPassMigrator.cs        (신규)
Assets/Scripts/Content/ContentLoader.cs                (async 전환)
Assets/Scripts/Referral/ReferralService.cs             (신규)
Assets/Scripts/Notification/NotificationCategoryToggleManager.cs (신규)
Assets/Scripts/Lifecycle/AppLifecycleHandler.cs        (OnApplicationPause 핸들러 추가)
Assets/UI/Referral/*                                   (신규 UI)
Assets/Data/SeasonPass/season5.asset                   (시즌 5 데이터)
```

---

## 빌드 메모

- Unity: <project-specific, see CLAUDE.md>
- Render pipeline: <project-specific>
- Android: minSdk 24, target 34, AAB 출고
- iOS: 본 릴리스에서 미실행 (TC는 Prepared 상태로만 기록)

---

## 패치노트 ↔ 개발 노트 매핑

| 사용자용 표현 | 기술 항목 |
|---|---|
| "시즌 패스 시즌 5 오픈" | 1. 시즌 패스 데이터 구조 마이그레이션 + 4번 미션 슬롯 |
| "콘텐츠 로딩 속도 향상" | 2. 콘텐츠 로딩 파이프라인 비동기화 |
| "친구 추천 시스템" | 3. 친구 추천 시스템 |
| "알림 설정 세분화" | 4. 알림 권한 처리 변경 |
| "백그라운드 복귀 시 검은 화면" | 5. 검은 화면 버그 |
