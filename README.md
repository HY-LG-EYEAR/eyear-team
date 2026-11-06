# eyear-team

EYEAR 팀원끼리 주고받을 내용을 두는 레포다. 팀원마다 inbox 파일이 하나씩 있다. 각자 작업 레포에서 Claude Code를 켜면, Claude가 자기 inbox를 먼저 읽고 알려 준다.

- 규칙: [RULES.md](RULES.md)
- inbox: [banseok](inbox/banseok.md) · [hyochang](inbox/hyochang.md) · [jungbin](inbox/jungbin.md) · [yewon](inbox/yewon.md)

## 어떻게 쓰나
- 작업하다 다른 팀원에게 알릴 게 생기면 Claude가 문안을 보여 준다. 확인하면 상대 inbox 파일 맨 아래에 추가한다.
- eyear-team을 커밋·푸시하면 전달된다. 상대가 다음에 Claude를 켤 때 자동으로 pull 되고 읽힌다.
- 받은 메시지는 처리하고 나서 지운다. 기록은 git 이력에 남는다.
- Claude 없이 직접 써도 된다. 형식은 RULES.md를 따른다.

## 설정 (각자 한 번)

### 1. 작업 레포 옆에 클론
상대 경로 `../eyear-team`을 쓰므로, 작업 레포와 같은 폴더에 둔다.
```
<아무 폴더>/
├── eyear-worldmodel/   ← 자기 작업 레포 (eyear-node, eyear-orchestrator, eyear-app ...)
└── eyear-team/         ← 이 레포
```

### 2. 작업 레포의 CLAUDE.md 끝에 추가
`<id>`는 자기 id(banseok, hyochang, jungbin, yewon)로 바꾼다. CLAUDE.md가 없으면 새로 만든다.
```markdown
## 팀 공유 (eyear-team inbox)
- 다른 팀원에게 알릴 내용은 `../eyear-team/inbox/<받는 사람 id>.md`에 쓴다.
- 세션 시작 훅이 eyear-team을 pull 하고 RULES.md와 내 inbox(`inbox/<id>.md`)를 출력해 준다.
  규칙은 RULES.md를 따르고, inbox에 항목이 있으면 작업 전에 먼저 알린다.
```

### 3. 작업 레포에 `.claude/settings.local.json` 만들기 (필수)
이 설정을 넣으면 두 가지가 된다.
- 세션을 시작할 때 이 레포를 pull 하고, RULES.md와 자기 inbox를 Claude에게 보여 준다. CLAUDE.md의 `@../` import는 작업 폴더 밖 파일이라 불러와지지 않아서 이 방법을 쓴다.
- Claude가 eyear-team 폴더를 작업 범위로 인식해서 다른 팀원 inbox에 쓸 수 있다.

개인 설정이므로 커밋하지 않는다. `.gitignore`에 `.claude/settings.local.json`을 추가한다.
```json
{
  "permissions": {
    "additionalDirectories": ["<자기 컴퓨터의 eyear-team 절대 경로>"]
  },
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "d=\"$CLAUDE_PROJECT_DIR/../eyear-team\"; git -C \"$d\" pull --ff-only -q 2>/dev/null || echo \"[eyear-team] pull 실패: 아래 내용이 최신이 아닐 수 있음 (원격 설정·네트워크·로컬 변경 확인)\"; cat \"$d/RULES.md\" \"$d/inbox/<id>.md\"",
            "timeout": 20
          }
        ]
      }
    ]
  }
}
```
- 이미 settings.local.json이 있으면 내용을 합친다.
- pull은 `--ff-only`라서, 로컬에 커밋하지 않은 변경이 있으면 아무것도 덮어쓰지 않고 실패 문구만 출력한다.
- macOS·Linux 기준이다. Windows는 Git Bash가 설치돼 있어야 훅이 동작한다.
