# banseok (신반석) inbox

다른 팀원이 신반석에게 보내는 메시지. 형식과 규칙은 [RULES.md](../RULES.md).
새 메시지는 이 파일 맨 아래에 추가한다. 처리가 끝난 메시지는 받은 사람이 지운다.

---

### [새] 2026-11-26 hyochang→banseok · 가전 시뮬레이터 만들었음, 진행표 8단계를 2단계로 당겨야 함
- 종류: 변경 알림 + 요청 (11-25 메시지 ②③ 답)
- 내용:
  - ② 가전 상태: 선택지 (b)로 했습니다. 월드모델에 `python -m worldmodel.device_sim --mqtt <브로커>`를 만들었고, 효창 노트북에서 띄웁니다.
    중앙 fixtures와 같은 6대(청소기·세탁기·에어컨 2·방1 조명·방1 커튼)의 상태를 보내고 `eyear/v0/device/{id}/command`를 받아 결과를 보냅니다.
    중앙은 `DEVICE_TRANSPORT=mqtt`로 띄웁니다 (정빈에게 알림).
  - mock은 안 되는 이유: 중앙은 스냅샷에 있는 기기에만 명령합니다. 가전 상태가 없으면 5단계 "응" 뒤 조명 끄기,
    6단계 "불 켜줘", 7단계 청소가 모두 안 나옵니다. 그래서 진행표 8단계(가전 시뮬레이터)를 **2단계에 같이** 해야 합니다.
  - ③ 질문 두 번은 월드모델에서 고쳤습니다 (07caa13, 같은 track은 person_id 유지). ④ paho-mqtt 의존성 추가 (42a2a5b).
  - 반석 샘플로 제 노트북에서 확인: 질문 1번 → "네" → 커튼·조명 off → 나가면 에어컨 off, 청소 시작 → 26초 뒤 completed.
    청소는 루틴 방(room2, room1)이 모두 EMPTY여야 시작하므로 3단계 가짜 송신기(방2 EMPTY)가 필요합니다.
  - Node 0.2 `boot_id`도 이제 재시작 판별에 씁니다. replay가 매번 새 boot_id를 써서 그대로 맞습니다.
- 링크: eyear-worldmodel worldmodel/device_sim.py, README "실행 (실제 연동)"
- 필요한 행동: docs/integration_2026-11-26.md 진행표에서 8단계를 2단계로 옮기기 (실행: 효창 `python -m worldmodel.device_sim --mqtt <브로커>`)
- 회신: 불필요
