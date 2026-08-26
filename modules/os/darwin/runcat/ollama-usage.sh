out="${RUNCAT_OUT_FILE:-$HOME/.ollama/runcat-usage.json}"

key=$(security find-generic-password -s "ollama-cloud" -w 2>/dev/null || true)
if [ -z "$key" ]; then
  echo "runcat-ollama-usage: no API key in Keychain (service: ollama-cloud)" >&2
  exit 0
fi

body_file=$(mktemp)
trap 'rm -f "$body_file"' EXIT

http_code=$(curl -sS --max-time 10 -o "$body_file" -w "%{http_code}" \
  -H "Authorization: Bearer $key" \
  -H "Accept: application/json" \
  "https://ollama.com/api/usage" || echo "000")

if [ "$http_code" != "200" ]; then
  echo "runcat-ollama-usage: HTTP $http_code" >&2
  exit 0
fi

now=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# /api/usage はリセット時刻を返さない。ollama.com/settings の HTML には
# data-time として入っているが、あちらは cookie 認証専用で API キーが効かない。
# 観測した境界は全ユーザ共通の固定グリッド上にあったため算出で代替する:
#   session: Unix エポック起点の 5h グリッド (2026-07-28T02:00:00Z % 18000 == 0)
#   weekly:  月曜 00:00 UTC 起点の 7d グリッド (2026-08-03T00:00:00Z)
snapshot=$(jq --arg now "$now" '
  def next_boundary($period; $offset):
    (now | floor) as $n
    | ((($n - $offset) / $period) | floor + 1) * $period + $offset;

  def reset_str($epoch):
    ($epoch - (now | floor)) as $sec
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
      end;

  def pct($t; $v; $reset):
    if $v == null then empty
    else
      {
        title: $t,
        formattedValue: "\(($v * 100) | round)% · \(reset_str($reset))",
        normalizedValue: (($v * 10000 | round) / 10000)
      }
    end;

  {
    title: "Ollama Cloud",
    symbol: "cloud",
    metrics: [
      pct("5h"; .limits.session.usage; next_boundary(18000; 0)),
      pct("7d"; .limits.weekly.usage;  next_boundary(604800; 345600))
    ],
    metricsBarValue: (
      .limits.session.usage
      | if . == null then null else "\((. * 100) | round)%" end
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
