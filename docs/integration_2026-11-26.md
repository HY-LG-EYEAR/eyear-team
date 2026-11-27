# 첫 통합 테스트 (2026-11-26 목, 신반석·이효창·송정빈)

목표: 실제 방1 Node → 월드모델 → 중앙 → Node 스피커가 처음으로 이어져 시나리오 t1~t6이 도는 것.
연결 그림과 흐름 번호(①~⑨)는 [connections.md](connections.md).

> **11-27 갱신**: 이제 월드모델·가전 시뮬레이터·중앙·앱 백엔드가 **EC2(13.125.114.142)에서 항상 실행**된다
> (브로커 1883 비밀번호, main에 push하면 1~2분 안에 자동 배포). 아래 0·2단계는 서버가 대신하고, Node·가짜 송신기만
> `--mqtt 13.125.114.142` + `EYEAR_MQTT_USER`·`EYEAR_MQTT_PASSWORD`로 붙이면 된다. 핫스팟 방식은 서버가 안 될 때의 비상용.

## 네트워크

- **신반석 휴대폰 핫스팟에 모두 접속.** 학교 와이파이는 기기끼리 접속을 막는 경우가 많다.
- 브로커는 반석 노트북: `scripts/broker_lan.sh --open` (핫스팟이라 비밀번호 없이). 주소는 그 자리에서 알려 줌.
  지금 중앙 코드는 MQTT 아이디·비밀번호를 지원하지 않아서 핫스팟 + 비밀번호 없음으로 간다.
- 중앙 HTTP 서버는 다른 노트북에서 접속하도록 `HOST=0.0.0.0`으로 띄운다 (기본은 자기 노트북 안에서만 받음).
- 모든 노트북의 시간 자동 설정을 켠다 (메시지 시각 비교).
- 안 될 때: 비상으로 세 사람 코드를 모두 반석 노트북에서 실행 (모두 Python, 브로커 localhost).

## 목요일 전에 할 일

**이효창 (월드모델)**
- MQTT 구독: `eyear/v0/+/state` → `NodeHub.submit(topic, payload)` (paho-mqtt 2.x)
- HTTP 보내기: `POST /v2/world/sessions`, `POST /v2/world/snapshots`, `POST /v2/world/device-results` (중앙 :8765)
- **장치 없이 미리 시험할 수 있음:** eyear-node를 받아 기본 설치(`pip install -e .`, Python 3.11)만 하면 실제 Node 기록을 재생할 수 있다.
  ```bash
  brew services start mosquitto     # 자기 노트북 브로커
  python -m recorder.replay recorder/samples/2026-11-19_room1_rest_passerby.jsonl --mqtt localhost
  ```
  227초짜리 시연 공간 기록 (누움 → 소등 → 지나가는 사람 → 1분 누움 → 나감). 구간은 `recorder/samples/README.md`.

**송정빈 (중앙)**
- `MQTT_HOST=<브로커 주소> HOST=0.0.0.0 python -m orchestrator.server` 로 뜨는지 확인
- 위 재생 명령으로 자기 노트북에서 ③④ 없이 상태만 먼저 받아 볼 수 있음 (월드모델을 거쳐야 판단하므로 효창과 같이)

**신반석 (Node)**
- Node 위치 고정 (옮기면 레이더 위치를 다시 잼), 핫스팟 확인
- 브로커 스크립트 확인 (`brew services stop mosquitto` 후 `scripts/broker_lan.sh --open`)

## 당일 순서

각 단계는 앞 단계가 되면 넘어간다. 확인은 누구나 `mosquitto_sub -h <브로커> -t 'eyear/v0/#' -v`로 볼 수 있다.

