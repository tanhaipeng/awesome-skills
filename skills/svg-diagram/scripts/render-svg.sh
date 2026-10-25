#!/usr/bin/env bash
# 用 headless Chrome 把 SVG 渲染成 2 倍 PNG，不依赖 rsvg-convert / inkscape / cairosvg。
#
#   ./render-svg.sh diagram.svg
#   ./render-svg.sh diagram.svg out.png 1200 1080
#
# 注意：Chrome 截完图不会自己退出，所以这里轮询产物 + 主动 kill。
set -euo pipefail

in=${1:?用法: render-svg.sh <input.svg> [out.png] [width] [height]}
out=${2:-${in%.svg}.png}
w=${3:-1200}
h=${4:-1080}

if [ -n "${CHROME:-}" ]; then
  chrome=$CHROME
elif [ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
  chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
elif command -v google-chrome >/dev/null 2>&1; then
  chrome=google-chrome
elif command -v chromium >/dev/null 2>&1; then
  chrome=chromium
else
  echo "找不到 Chrome，可用 CHROME=/path/to/chrome 指定" >&2
  exit 1
fi

[ -f "$in" ] || { echo "找不到输入文件：$in" >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

abs=$(cd "$(dirname "$in")" && pwd)/$(basename "$in")
rm -f "$out"

"$chrome" \
  --headless=new --no-sandbox --disable-gpu \
  --disable-crash-reporter --disable-breakpad \
  --no-first-run --no-default-browser-check \
  --user-data-dir="$tmp/profile" --crash-dumps-dir="$tmp/crash" \
  --force-device-scale-factor=2 \
  --window-size="$w,$h" --hide-scrollbars \
  --default-background-color=FFFFFFFF \
  --screenshot="$out" "file://$abs" >/dev/null 2>&1 &
pid=$!

for _ in $(seq 1 60); do
  [ -s "$out" ] && break
  sleep 0.25
done

sleep 1
kill "$pid" 2>/dev/null || true
wait "$pid" 2>/dev/null || true

[ -s "$out" ] || { echo "渲染失败：没有生成 $out（检查 Chrome 是否可用）" >&2; exit 1; }

size=$(python3 - "$out" <<'PY' 2>/dev/null || true
import struct, sys
with open(sys.argv[1], "rb") as f:
    head = f.read(24)
if head[:8] == b"\x89PNG\r\n\x1a\n":
    w, h = struct.unpack(">II", head[16:24])
    print(f"{w}x{h}")
PY
)
echo "已生成 ${out}${size:+（${size}）}"
