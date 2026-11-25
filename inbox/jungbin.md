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

### [새] 2026-11-19 hyochang→jungbin · WorldSnapshot 2.0 구현 공유, 확인 요청 5건
- 종류: 요청
- 내용: 11-13 계약 2.0 협의안 기준으로 엔진, Schema, 수신 참조 구현을 올렸습니다. 협의안에서 정해지지 않았거나 함께 확인하기로 한 부분만 요청드립니다. TTL 값과 구현 내역은 링크에 있습니다.
- 링크: eyear-worldmodel docs/3_to_orchestrator/합의_요청_2026-11-14.md, worldmodel/contract/ @ 6e33647
- 필요한 행동:
  1. `POST /v2/world/snapshots` 서버 주소, 인증 방식, 테스트 가능 시점
  2. 세션 등록/reset 호출 방법과 권한. reset이 대기 명령과 질문도 지우는데, 시연 중 World Model만 재시작할 때도 reset할지
  3. 기기 명령을 보낼 곳, 결과 이벤트를 받을 endpoint, 시연 어댑터로 앱의 DeviceSimulator를 쓸지
  4. 추적이 끊겨도 방이 계속 OCCUPIED면 그 사람을 방에 유지하는 기준(HELD)이 괜찮은지
  5. 별첨 Schema/예제 원본 공유 또는 제가 만든 파일을 기준으로 써도 되는지, 계약 PDF를 eyear-orchestrator에 커밋할 수 있는지
- 회신: 필요

### [새] 2026-11-19 banseok→jungbin · 스키마 0.2: 음성 메시지에 boot_id 추가 + Node 켜짐/꺼짐 토픽
- 종류: 변경 알림
- 내용: Node가 보내는 voice/reply·voice/command에 boot_id 필드가 생기고 schema_version이 "0.2"가 됩니다. 기존 필드는 그대로입니다.
  - 중앙이 보내는 speak는 0.1·0.2 둘 다 받으므로 당장 바꾸지 않아도 됩니다.
  - Node가 켜져 있는지는 `eyear/v0/{room_id}/status`(보관 메시지, online true/false)로 알 수 있습니다. 질문을 보내기 전에 확인하는 데 쓸 수 있습니다.
- 링크: eyear-node docs/schema_v0.md 1절 @ 80f05a7
- 필요한 행동: 메시지를 엄격하게 검사하고 있다면 schema_version "0.2"와 boot_id를 허용해 주세요.
- 회신: 불필요

### [새] 2026-11-23 banseok→jungbin · 목요일 통합 준비: 중앙 실행 방법 + 진행표
- 종류: 요청
- 내용: 목요일(11-26) 진행표를 올렸습니다. 다른 노트북의 월드모델이 중앙에 HTTP로 보내야 해서
  `MQTT_HOST=<브로커 주소> HOST=0.0.0.0`으로 띄워 주세요. 브로커는 반석 핫스팟 + 비밀번호 없음입니다
  (지금 중앙 설정에 MQTT 아이디·비밀번호가 없어서). 중앙 ↔ Node 음성 메시지(speak, voice/reply, voice/command)
  형식은 서로 맞는 것을 코드로 확인했습니다. 시연 영상 B 역할이라, 목요일에 카메라 앞에서 얼굴 등록이
  MEMBER_B인지 C인지 확인하겠습니다.
- 링크: eyear-team docs/integration_2026-11-26.md, docs/connections.md
- 필요한 행동: 진행표의 "송정빈" 항목 확인
- 회신: 불필요

### [새] 2026-11-25 hyochang→jungbin · 월드모델 → 중앙 HTTP 연결 준비 완료 (②⑦)
- 종류: 변경 알림
- 내용: 월드모델이 중앙 :8765로 sessions → snapshots → device-results를 보냅니다. eyear-orchestrator e63a47f 서버에 붙여서 스냅샷 202 19번, 거절·오류 0번, 판단 기록 9건을 확인했습니다.
  - 세션: 월드모델이 켜질 때마다 새 world_session_id로 등록합니다 (reset은 부르지 않음). 중앙이 재시작해서 409 "등록되지 않은 세션"이 오면 다시 등록하고 다시 보냅니다.
  - 기기 결과: `eyear/v0/device/{id}/result`를 월드모델이 받아 상태에 반영한 뒤, world_session_id·world_revision을 붙여 `/v2/world/device-results`로 보냅니다 (`state`는 `observed_state`로 보냄).
  - 프로필·루틴: 앱 연결(⑧) 전까지 config/app_demo.json으로 넣습니다. 선호값은 중앙 fixtures의 A·B와 같고 A identity는 MEMBER_D입니다. 청소 루틴(vacuum_01)은 청소기가 상태를 보고한 뒤에만 스냅샷에 들어갑니다.
  - 스냅샷 시각이 -5~120초 범위를 벗어나면 422가 나므로, 목요일에 두 노트북 모두 시간 자동 설정을 켜야 합니다.
  - 11-14 요청의 1~3(주소, 세션 등록, 결과 endpoint)은 이 구현으로 정리됐습니다. 4(HELD 기준)·5(Schema 원본)는 목요일에 같이 보면 됩니다.
- 링크: eyear-worldmodel worldmodel/live.py @ ea115c3
- 필요한 행동: 목요일에 중앙 HTTP 주소(IP:8765)만 알려 주세요.
- 회신: 불필요 (문제 있으면 알려 주세요)
