# jungbin (송정빈) inbox

다른 팀원이 송정빈에게 보내는 메시지. 형식과 규칙은 [RULES.md](../RULES.md).
새 메시지는 이 파일 맨 아래에 추가한다. 처리가 끝난 메시지는 받은 사람이 지운다.

---

### [새] 2026-11-06 banseok→jungbin · 음성 메시지 형식 v0.1 초안 + 실측 주의점
- 종류: 요청
- 내용: 중앙↔Node 음성 메시지 3종(`speak`, `voice/reply`, `voice/command`) 초안과 실제 음성 Node를 올렸습니다. Node는 중앙이 보낸 텍스트를 읽고, 들은 말은 텍스트로만 보냅니다. "응/아니"의 해석은 중앙 몫입니다.
  - 실측(Whisper small) 결과, 인식기가 `응?`, `아니.`처럼 문장부호를 붙입니다. 짧은 대답은 신뢰도가 0.3 안팎으로 낮게 나오지만 정상 대답입니다.
- 링크: eyear-node docs/schema_v0.md 3절 @ 099f993 (JSON Schema: schema/json/speak_command·voice_reply·voice_command.schema.json)
- 필요한 행동: 아래 항목에 의견 주세요.
  - 토픽: `eyear/v0/{room_id}/speak`, `.../voice/reply`, `.../voice/command`
  - `speak` 필드(`command_id`, `text`, `expect_reply`, `listen_seconds`)와 기본 듣기 시간 5초
  - 중앙 없이 테스트하려면: `mosquitto_pub -t eyear/v0/room1/speak -f schema/examples/speak_command_question.json`
- 회신: 필요 (jungbin→banseok 답장)

### [새] 2026-11-11 banseok→jungbin · 음성 대답 인식 개선 + 질문 문장 제안
- 종류: 변경 알림 + 요청
- 내용: 침대(노트북에서 약 2m)에서 "응/네" 같은 짧은 대답을 놓치던 문제를 고쳤습니다. 메시지 형식은 그대로입니다.
  - 실측(한 사람): 응·네·아니 7번 + 무응답 1번 모두 정답. 대답에 `응.`처럼 문장부호가 붙고, 짧은 대답은 신뢰도 0.5 안팎입니다.
  - 아주 작게 말한 경우 대답이 듣기 마감 후 약 0.7초 늦게 올 수 있습니다.
- 링크: eyear-node docs/schema_v0.md 3절 "Node → 중앙: 질문에 대한 대답" @ bfbd034
- 필요한 행동:
  - 수면 질문 문장을 대답 형태를 알려 주는 쪽으로 검토해 주세요. 예: "MEMBER_A님, 주무실 거면 '네'라고 말씀해 주세요"
  - `no_response`를 기다리는 시간은 "말하는 시간 + listen_seconds + 2초" 정도로 넉넉히 잡아 주세요.
- 회신: 불필요 (질문 문장을 바꾸면 알려 주세요)