| 단계 | 하는 일 | 실행 | 되면 |
|---|---|---|---|
| 0 | 핫스팟 접속, 브로커 실행 | 반석: `scripts/broker_lan.sh --open` | 모두 `mosquitto_sub`에 접속됨 |
| 1 | 기록 재생으로 ① 확인 (사람 필요 없음) | 반석: `python -m recorder.replay recorder/samples/2026-11-19_room1_rest_passerby.jsonl --mqtt <브로커>` | 월드모델이 방1 상태를 받음 (accepted) |
| 2 | ② 월드모델 → 중앙 + ⑤⑥⑦ 가전 | 효창 월드모델·가전 시뮬레이터(`python -m worldmodel.device_sim --mqtt <브로커>`), 정빈 중앙(`DEVICE_TRANSPORT=mqtt`) 실행 | 중앙이 스냅샷 202, 판단 기록이 생김, 스냅샷에 기기 6대 (없으면 5~7단계 명령이 안 나옴) |
| 3 | 다른 방은 가짜로 | 반석: `python -m publisher.fake_sender --mqtt <브로커> --skip room1 --step` | 거실 B·세탁기 등이 월드모델에 보임 |
| 4 | 실제 Node 켜기 | 반석: `python main.py --mqtt <브로커> --jsonl recordings/2026-11-26.jsonl` | 방1 상태가 실시간으로 |
| 5 | t1~t3: 들어와 누움 → 질문 → "응" | 효창(A)이 침대에 누움 | ③ 스피커 "효창님, 주무실 건가요?" → ④ "응" → 중앙이 조명 끄기·커튼 닫기 |
| 6 | t4~t5: 어둠 → "하이 엘지, 불 켜줘" | 효창이 말함 | ④ 명령 → ③ "네 효창님, 불을 켤게요." → 조명 켬 |
| 7 | t6: 나감 | 효창이 방을 나감 | 방1 EMPTY → 청소기 방1 청소 (3단계 가짜 송신기로 방2도 EMPTY여야 함) |

- (11-26 효창 요청) 가전 시뮬레이터는 원래 8단계였으나 2단계로 옮김: 가전 상태가 없으면 중앙이 5~7단계 명령을 내지 않는다.

- 4단계부터 Node가 보낸 것을 모두 `recordings/2026-11-26.jsonl`로 남긴다. 다음에 같은 장면을 사람 없이 재생할 수 있다.
- 시연 영상 전에 각 단계가 되는지만 확인하고, 촬영은 따로 잡는다.

## 그 자리에서 같이 할 것

- ~~송정빈 얼굴이 MEMBER_B인지 C인지 확인~~ → **MEMBER_B로 확인** (11-26 거실 촬영에서 카메라가 정빈을 MEMBER_B로 식별). 가짜 송신기·월드모델 B 연결 그대로.
- (동의하면) **목소리 등록**: 목소리로 누구인지 알아보는 기능용. 한 사람당 짧은 문장 5개, 목소리 특징값만 Node에 남기고 녹음은 저장하지 않음.
  실제로 명령을 말할 자리(**침대**)에서 등록: `python -m audio.enroll_voice --name MEMBER_D` (정빈은 얼굴 확인 후 B·C 중 맞는 이름).
  등록 뒤 `--test`로 서로의 목소리를 몇 번씩 말해 보고 기준값(지금 0.65)을 정함. 반석(MEMBER_A)은 등록 완료, 본인 0.78.
- 다음 통합 날짜, 시연 영상 촬영 날짜

## 막히면

| 증상 | 확인 |
|---|---|
| 다른 노트북이 브로커에 못 붙음 | 같은 핫스팟인지, 반석 노트북 방화벽(mosquitto 연결 허용), 주소(IP) |
| 월드모델이 메시지를 거절 | schema_version (0.2), room_id와 토픽의 방이 같은지 |
| 중앙에 HTTP가 안 감 | 중앙을 `HOST=0.0.0.0`으로 띄웠는지, 주소·포트 8765 |
| 질문이 스피커로 안 나옴 | 중앙이 `eyear/v0/room1/speak`로 보내는지 (`mosquitto_sub`로 확인) |
| 메시지가 오래됐다고 버려짐 | 노트북 시간 자동 설정 |
