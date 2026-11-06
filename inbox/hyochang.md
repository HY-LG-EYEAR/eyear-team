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
