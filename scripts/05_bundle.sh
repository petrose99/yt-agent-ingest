#!/usr/bin/env bash
# Assemble the agent pack: single folder + INDEX.md manifest.
# Usage: ./05_bundle.sh OUT_DIR PACK_NAME "TALK_TITLE — CHANNEL"
set -euo pipefail
out="$1"; pack="${2:-pack}"; title="${3:-titled talk}"
mv "$out" "$pack"; cd "$pack"
mkdir -p docs paper slide-captions video
# standard moves
[ -f talk.mp4 ] && mv talk.mp4 video/
f=$(ls TRANSCRIPT-captions-en.vtt 2>/dev/null | head -1)
[ -n "${f:-}" ] && mv "$f" slide-captions/
f=$(ls TRANSCRIPT-publisher.md 2>/dev/null | head -1)
[ -n "${f:-}" ] && mv "$f" TRANSCRIPT.md
# th lxml cleanup
ls slide-captions/th*.jpg 2>/dev/null | head -400 | while read -r f; do n=$(basename "$f"); mv "$f" "slide-captions/$n"; done

cat > INDEX.md <<EOF
# Bundle: $title

**Collected:** $(date -u +%F)

\`\`\`
/video/talk.mp4
/slide-captions/TRANSCRIPT-captions-en.vtt
/slide-captions/NN_talk_at_*.jpg
/docs/
/paper/
/TRANSCRIPT.md
\`\`\`

## Suggested entry points
| Task | Read |
|---|---|
| Understand the talk fast | \`TRANSCRIPT.md\` |
| Exact words at a moment | grep \`slide-captions/TRANSCRIPT-captions-en.vtt\` |
| Every slide | \`slide-captions/NN_talk_at_*.jpg\` (filename has timestamp) |
| Reproduce the demo | \`docs/\` |
EOF

for s in docs paper slide-captions video; do mkdir -p "$s"; done
# move stray graphics into docs if the speaker artifacts landed in ./img
mv -f img/*.png img/*.jpg docs/ 2>/dev/null || true
echo "bundle built: $(ls)"
