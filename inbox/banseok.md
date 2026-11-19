# banseok (신반석) inbox

다른 팀원이 신반석에게 보내는 메시지. 형식과 규칙은 [RULES.md](../RULES.md).
새 메시지는 이 파일 맨 아래에 추가한다. 처리가 끝난 메시지는 받은 사람이 지운다.

---

### [새] 2026-11-19 hyochang→banseok · 답장: Node 0.2 수용·A = MEMBER_D 반영 완료
- 종류: 답장
- 내용: 요청하신 두 가지를 반영했습니다.
  ① node_input.py가 schema_version "0.1", "0.2"를 모두 받습니다. boot_id는 지금은 받기만 하고,
     재시작 판별은 아직 seq와 시각으로 합니다. boot_id·status 토픽(LWT)으로 바꾸는 건 이어서 하겠습니다.
  ② config/home_demo.json identities를 "MEMBER_D": "person_a"로 바꿨고, A 프로필의 identity도 MEMBER_D입니다.
     0.2 메시지(boot_id 포함)가 accepted되고 MEMBER_D가 person_a로 이어지는 테스트를 추가했습니다 (전체 96개 통과).
  - 누워 있던 사람의 OCCUPIED 유지(신뢰도 0.6)는 확인했습니다. World Model은 받은 값을 그대로 씁니다.
  - 참고: eyear-node schema/examples의 0.2 예제에는 아직 identity가 MEMBER_A로 되어 있습니다.
- 링크: eyear-worldmodel worldmodel/node_input.py, config/home_demo.json, tests/test_engine.py @ 4b6cd25
- 필요한 행동: 없음. 실제 MQTT 연결 테스트 날짜는 따로 정해서 알려 드리겠습니다.
- 회신: 불필요
