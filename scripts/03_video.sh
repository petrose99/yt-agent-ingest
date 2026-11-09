#!/usr/bin/env bash
# Video acquisition ladder: yt-dlp → Invidious direct → Invidious through one browser session
# (cap.js cookie + `check=` token) → everything again over Tor if IP-flagged.
# Usage: ./03_video.sh VIDEO_ID OUT_DIR
set -euo pipefail
vid="$1"; out="${2:-out}"; mkdir -p "$out"
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0 Safari/537.36"
PROXY_ARG=()
if [ "${USE_TOR:-0}" = "1" ] && command -v tor >/dev/null; then
  service tor start 2>/dev/null || true; sleep 2
  PROXY_ARG=(--socks5-hostname 127.0.0.1:9050)
  echo "routing via tor"
fi

echo "== rung 1: yt-dlp =="
if command -v yt-dlp >/dev/null; then
  yt-dlp -w -f "bv*[height<=1080]+ba/b" --merge-output-format mp4 \
    -o "$out/talk.mp4" "https://www.youtube.com/watch?v=$vid" && exit 0 || true
fi

echo "== rung 2: Invidious DASH round-trip =="
for inst in $(curl -s "${PROXY_ARG[@]}" "https://api.invidious.io/instances.json" \
  | python3 -c "import json,sys;d=json.load(sys.stdin);print(' '.join(i[1]['uri'].replace('https://','') for i in d if len(i)>1 and i[1].get('type')=='https' and i[1].get('api')!=False))"); do
  echo " trying $inst (api docs + video json)"
  curl -s -m 30 "${PROXY_ARG[@]}" "https://$inst/api/v1/videos/$vid" -o "$out/invvid.json" || continue
  python3 - "$out/invvid.json" <<'PY' || continue
import json,sys
d=json.load(open(sys.argv[1]))
best={}
for f in d.get('adaptiveFormats',[]):
    it=str(f.get('itag')); u=f.get('url')
    if u and it not in best: best[it]=u
for it in ('299','303','135','134','140','251'):
    if it in best:
        open(f"{sys.argv[1].rsplit('/',1)[0]}/url_{it}.txt","w").write(best[it])
        print("itag",it,"url saved")
print("OK")
PY
  # video+audio URLs point at googlevideo (instance-locked): use local proxy path when allowed
  for itag in 299 140; do
    [ -f "$out/url_$itag.txt" ] || continue
    python3 - "$out/url_$itag.txt" "$inst" <<'PY'
import sys
from urllib.parse import urlparse
p=urlparse(open(sys.argv[1]).read().strip())
inst=sys.argv[2]
open(sys.argv[1], "w").write(f"https://{inst}{p.path}?{p.query}&local=true")
PY
    curl -s "${PROXY_ARG[@]}" -A "$UA" -m 1200 "$(cat "$out/url_$itag.txt")" \
      -o "$out/track.$itag" -w "$itag %{http_code} %{size_download}\n" || true
  done
  if [ -s "$out/track.299" ] && [ -s "$out/track.140" ]; then
    ffmpeg -y -i "$out/track.299" -i "$out/track.140" -c copy \
      -map 0:v:0 -map 1:a:0 -shortest "$out/talk.mp4" && exit 0
  fi
done

echo "== rung 3: browser session solve (cap.js + cookbook in README '03') =="
echo "Run scripts/solve_browser.py — see README. That session fingerprints as a real browser under Xvfb;"
echo "click the cap-widget, capture captcha_verified + fresh DASH manifest with check= token, then:"
echo "  ffmpeg -i track.299 -i track.140 ..."
exit 1
