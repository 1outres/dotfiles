out="${RUNCAT_OUT_FILE:-$HOME/.claude/runcat-usage.json}"
card_title="Claude Code"
card_symbol="staroflife"
now=$(date -u +%Y-%m-%dT%H:%M:%SZ)

write_snapshot() {
  local out_dir tmp
  out_dir=$(dirname "$out")
  mkdir -p "$out_dir"
  tmp=$(mktemp "$out_dir/.runcat-XXXXXX")
  printf '%s' "$1" > "$tmp"
  mv "$tmp" "$out"
}

# Only Claude Code can refresh the token, because the refresh token rotates.
# So we show that the token has expired instead of keeping old numbers.
write_expired_snapshot() {
  write_snapshot "$(jq -n --arg title "$card_title" --arg symbol "$card_symbol" --arg now "$now" '{
    title: $title,
    symbol: $symbol,
    metrics: [{title: "Token", formattedValue: "Expired. Open Claude Code"}],
    metricsBarValue: "expired",
    lastUpdatedDate: $now
  }')"
}

creds_json=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null || true)
if [ -z "$creds_json" ]; then
  echo "runcat-claude-usage: no credentials in Keychain" >&2
  exit 0
fi

token=$(printf '%s' "$creds_json" | jq -r '.claudeAiOauth.accessToken // .accessToken // empty')
if [ -z "$token" ]; then
  echo "runcat-claude-usage: could not extract accessToken" >&2
  exit 0
fi

expires_at_ms=$(printf '%s' "$creds_json" | jq -r '.claudeAiOauth.expiresAt // empty')
if [ -z "$expires_at_ms" ]; then
  echo "runcat-claude-usage: could not extract expiresAt" >&2
  exit 0
fi

if [ "$expires_at_ms" -le "$(($(date +%s) * 1000))" ]; then
  echo "runcat-claude-usage: access token expired" >&2
  write_expired_snapshot
  exit 0
fi

body_file=$(mktemp)
trap 'rm -f "$body_file"' EXIT

http_code=$(curl -sS --max-time 10 -o "$body_file" -w "%{http_code}" \
  -H "Authorization: Bearer $token" \
  -H "anthropic-beta: oauth-2025-04-20" \
  -H "Accept: application/json" \
  "https://api.anthropic.com/api/oauth/usage" || echo "000")

case "$http_code" in
  200) ;;
  401)
    echo "runcat-claude-usage: HTTP 401" >&2
    write_expired_snapshot
    exit 0
    ;;
  *)
    echo "runcat-claude-usage: HTTP $http_code" >&2
    exit 0
    ;;
esac

snapshot=$(jq --arg title "$card_title" --arg symbol "$card_symbol" --arg now "$now" '
  def reset_str($resets_at):
    if $resets_at == null then null
    else
      ($resets_at
        | sub("\\.[0-9]+"; "")
        | sub("\\+00:00$"; "Z")
        | sub("\\+0000$"; "Z")
        | fromdateiso8601) as $r
      | (now | floor) as $n
      | ($r - $n) as $sec
      | if $sec <= 0 then "now"
        elif $sec < 3600 then "\(($sec / 60) | floor)m"
        elif $sec < 86400 then
          (($sec / 3600 | floor) as $h
          | (($sec % 3600) / 60 | floor) as $m
          | if $m == 0 then "\($h)h" else "\($h)h\($m)m" end)
        else
          (($sec / 86400 | floor) as $d
          | (($sec % 86400) / 3600 | floor) as $h
          | if $h == 0 then "\($d)d" else "\($d)d\($h)h" end)
        end
    end;
  def limit_title:
    if .kind == "session" then "5h"
    elif .kind == "weekly_all" then "7d"
    elif .kind == "weekly_scoped" then .scope.model.display_name
    else null
    end;
  def metric:
    limit_title as $t
    | select($t != null)
    | reset_str(.resets_at) as $reset
    | {
      title: $t,
      formattedValue: (if $reset == null then "\(.percent | round)%" else "\(.percent | round)% · \($reset)" end),
      normalizedValue: ((.percent / 100 * 10000 | round) / 10000)
    };
  {
    title: $title,
    symbol: $symbol,
    metrics: [.limits[] | metric],
    metricsBarValue: (
      [.limits[] | select(.kind == "session") | "\(.percent | round)%"]
      | first
    ),
    lastUpdatedDate: $now
  }
  | with_entries(select(.value != null))
' < "$body_file")

write_snapshot "$snapshot"
