# EYEAR 서버 (AWS EC2) 설정 원본

팀 서버를 다시 만들거나 설정을 확인할 때 쓰는 파일. **비밀번호·API 키·.pem은 여기에 넣지 않는다** (이 레포는 공개).
담당: 신반석 (2026-11-27). 서버에 있는 것과 같은 내용이며, 서버 설정을 바꾸면 여기도 같이 고친다.

## 지금 서버
- AWS 서울(ap-northeast-2), Ubuntu 24.04, t3.medium(메모리 4GB) + 스왑 2GB, 디스크 20GB, 탄력적 IP `13.125.114.142`
- 보안 그룹(바깥에서 들어올 수 있는 포트): 22(SSH, 관리자 IP만), 1883(MQTT, 비밀번호), 8081(앱 백엔드)
  - 열지 않음: 8765(중앙), 1884(서버 안 MQTT), 5432(DB), 8770(Node 등록 — 집 와이파이 전용)
- Node(카메라·마이크·레이더)는 서버에 올리지 않는다. 원본 영상·음성은 Node 밖으로 나가지 않음 (R-10).

```
Node 노트북 ──MQTT 1883(비밀번호)──▶ mosquitto ──1884(서버 안)──▶ eyear-worldmodel ──HTTP──▶ eyear-orchestrator
                                         ▲                                   eyear-devices(가전 시뮬레이터)
앱(폰) ──HTTP 8081──▶ eyear-app(Spring) ── PostgreSQL
```

## 서비스 (systemd, 재부팅해도 자동 시작, 죽으면 자동 재시작)
| 서비스 | 내용 | 파일 |
|---|---|---|
| `eyear-orchestrator` | 중앙 에이전트 :8765 (`~/eyear-orchestrator/.env`) | systemd/eyear-orchestrator.service |
| `eyear-worldmodel` | 월드모델 `worldmodel.live --mqtt 127.0.0.1:1884` | systemd/eyear-worldmodel.service |
| `eyear-devices` | 가전 시뮬레이터 `worldmodel.device_sim` | systemd/eyear-devices.service |
| `eyear-app` | 앱 백엔드 :8081 (`~/deploy/app.jar`, `~/.config/eyear/app.env`, `~/secret.properties`) | systemd/eyear-app.service |
| `eyear-deploy.timer` | 1분마다 자동 배포 | systemd/eyear-deploy.{service,timer} |

## 자동 배포 (`eyear-deploy.sh`)
- eyear-orchestrator·eyear-worldmodel·eyear-app의 **main**에 새 커밋이 있으면 받아서 설치·빌드하고 그 서비스만 재시작.
- 설치·빌드 실패, 또는 재시작 뒤 서비스가 죽으면 **이전 커밋(앱은 이전 jar)으로 되돌림**.
- 서버에서 레포를 직접 고치면 받지 못하고 건너뜀 → 수정은 항상 레포에 push.
- 기록: `~/deploy/deploy.log`. **멈춤: `touch ~/deploy/FREEZE`** (발표 당일), 다시 켜기: `rm ~/deploy/FREEZE`.

## 자주 쓰는 명령 (서버에서)
```bash
tail -20 ~/deploy/deploy.log                                   # 배포 기록
journalctl -u eyear-orchestrator -f                            # 로그 (worldmodel, devices, app 같은 방식)
systemctl status eyear-orchestrator eyear-worldmodel eyear-devices eyear-app
sudo systemctl restart eyear-orchestrator                      # 직접 다시 시작
curl -s http://127.0.0.1:8765/v1/status                        # 중앙 상태 (llm, session_id)
```

## 새 서버에 다시 설치할 때 (요약)
1. 패키지: `sudo apt install -y git python3-venv openjdk-17-jdk postgresql mosquitto mosquitto-clients`
2. 스왑 2GB: `sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile`
   + `/etc/fstab`에 `/swapfile none swap sw 0 0`
3. mosquitto: `mosquitto/eyear.conf` → `/etc/mosquitto/conf.d/`, 비밀번호 파일 만들기(파일 안 설명), `sudo systemctl restart mosquitto`
4. 레포 3개를 `~/`에 clone 하고 각자 `.venv`:
   - orchestrator: `python3 -m venv .venv && .venv/bin/pip install -e . scikit-learn==1.9.1`, `.env`는 `orchestrator.env.example` 참고
   - worldmodel: `python3 -m venv .venv && .venv/bin/pip install -e .`
   - app: PostgreSQL 사용자·DB `eyear` 만들기, `cd backend && ./gradlew bootJar -x test`, jar를 `~/deploy/app.jar`로 복사,
     `~/.config/eyear/app.env`(`app.env.example`, 권한 600), `~/secret.properties`(정예원에게 받은 키 7개, 권한 600)
5. `eyear-deploy.sh` → `~/deploy/` (실행 권한), `systemd/*` → `/etc/systemd/system/`,
   `sudo systemctl daemon-reload && sudo systemctl enable --now eyear-orchestrator eyear-worldmodel eyear-devices eyear-app eyear-deploy.timer`
