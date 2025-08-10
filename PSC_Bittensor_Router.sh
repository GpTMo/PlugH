#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/assistant_bittensor_psc"
SCRIPT_NAME="PSC_Bittensor_Router.sh"
SCRIPT_PATH="$BASE/$SCRIPT_NAME"
CFG_DIR="$BASE/config"
LOG_DIR="$BASE/logs"
SESS_DIR="$BASE/sessions"
CFG_FILE="$CFG_DIR/config.json"
LOG_FILE="$LOG_DIR/last_run.log"
ERR_FILE="$LOG_DIR/install_error.log"

# Ensure base directory and self-installation
mkdir -p "$BASE"
if [ "$(realpath "$0")" != "$SCRIPT_PATH" ]; then
  cp "$0" "$SCRIPT_PATH"
  exec "$SCRIPT_PATH" "$@"
fi
cd "$BASE"

mkdir -p "$CFG_DIR" "$LOG_DIR" "$SESS_DIR"

# Create default config if missing
if [ ! -f "$CFG_FILE" ]; then
  cat >"$CFG_FILE" <<'JSON'
{
  "bt_endpoint": "",
  "bt_api_key": "",
  "model": "",
  "profiles": {
    "chat":      { "temperature": 0.20, "top_p": 0.90, "max_tokens": 1024, "system": "Asistente conciso, experto." },
    "code":      { "temperature": 0.10, "top_p": 0.85, "max_tokens": 1400, "system": "Coding assistant preciso. Code in English." },
    "translate": { "temperature": 0.15, "top_p": 0.90, "max_tokens": 900,  "system": "Traducción ES/FR/EN fiel." },
    "deep":      { "temperature": 0.20, "top_p": 0.90, "max_tokens": 2048, "system": "Razonamiento profundo, pasos claros." }
  },
  "model_map": {
    "fast": "tier-fast-8b",
    "general": "tier-general-14b",
    "deep": "tier-deep-70b",
    "code": "tier-code-7b",
    "translate": "tier-trans-2b"
  }
}
JSON
fi

exec > >(tee "$LOG_FILE") 2>&1
trap 'echo "Error occurred. See $LOG_FILE" > "$ERR_FILE"' ERR

declare -A AUTH_HEADER

if command -v pwsh >/dev/null 2>&1 && [ -f "$BASE/PSC_Bittensor_Router.ps1" ]; then
  pwsh "$BASE/PSC_Bittensor_Router.ps1"
  exit $?
fi

: "${BT_ENDPOINT:?BT_ENDPOINT required}"
: "${ASK:?ASK required}"
BT_API_KEY="${BT_API_KEY:-}"
MODEL="${MODEL:-}"
PROFILE="${PROFILE:-chat}"
POLICY="${POLICY:-auto}"
STREAM="${STREAM:-0}"

normalize_endpoint() {
  local ep="$1"
  ep="${ep%/}"
  [[ "$ep" == */v1 ]] || ep+="/v1"
  echo "$ep"
}
ENDPOINT="$(normalize_endpoint "$BT_ENDPOINT")"

if [ -n "$BT_API_KEY" ]; then
  AUTH_HEADER=(-H "Authorization: Bearer $BT_API_KEY")
else
  AUTH_HEADER=()
fi

MODELS_JSON=$(mktemp)
HTTP_STATUS=$(curl -sS -w "%{http_code}" "${AUTH_HEADER[@]}" "$ENDPOINT/models" -o "$MODELS_JSON")
if [ "$HTTP_STATUS" != "200" ]; then
  echo "Failed to fetch models ($HTTP_STATUS)" >&2
  exit 1
fi
cat "$MODELS_JSON"

SEL_JSON=$(python3 - "$CFG_FILE" "$MODELS_JSON" <<'PY'
import json,sys,os,re
cfg=json.load(open(sys.argv[1]))
models=json.load(open(sys.argv[2]))['data']
avail=[m['id'] for m in models]
ask=os.environ['ASK']
model=os.environ.get('MODEL','').strip()
policy=os.environ.get('POLICY','auto')
profile_name=os.environ.get('PROFILE','chat')
profile=cfg['profiles'].get(profile_name,cfg['profiles']['chat'])
model_map=cfg['model_map']
chosen=None
if model:
    chosen=model
elif policy!='auto':
    chosen=model_map.get(policy)
else:
    txt=ask.lower()
    if re.search(r"```|\b(function|class|error|regex|code|python|javascript|java|c\+\+|c#|go|rust|ruby|typescript)\b", txt):
        chosen=model_map['code']
    elif re.search(r"translate|traduce|traducción|->\s*(en|es|fr)", txt):
        chosen=model_map['translate']
    else:
        words=len(txt.split())
        if words>280:
            chosen=model_map['deep']
        elif words>80:
            chosen=model_map['general']
        else:
            chosen=model_map['fast']
if chosen not in avail:
    fb=avail[0] if avail else ''
    print(f"WARN: model {chosen} not available; using {fb}", file=sys.stderr)
    chosen=fb
out={
  'model': chosen,
  'temperature': profile['temperature'],
  'top_p': profile['top_p'],
  'max_tokens': profile['max_tokens'],
  'system': profile['system']
}
print(json.dumps(out))
PY
)
export SEL_JSON

REQ_JSON=$(python3 - <<'PY'
import json,os
cfg=json.loads(os.environ['SEL_JSON'])
body={
  'model': cfg['model'],
  'messages': [
    {'role':'system','content':cfg['system']},
    {'role':'user','content':os.environ['ASK']}
  ],
  'temperature': cfg['temperature'],
  'top_p': cfg['top_p'],
  'max_tokens': cfg['max_tokens'],
  'stream': os.environ['STREAM']=='1'
}
print(json.dumps(body))
PY
)

SESSION_FILE="$SESS_DIR/bt_$(date +%Y%m%d_%H%M%S).txt"

if [ "$STREAM" = "1" ]; then
  curl -sS -N "${AUTH_HEADER[@]}" -H "Content-Type: application/json" "$ENDPOINT/chat/completions" -d "$REQ_JSON" |
  while read -r line; do
    if [[ $line == "data: [DONE]"* ]]; then
      echo "[DONE]"
      break
    elif [[ $line == data:* ]]; then
      chunk=${line#data: }
      token=$(printf '%s' "$chunk" | python3 -c 'import sys,json;print(json.load(sys.stdin)["choices"][0]["delta"].get("content",""), end="")')
      printf '%s' "$token" | tee -a "$SESSION_FILE"
    fi
  done
else
  RESP=$(curl -sS "${AUTH_HEADER[@]}" -H "Content-Type: application/json" "$ENDPOINT/chat/completions" -d "$REQ_JSON")
  TEXT=$(echo "$RESP" | python3 -c 'import sys,json;print(json.load(sys.stdin)["choices"][0]["message"]["content"])')
  echo "$TEXT" | tee "$SESSION_FILE"
fi

rm -f "$MODELS_JSON"
