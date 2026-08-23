#!/usr/bin/env bash
# ELI5 export: HTML -> PDF or PNG via headless Chromium.
# Usage: export.sh <file.html> [pdf|png] [outdir]
set -uo pipefail

HTML="${1:?usage: export.sh <file.html> [pdf|png] [outdir]}"
FMT="${2:-pdf}"
OUTDIR="${3:-$(dirname "$HTML")}"

# Locate a Chromium-family binary: PATH first, then playwright caches
CHROME=""
for c in chromium chromium-browser google-chrome google-chrome-stable chrome headless_shell; do
  if command -v "$c" >/dev/null 2>&1; then CHROME="$c"; break; fi
done
if [ -z "$CHROME" ]; then
  for base in "$HOME/.cache/ms-playwright" "$HOME/.cache/puppeteer"; do
    [ -d "$base" ] || continue
    FOUND="$(find "$base" -type f \( -name chrome -o -name headless_shell \) 2>/dev/null | head -1)"
    if [ -n "$FOUND" ]; then CHROME="$FOUND"; break; fi
  done
fi
if [ -z "$CHROME" ]; then
  echo "ERROR: no Chromium/Chrome found. Install chromium/google-chrome, or run: python3 -m playwright install chromium" >&2
  exit 1
fi

BASE="$(basename "$HTML" .html)"
OUT="$OUTDIR/$BASE.$FMT"
mkdir -p "$OUTDIR"

case "$FMT" in
  pdf)
    "$CHROME" --headless --disable-gpu --no-sandbox \
      --print-to-pdf="$OUT" --no-pdf-header-footer \
      "file://$(realpath "$HTML")" 2>/tmp/eli5-chrome-err.log
    RC=$?
    ;;
  png)
    W="${ELI5_PNG_WIDTH:-1200}"
    "$CHROME" --headless --disable-gpu --no-sandbox \
      --screenshot="$OUT" --window-size=${W},8000 \
      "file://$(realpath "$HTML")" 2>/tmp/eli5-chrome-err.log
    RC=$?
    ;;
  *)
    echo "ERROR: format must be pdf or png, got '$FMT'" >&2
    exit 1
    ;;
esac

if [ $RC -ne 0 ]; then
  echo "ERROR: Chromium failed (exit $RC)." >&2
  if grep -q "shared libraries" /tmp/eli5-chrome-err.log 2>/dev/null; then
    echo "  Missing system libraries. On Debian/Ubuntu run:" >&2
    echo "    sudo apt install -y libnspr4 libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libxcomposite1 libxdamage1 libatspi2.0-0" >&2
    echo "  Or export on any machine with a browser: open the HTML and Ctrl+P -> Save as PDF." >&2
  else
    echo "  Log: $(tail -2 /tmp/eli5-chrome-err.log 2>/dev/null)" >&2
  fi
  exit 1
fi

if [ -s "$OUT" ]; then
  echo "OK: $OUT ($(du -h "$OUT" | cut -f1))"
else
  echo "ERROR: output empty/failed: $OUT" >&2
  exit 1
fi
