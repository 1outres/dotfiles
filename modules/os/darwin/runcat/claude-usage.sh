out="${RUNCAT_OUT_FILE:-$HOME/.claude/runcat-usage.json}"

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

body_file=$(mktemp)
trap 'rm -f "$body_file"' EXIT

http_code=$(curl -sS --max-time 10 -o "$body_file" -w "%{http_code}" \
  -H "Authorization: Bearer $token" \
  -H "anthropic-beta: oauth-2025-04-20" \
  -H "Accept: application/json" \
  "https://api.anthropic.com/api/oauth/usage" || echo "000")

if [ "$http_code" != "200" ]; then
  echo "runcat-claude-usage: HTTP $http_code" >&2
  exit 0
fi

now=$(date -u +%Y-%m-%dT%H:%M:%SZ)

snapshot=$(jq --arg now "$now" '
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
  def pct($t; $v; $r):
    if $v == null then empty
    else
      reset_str($r) as $reset
      | {
        title: $t,
        formattedValue: (if $reset == null then "\($v | round)%" else "\($v | round)% · \($reset)" end),
        normalizedValue: (($v / 100 * 10000 | round) / 10000)
      }
    end;
  {
    title: "Claude Code",
    symbol: "staroflife",
    metrics: [
      pct("5h";   .five_hour.utilization;      .five_hour.resets_at),
      pct("7d";   .seven_day.utilization;      .seven_day.resets_at),
      pct("Opus"; .seven_day_opus.utilization; .seven_day_opus.resets_at)
    ],
    metricsBarValue: (
      .five_hour.utilization
      | if . == null then null else "\(round)%" end
    ),
    lastUpdatedDate: $now
  }
  | with_entries(select(.value != null))
' < "$body_file")

out_dir=$(dirname "$out")
mkdir -p "$out_dir"
tmp=$(mktemp "$out_dir/.runcat-XXXXXX")
printf '%s' "$snapshot" > "$tmp"
mv "$tmp" "$out"
