#!/usr/bin/env bash
# Slide graphics: (A) speaker repo artifacts via GitHub search; (B) ffmpeg scene cuts.
# Usage: ./04_slides.sh VIDEO_ID OUT_DIR "speaker-slug" ["optional repo"]
set -euo pipefail
vid="$1"; out="${2:-out}"; slug="${3:-}"; repo="${4:-}"
mkdir -p "$out/slide-captions" "$out/docs"

echo "== A: speaker artifacts =="
if [ -n "$repo" ]; then
  echo "repo $repo"
else
  echo "search github for $slug with 'img', 'demo', 'slides' keywords:"
  gh api "search/code?q=$slug+img+filename:README" --jq '.items[].repository.full_name' 2>/dev/null \
    | head -5 || true
  echo "(pick the repo, add it as \$4 for a full artifacts pull)"
fi
if [ -n "$repo" ]; then
  tree=$(curl -sfL "https://api.github.com/repos/$repo/git/trees/HEAD?recursive=1")
  echo "$tree" | python3 -c "
import json,sys
d=json.load(sys.stdin)
for t in d.get('tree',[]):
    p=t['path']
    if p.endswith(('.png','.jpg','.svg','.pdf')) or any(k in p.lower() for k in ('readme','story','query','skill')):
        print(f\"{t.get('size','')}\t{p}\")"
  echo "downloads handled by scripts/pull_repo.py" 
fi

echo "== B: film slides via ffmpeg scene-detect =="
talk="$out/talk.mp4"; [ -f "$talk" ] || { echo "no video yet; run 03 first"; exit 0; }
for th in 0.18 0.10 0.055; do
  ffmpeg -y -hide_banner -loglevel info -i "$talk" \
    -vf "select='gt(scene,$th)',showinfo" -vsync vfr -fps_mode passthrough \
    "$out/slide-captions/th$th_%03d.jpg" -f null - 2> "$out/scenes_$th.log" || true
done
# timestamped contact sheet for dedupe
ffmpeg -y -hide_banner -loglevel error -pattern_type glob -i "$out/slide-captions/*.jpg" \
  -filter_complex "scale=480:-1,tile=6x4" "$out/contact_sheet.jpg" 2>/dev/null || true
echo "scene times:"
for f in "$out"/scenes_*.log; do
  echo "== $f"
  grep -oE "n: *[0-9]+ .*pts_time:[0-9.]+" "$f" \
    | sed -E 's/^.*n: *([0-9]+).*pts_time:([0-9.]+).*/\2/' | head -25 | sort -nu | head -25
done
