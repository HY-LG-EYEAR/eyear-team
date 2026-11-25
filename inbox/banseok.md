# banseok (신반석) inbox

다른 팀원이 신반석에게 보내는 메시지. 형식과 규칙은 [RULES.md](../RULES.md).
새 메시지는 이 파일 맨 아래에 추가한다. 처리가 끝난 메시지는 받은 사람이 지운다.

---

### [새] 2026-11-25 hyochang→banseok · 답장: 월드모델 MQTT 구독·HTTP 보내기 준비 완료 + 재생 샘플이 레포에 없음
- 종류: 답장 + 요청
- 내용: 11-23 요청한 ①② ⑦ 연결을 만들었습니다.
  - 실행: `python -m worldmodel.live --mqtt <브로커> --orchestrator http://<중앙>:8765 --app-data config/app_demo.json`
  - 구독: `eyear/v0/+/state` → NodeHub, `+/status` (online:false면 그 방을 바로 UNKNOWN), `device/+/state`·`device/+/result`
  - 중앙으로 sessions 등록 → snapshots → device-results 순서로 보냅니다. 중앙이 재시작하면 세션을 다시 등록하고, 중앙이 꺼져 있으면 최신 스냅샷을 다시 보냅니다.
  - 시험: 로컬 브로커 + 송정빈 orchestrator.server + eyear-node fake_sender로 돌렸고, 스냅샷 202 19번, 거절·오류 0번, 판단 기록 9건이 생겼습니다. fake_sender를 끄면 LWT로 네 방이 바로 UNKNOWN이 됩니다.
  - 재생 샘플 `recorder/samples/2026-11-19_room1_rest_passerby.jsonl`이 `.gitignore`의 `*.jsonl` 때문에 레포에 없습니다 (samples에는 README.md만 있음). 그래서 재생 시험은 못 했습니다.
- 링크: eyear-worldmodel worldmodel/live.py @ ea115c3
- 필요한 행동: ① 샘플 jsonl을 `!recorder/samples/*.jsonl` 예외로 올리거나 따로 전달 ② 목요일 가전 상태(`eyear/v0/device/{id}/state`)를 누가 보내는지 알려 주세요. 지금은 `kind`/`type` 둘 다 받고, capabilities가 없어도 받습니다.
- 회신: 필요 (①②)
