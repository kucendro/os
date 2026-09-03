env_file=${TELEGRAM_ENV:-/var/lib/gitea-runner/telegram.env}

if [ -z "${BOT_TOKEN:-}" ] || [ -z "${CHAT_ID:-}" ]; then
  if [ ! -r "$env_file" ]; then
    echo "$env_file unreadable" >&2
    exit 1
  fi
  # shellcheck source=/dev/null
  . "$env_file"
fi

api="https://api.telegram.org/bot$BOT_TOKEN"

case "${1:-}" in
message)
  curl -fsS -o /dev/null -X POST "$api/sendMessage" \
    --data-urlencode "chat_id=$CHAT_ID" \
    --data-urlencode "text=$2"
  ;;
photo)
  curl -fsS -o /dev/null -X POST "$api/sendPhoto" \
    -F chat_id="$CHAT_ID" \
    -F photo=@"$2" \
    -F caption="${3:-}"
  ;;
document)
  curl -fsS -o /dev/null -X POST "$api/sendDocument" \
    -F chat_id="$CHAT_ID" \
    -F document=@"$2" \
    -F caption="${3:-}"
  ;;
*)
  exit 2
  ;;
esac
