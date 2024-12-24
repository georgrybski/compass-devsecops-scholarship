#!/usr/bin/env bash
set -e

# ==================================
# Nginx Health Endpoint Checker
# ==================================
# Checks if a given URL's /health endpoint returns HTTP 200.
# Logs JSON results to:
#   /var/log/nginx_health_endpoint/online.log   (if 200)
#   /var/log/nginx_health_endpoint/offline.log  (otherwise)

RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'

info()    { echo -e "${GREEN}[INFO]${RESET} $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
verbose() { [[ "$VERBOSE" == true ]] && echo -e "[VERBOSE] $*"; }

usage() {
  echo "Usage: $0 [OPTIONS] <BASE_URL>"
  echo
  echo "Checks the /health endpoint of <BASE_URL> and appends JSON results to:"
  echo "  /var/log/nginx_health_endpoint/online.log   or"
  echo "  /var/log/nginx_health_endpoint/offline.log"
  echo
  echo "Example:"
  echo "  $0 http://localhost"
  echo
  echo "Options:"
  echo "  -v, --verbose  Show verbose internal command logs"
  echo "  -h, --help     Show this help message"
  exit 1
}

parse_arguments() {
  VERBOSE=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -v|--verbose)
        VERBOSE=true
        shift
        ;;
      -h|--help)
        usage
        ;;
      -*)
        error "Unknown option: $1"
        usage
        ;;
      *)
        BASE_URL="$1"
        shift
        ;;
    esac
  done

  [[ -z "$BASE_URL" ]] && usage
}

parse_arguments "$@"

get_aws_instance_metadata() {
  if curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/ >/dev/null; then
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
  else
    INSTANCE_ID="${INSTANCE_ID:-localhost}"
    REGION="${REGION:-unknown}"
  fi
}

get_aws_instance_metadata

LOG_DIR="/var/log/nginx_health_endpoint"
ONLINE_LOG="$LOG_DIR/online.log"
OFFLINE_LOG="$LOG_DIR/offline.log"

info "Ensuring log directory: $LOG_DIR"
sudo mkdir -p "$LOG_DIR"
sudo touch "$ONLINE_LOG" "$OFFLINE_LOG"
sudo chmod 666 "$ONLINE_LOG" "$OFFLINE_LOG"

json_log() {
  local status="$1"
  local message="$2"
  local timestamp
  timestamp=$(date +"%Y-%m-%dT%H:%M:%SZ")

  local json_line
  json_line=$(
    jq -nc \
      --arg ts "$timestamp" \
      --arg svc "nginx_health_endpoint" \
      --arg st "$status" \
      --arg msg "$message" \
      --arg iid "$INSTANCE_ID" \
      --arg rgn "$REGION" \
      '{
        "timestamp": $ts,
        "service": $svc,
        "status": $st,
        "message": $msg,
        "instance_id": $iid,
        "region": $rgn
      }'
  )

  local log_file
  if [[ "$status" == "online" ]]; then
    log_file="$ONLINE_LOG"
  else
    log_file="$OFFLINE_LOG"
  fi

  echo "$json_line" | sudo tee -a "$log_file" >/dev/null
}

ADDRESS="$BASE_URL/health"
verbose "Checking $ADDRESS ..."

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$ADDRESS" || true)
if [[ "$HTTP_CODE" == "200" ]]; then
  STATUS="online"
  MESSAGE="Nginx health endpoint returned code $HTTP_CODE."
else
  STATUS="offline"
  MESSAGE="Nginx health endpoint returned code $HTTP_CODE."
fi

json_log "$STATUS" "$MESSAGE"
exit "$([[ "$STATUS" == "online" ]] && echo 0 || echo 1)"
