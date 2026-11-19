# hyochang (이효창) inbox

다른 팀원이 이효창에게 보내는 메시지. 형식과 규칙은 [RULES.md](../RULES.md).
새 메시지는 이 파일 맨 아래에 추가한다. 처리가 끝난 메시지는 받은 사람이 지운다.

---

### [새] 2026-11-06 banseok→hyochang · Node 방 상태 메시지 v0.1 초안 + 가짜 송신기
- 종류: 요청
- 내용: 방 상태 메시지(`eyear/v0/{room_id}/state`) 형식 초안과, 장치 없이 같은 형식을 MQTT로 보내는 가짜 송신기를 올렸습니다. 시나리오 t0~t7을 그대로 재생할 수 있습니다.
- 링크: eyear-node docs/schema_v0.md 2절·4절 @ 099f993 (JSON Schema: schema/json/node_state.schema.json, 예시: schema/examples/node_state_*.json)
- 필요한 행동: 아래 항목에 의견 주세요. 바꿔야 할 부분이 있으면 제가 schema_version을 올려 반영합니다.
  - 토픽 이름: `eyear/v0/{room_id}/state`
  - 방 ID: `room1` `room2` `living` `laundry`
  - 좌표 원점·축 방향: 방마다 문 쪽 모서리가 원점 (임시)
  - heartbeat 주기: 1초
- 회신: 필요 (hyochang→banseok 답장)

### [새] 2026-11-12 banseok→hyochang · 좌표 기준 확정안 + 실제 Node 재실·어둠 규칙
- 종류: 변경 알림 + 요청
- 내용: 메시지 형식은 그대로(schema 0.1)이고, 값의 의미가 정해졌습니다.
  - 좌표 기준(확정안): 평면도를 위에서 본 2D, 미터. 원점 = 평면도에서 각 방의 왼쪽 아래 모서리, x = 오른쪽, y = 위쪽.
    집 전체 좌표 = 방 좌표 + 평면도에서 그 방의 왼쪽 아래 모서리 위치. (11-06 메시지의 "문 쪽 모서리" 임시안을 대체)
  - 실제 Node(방1)가 카메라 + 레이더 2개로 동작합니다.
    - 재실: 카메라나 위치 레이더가 방 안에서 사람을 봐야 OCCUPIED가 되고, 걸어 나가면 약 6~7초 뒤 EMPTY.
      재실 레이더가 레이더 뒤쪽(벽 너머) 사람도 잡아서, EMPTY 신뢰도 0.6은 "방 밖 사람일 가능성이 높음"이라는 뜻입니다.
    - 불이 꺼지면: 신원 TRACK_CARRIED, posture UNKNOWN, RESTING은 크게 움직이기 전까지 유지.
    - position은 시연 설치 때 레이더 위치를 재기 전까지 null입니다.
  - 가짜 송신기 시나리오의 좌표는 아직 임시안 기준입니다. 이 기준으로 고칠 예정입니다.
- 링크: eyear-node docs/schema_v0.md 2절 "좌표 기준"·"알아 두면 좋은 상황" @ 66d2b62
- 필요한 행동: 좌표 기준이 3D 시뮬레이션에서 쓰기 괜찮은지 의견 주세요.
- 회신: 필요 (좌표 기준 동의 여부)

### [새] 2026-11-19 banseok→hyochang · 답장: 브로커·LWT·boot_id·NTP (스키마 0.2)
- 종류: 답장 + 변경 알림
- 내용: 질문 4개에 대한 답입니다. 메시지 형식은 0.2로 올렸고, 기존 필드는 그대로입니다.
  - 브로커: 시연 때 신반석 노트북에서 mosquitto를 띄우고, 다른 노트북은 같은 와이파이로 접속합니다.
    지금은 반석 노트북 안에서만 접속할 수 있게 되어 있어서, 연동할 때 설정을 바꾸고 주소·접속 정보를 알려 드리겠습니다.
  - LWT: 추가했습니다. `eyear/v0/{room_id}/status`(보관 메시지)에 `{type: NODE_STATUS, online, boot_id, …}`.
    켜지면 online: true, 정상 종료하면 online: false를 직접 보내고, 갑자기 끊기면 브로커가 online: false를 대신 보냅니다
    (프로그램이 죽으면 바로, 네트워크가 끊기면 약 8초 안). LWT로 온 offline의 timestamp는 연결 시각이라, 끊긴 시각은 받은 시각으로 봐 주세요.
    브로커가 있는 노트북 자체가 꺼지면 이 알림도 못 가므로 "3초 조용하면 UNKNOWN"은 그대로 두시는 게 좋겠습니다.
  - boot_id: 추가했습니다. Node가 보내는 모든 메시지에 있고, 바뀌면 재시작(seq도 0부터)입니다.
  - NTP: macOS 자동 시간 설정으로 맞춥니다. 오늘 확인해 보니 2.1초 어긋나 있어서 맞췄습니다(현재 차이 0.001초). 시연 전에 다시 확인하겠습니다.
  - 가짜 송신기도 0.2로 동작합니다 (방마다 boot_id와 status를 따로 보냄).
- 링크: eyear-node docs/schema_v0.md 1절·6절 @ 80f05a7 (JSON Schema: schema/json/node_status.schema.json, 예시: schema/examples/node_status_*.json)
- 필요한 행동: 파서에서 schema_version "0.2", boot_id, status 토픽을 받아 주세요.
- 회신: 불필요 (문제 있으면 알려 주세요)
