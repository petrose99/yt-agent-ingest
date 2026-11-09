#!/usr/bin/env bash
# Fetch talk metadata without auth (works even when watch pages are bot-walled).
# Usage: ./01_metadata.sh VIDEO_URL_OR_ID
set -euo pipefail
url="$1"
vid=$(echo "$url" | grep -oE '(v=|youtu\.be/|shorts/)[A-Za-z0-9_-]{11}' | grep -oE '[A-Za-z0-9_-]{11}$' || echo "$url")
curl -s "https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=$vid&format=json" \
  | tee "metadata.json"
echo
echo "video id: $vid"
