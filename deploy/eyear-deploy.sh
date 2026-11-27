#!/bin/bash
# EYEAR 자동 배포: GitHub main에 새 커밋이 있으면 받아서 설치·빌드하고 그 서비스만 다시 시작한다.
# - 설치·빌드가 실패하거나 재시작 뒤 서비스가 죽으면 이전 커밋으로 되돌리고 이전 버전을 계속 돌린다.
# - ~/deploy/FREEZE 파일이 있으면 아무것도 하지 않는다 (발표 당일 등). 기록: ~/deploy/deploy.log
set -u
DEPLOY=/home/ubuntu/deploy
LOG=$DEPLOY/deploy.log
exec 9>"$DEPLOY/.lock"
flock -n 9 || exit 0
[ -f "$DEPLOY/FREEZE" ] && exit 0
log() { echo "$(date '+%F %T') $*" >> "$LOG"; }

healthy() {  # 재시작하고 기다린 뒤에도 서비스가 살아 있는지
  local wait=$1; shift
  sleep "$wait"
  for s in "$@"; do systemctl is-active --quiet "$s" || return 1; done
}

install_orchestrator() { .venv/bin/pip install -q -e . "scikit-learn==1.9.1" && .venv/bin/python -c "import orchestrator.server"; }
install_worldmodel()   { .venv/bin/pip install -q -e . && .venv/bin/python -c "import worldmodel.live, worldmodel.device_sim"; }
install_app() {
  (cd backend && ./gradlew bootJar -x test -q) || return 1
  local jar; jar=$(ls backend/build/libs/*.jar 2>/dev/null | grep -v plain | head -1)
  [ -n "$jar" ] || return 1
  cp -f "$DEPLOY/app.jar" "$DEPLOY/app.jar.prev" 2>/dev/null
  cp -f "$jar" "$DEPLOY/app.jar.new" && mv -f "$DEPLOY/app.jar.new" "$DEPLOY/app.jar"
}

deploy() {  # 레포 설치함수 기다릴초 서비스...
  local repo=$1 fn=$2 wait=$3; shift 3
  cd "/home/ubuntu/$repo" || return
  git fetch -q origin main 2>>"$LOG" || { log "$repo: GitHub 확인 실패"; return; }
  local old new
  old=$(git rev-parse HEAD); new=$(git rev-parse origin/main)
  [ "$old" = "$new" ] && return
  if ! git merge -q --ff-only origin/main >>"$LOG" 2>&1; then
    log "$repo: 서버에 따로 고친 것이 있어 받지 못함 → 건너뜀 (git status 확인)"; return
  fi
  log "$repo: ${old:0:7} → ${new:0:7} 설치 시작"
  if ! $fn >>"$LOG" 2>&1; then
    log "$repo: 설치·빌드 실패 → ${old:0:7}로 되돌림 (서비스는 이전 버전 그대로)"
    git reset -q --hard "$old"
    [ "$fn" = install_app ] || $fn >>"$LOG" 2>&1
    return
  fi
  sudo systemctl restart "$@"
  if healthy "$wait" "$@"; then log "$repo: ${new:0:7} 배포 완료"; return; fi
  log "$repo: 재시작 뒤 서비스가 죽음 → ${old:0:7}로 되돌림"
  git reset -q --hard "$old"
  if [ "$fn" = install_app ]; then cp -f "$DEPLOY/app.jar.prev" "$DEPLOY/app.jar"; else $fn >>"$LOG" 2>&1; fi
  sudo systemctl restart "$@"
  if healthy "$wait" "$@"; then log "$repo: ${old:0:7}로 복구됨"; else log "$repo: 복구도 실패 → 확인 필요 (journalctl -u $1)"; fi
}

deploy eyear-orchestrator install_orchestrator 15 eyear-orchestrator
deploy eyear-worldmodel   install_worldmodel   15 eyear-worldmodel eyear-devices
deploy eyear-app          install_app          40 eyear-app
