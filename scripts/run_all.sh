#!/usr/bin/env bash
set -euo pipefail
url="$1"; out="${2:-pack_slug}"
vid=$(echo "$url" | grep -oE '(v=|youtu\.be/|shorts/)[A-Za-z0-9_-]{11}' | grep -oE '[A-Za-z0-9_-]{11}$' | head -1)
[ -n "$vid" ] || vid="$url"
mkdir -p "$out"
for s in 01_metadata 02_captions 03_video 04_slides; do
  echo "=== $s ==="
  "./scripts/$s.sh" "$vid" "$out" "${3:-}" "${4:-}" || { echo "!! $s failed, continuing"; }
done
echo "=== 05_bundle ==="
./scripts/05_bundle.sh "$out" "$(basename "$out")" "YouTube talk $vid"
echo "pack at: $out"
