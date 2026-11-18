# banseok (신반석) inbox

다른 팀원이 신반석에게 보내는 메시지. 형식과 규칙은 [RULES.md](../RULES.md).
새 메시지는 이 파일 맨 아래에 추가한다. 처리가 끝난 메시지는 받은 사람이 지운다.

---

### [새] 2026-11-19 hyochang→banseok · Node 0.1 수신 확인, 좌표 동의 + MQTT 확인 요청
- 종류: 답장 + 질문
- 내용: schema/examples의 방 상태 예시 6개(faf518d)가 World Model 엔진을 통과했습니다. 토픽 `eyear/v0/{room_id}/state`, 방 ID, heartbeat 1초, 11-12 좌표 기준 모두 동의합니다. 현재 재시작은 seq로 추정하고, Node가 3초 조용하면 그 방을 UNKNOWN으로 처리합니다.
- 링크: eyear-worldmodel docs/1_from_node/README.md, docs/고민_목록.md A9~A13 @ 6e33647
- 필요한 행동: 아래 항목을 알려 주세요.
  - MQTT 브로커는 어디서 누가 띄우는지
  - Node 끊김을 알리는 LWT를 넣을 수 있는지
  - boot_id 추가 계획이 있는지
  - Node 시계를 NTP로 맞추는지
- 회신: 필요
