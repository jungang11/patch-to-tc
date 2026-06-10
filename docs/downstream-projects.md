# Downstream Projects

이 문서는 patch-to-tc를 여러 로컬 프로젝트에 반복 적용하기 위한 사용법이다. 실제 회사/개인 프로젝트 경로는 민감할 수 있으므로 이 문서에 직접 저장하지 않는다. 실제 경로는 gitignored 파일인 `downstream-projects.local.md`에 둔다.

---

## Recommended Local Registry

루트에 아래 파일을 만든다.

```text
downstream-projects.local.md
```

이 파일은 `.gitignore`에 포함되어 있으므로 commit 대상이 아니다. 사용자가 로컬 경로를 계속 수정해도 repo에는 올라가지 않는다.

권장 양식:

```markdown
# Downstream Projects Local

실제 로컬 경로만 기록한다. 회사명, 내부 URL, 계정, 토큰은 쓰지 않는다.

| Enabled | Project | Path | First install? | Notes |
|---|---|---|---|---|
| yes | coggames_Unity6 | E:\...\coggames_Unity6 | no | 기존 설치됨. bootstrap update만 |
| yes | bomphago_Unity6 | E:\...\bomphago_Unity6 | no | 기존 설치됨. bootstrap update만 |
| no | sample | E:\...\sample | yes | 필요할 때만 |
```

`Enabled = yes`인 행만 업데이트 대상으로 본다. `First install? = yes`면 `-SetupClaudeMd`까지 붙이고, 이미 설치된 프로젝트면 일반 bootstrap update만 실행한다.

---

## How To Ask An Agent

patch-to-tc 세션에서 이렇게 요청하면 된다.

```text
downstream-projects.local.md에 등록된 Enabled=yes 프로젝트들에 patch-to-tc skill 업데이트해줘.
처음 설치가 필요한 프로젝트는 -SetupClaudeMd까지 붙여줘.
```

에이전트가 해야 할 일:

1. `downstream-projects.local.md`를 읽는다.
2. `Enabled = yes`인 프로젝트만 고른다.
3. 각 `Path`가 존재하는지 확인한다.
4. 기존 설치 프로젝트는 아래 명령을 실행한다.

```powershell
.\bootstrap.ps1 -TargetProject "<path>"
```

5. 첫 설치 프로젝트는 아래 명령을 실행한다.

```powershell
.\bootstrap.ps1 -TargetProject "<path>" -SetupClaudeMd
```

6. 각 프로젝트의 결과를 `new / updated / skipped` 숫자로 요약한다.

---

## After Update

각 downstream 프로젝트에서 Claude Code를 켠 뒤:

```text
> /mobile-build-tc-from-diff
```

Codex에서 사용할 때는 `docs/codex-portability.md`의 invocation pattern을 따른다.

---

## Safety Rules

- 실제 경로 파일은 `downstream-projects.local.md`에만 둔다.
- real patch note, dev note, Notion URL, 계정 ID, 내부 서버 URL은 쓰지 않는다.
- `bootstrap.ps1`은 target 프로젝트의 `.claude/skills/mobile-build-tc-from-diff/`만 갱신한다.
- 이미 있는 downstream `.claude/CLAUDE.md`는 `-SetupClaudeMd`를 써도 덮어쓰지 않는다.
- commit/push는 사용자 명시 승인 전에는 하지 않는다.
