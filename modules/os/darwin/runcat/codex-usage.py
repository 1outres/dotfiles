"""RunCat Neo custom metrics producer for Codex, driven by launchd on a timer.

Reads ~/.codex/auth.json for the ChatGPT OAuth token, calls
https://chatgpt.com/backend-api/wham/usage, and writes a snapshot to
~/.codex/runcat-usage.json.
"""

import json
import os
import sys
import tempfile
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path


CODEX_DIR = Path.home() / ".codex"
AUTH_FILE = CODEX_DIR / "auth.json"
OUT = Path(os.environ.get("RUNCAT_OUT_FILE", str(CODEX_DIR / "runcat-usage.json")))
USAGE_URL = "https://chatgpt.com/backend-api/wham/usage"
REQUEST_TIMEOUT_SECONDS = 10


def load_auth():
    try:
        with AUTH_FILE.open(encoding="utf-8") as auth:
            data = json.load(auth)
    except (OSError, json.JSONDecodeError) as err:
        raise RuntimeError(f"could not read {AUTH_FILE}: {err}") from err
    tokens = data.get("tokens") or {}
    access_token = tokens.get("access_token")
    if not isinstance(access_token, str) or not access_token:
        raise RuntimeError("tokens.access_token missing in auth.json")
    account_id = tokens.get("account_id")
    return access_token, account_id if isinstance(account_id, str) and account_id else None


def fetch_usage(access_token, account_id):
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Accept": "application/json",
        "User-Agent": "codex-cli",
    }
    if account_id:
        headers["ChatGPT-Account-Id"] = account_id
    request = urllib.request.Request(USAGE_URL, headers=headers, method="GET")
    with urllib.request.urlopen(request, timeout=REQUEST_TIMEOUT_SECONDS) as response:
        body = response.read()
    return json.loads(body)


def format_reset(reset_epoch):
    if not isinstance(reset_epoch, (int, float)) or reset_epoch <= 0:
        return None
    now_epoch = datetime.now(timezone.utc).timestamp()
    delta = int(reset_epoch - now_epoch)
    if delta <= 0:
        return "now"
    days, rem = divmod(delta, 86400)
    hours, rem = divmod(rem, 3600)
    minutes = rem // 60
    if days > 0:
        return f"{days}d{hours}h" if hours else f"{days}d"
    if hours > 0:
        return f"{hours}h{minutes}m" if minutes else f"{hours}h"
    return f"{minutes}m"


def percentage_metric(title, used_percent, reset_at):
    if not isinstance(used_percent, (int, float)):
        return None
    clamped = max(0.0, min(float(used_percent), 100.0))
    formatted = f"{clamped:.1f}".rstrip("0").rstrip(".")
    reset_str = format_reset(reset_at)
    value = f"{formatted}%" if reset_str is None else f"{formatted}% · {reset_str}"
    return {
        "title": title,
        "formattedValue": value,
        "normalizedValue": round(clamped / 100, 4),
    }


def window_title(limit_window_seconds):
    if not isinstance(limit_window_seconds, (int, float)) or limit_window_seconds <= 0:
        return None
    minutes = limit_window_seconds / 60
    if minutes % 1440 == 0:
        return f"{minutes / 1440:g}d"
    if minutes % 60 == 0:
        return f"{minutes / 60:g}h"
    return f"{minutes:g}m"


def rate_limit_metrics(rate_limit):
    if not isinstance(rate_limit, dict):
        return []
    metrics = []
    seen = set()
    for key in ("primary_window", "secondary_window"):
        window = rate_limit.get(key) or {}
        title = window_title(window.get("limit_window_seconds"))
        metric = (
            percentage_metric(title, window.get("used_percent"), window.get("reset_at"))
            if title
            else None
        )
        if metric is not None and title not in seen:
            metrics.append(metric)
            seen.add(title)
    return metrics


def bar_value(rate_metric):
    return rate_metric["formattedValue"].split(" ", 1)[0]


def build_snapshot(payload):
    rate_metrics = rate_limit_metrics(payload.get("rate_limit"))

    snapshot = {
        "title": "Codex",
        "symbol": "camera.aperture",
        "metrics": rate_metrics,
        "lastUpdatedDate": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }
    if rate_metrics:
        snapshot["metricsBarValue"] = bar_value(rate_metrics[0])
    return snapshot


def write_snapshot(snapshot):
    OUT.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix=".runcat-", dir=str(OUT.parent))
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as output:
            json.dump(snapshot, output, ensure_ascii=False)
        os.replace(tmp, OUT)
    except Exception:
        try:
            os.unlink(tmp)
        except OSError:
            pass
        raise


def main():
    access_token, account_id = load_auth()
    try:
        payload = fetch_usage(access_token, account_id)
    except urllib.error.HTTPError as err:
        raise RuntimeError(f"HTTP {err.code} from usage endpoint") from err
    except urllib.error.URLError as err:
        raise RuntimeError(f"network error: {err.reason}") from err
    write_snapshot(build_snapshot(payload))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except SystemExit:
        raise
    except Exception as err:
        print(f"runcat-codex-usage: {err}", file=sys.stderr)
        raise SystemExit(0)
