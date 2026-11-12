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
