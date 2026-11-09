#!/usr/bin/env bash
# Rung ladder for captions: yt-dlp → Invidious API → publisher page.
# Usage: ./02_captions.sh VIDEO_ID OUT_DIR
set -euo pipefail
vid="$1"; out="${2:-out}"; mkdir -p "$out"

UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0 Safari/537.36"

echo "== rung 1: yt-dlp auto-subs =="
if command -v yt-dlp >/dev/null; then
  if yt-dlp --write-auto-subs --write-subs --sub-langs "en.*" --sub-format vtt \
      --skip-download -o "$out/vid.%(ext)s" "https://www.youtube.com/watch?v=$vid"; then
    f=$(ls "$out"/*.vtt 2>/dev/null | head -1)
    [ -n "${f:-}" ] && { cp "$f" "$out/TRANSCRIPT-captions-en.vtt"; echo "captions via yt-dlp: $f"; exit 0; }
  fi
fi

echo "== rung 2: Invidious instances =="
for inst in $(curl -s "https://api.invidious.io/instances.json" \
  | python3 -c "import json,sys;d=json.load(sys.stdin);print(' '.join(i[1]['uri'].replace('https://','') for i in d if len(i)>1 and i[1].get('type')=='https' and i[1].get('api')!=False))"); do
  echo " trying $inst"
  if curl -s -m 20 "https://$inst/api/v1/videos/$vid?fields=title" | grep -q '$vid\|title'; then
    if curl -s -m 30 "https://$inst/api/v1/captions/$vid" | grep -q 'captions'; then
      curl -s -m 60 "https://$inst/api/v1/captions/$vid?label=English%20(auto-generated)" \
        -o "$out/TRANSCRIPT-captions-en.vtt"
      [ -s "$out/TRANSCRIPT-captions-en.vtt" ] && { echo "captions via $inst"; exit 0; }
    fi
  fi
done

echo "== rung 3: publisher pages =="
for tpl in $(cut -f2 publisher_transcripts.tsv 2>/dev/null); do
  u=${tpl//\{id\}/$vid}
  if curl -sL -m 60 -A "$UA" "$u" -o "$out/publisher.html" && [ -s "$out/publisher.html" ]; then
    python3 - <<PY
import re, html
s=open("$out/publisher.html").read()
s=re.sub(r'<script.*?</script>','',s,flags=re.S)
s=re.sub(r'<style.*?</style>','',s,flags=re.S)
open("$out/TRANSCRIPT-publisher.md","w").write(html.unescape(re.sub(r'<[^>]+>','\n',s)))
PY
    echo "publisher transcript via $u"; exit 0
  fi
done
echo "no captions found at any rung"; exit 1
