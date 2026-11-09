# yt-agent-ingest

Turn a YouTube talk into a **machine-consumable media pack**: full caption transcript, polished
transcript, slide/frame graphics, the video itself, and a manifest an agent can navigate.

Born from ingesting *"Make Your AI Agents Predictable With Graph Engineering — Zachary
Blumenfeld, Neo4j"* (AI Engineer, `g_NgCLTibiM`) on 2026-11-09 — a day-old video behind four
layers of bot protection. The method that survived:

> metadata via oEmbed → captions from the publisher's site + Invidious → video via a working
> Invidious instance reached over Tor (bot-gates are per-IP) → slides via (a) the speaker's
> demo repo and (b) ffmpeg scene-detect frame grabs → one bundle with an `INDEX.md` manifest.

## Pipeline at a glance

```
URL given
  └─ 01_metadata   oEmbed: title/author/thumbnail — never fails, works with no auth
  └─ 02_captions   (1) yt-dlp auto-subs  (2) Invidious /api/v1/captions  (3) publisher site
  └─ 03_video      (1) yt-dlp            (2) Invidious API → googlevideo/anchor URLs
                   (3) rate-limited? route through Tor (fresh IP → gates reset)
  └─ 04_slides     speaker repo graphics + ffmpeg scene cuts + timestamped contact sheet
  └─ 05_bundle     pack everything into ONE folder with an INDEX.md manifest
```

Run the whole thing:

```bash
./scripts/run_all.sh https://youtu.be/g_NgCLTibiM out/graph-engineering
```

Each script also runs standalone; see the header of each file.

## What each step does and why

### 01_metadata.sh — oEmbed
`https://www.youtube.com/oembed?url=…` gives title, author, channel, thumbnail — **even when
watch pages are bot-walled**. This is the first probe of the loop; it also proves connectivity.

### 02_captions.sh — three-rung ladder
1. **yt-dlp** with `--write-auto-subs --sub-langs "en.*"`.
2. **Invidious**: `GET {instance}/api/v1/captions/{id}` returns VTT. Instance list is fetched
   from `api.invidious.io/instances.json`; the first instance whose `/api/v1/videos` answers
   wins (only captions/services matter here, media can rate-limit independently).
3. **Publisher's own transcript**: AI Engineer, AWS Developer channels etc. publish the full
   talk text under `ai.engineer/talks/{id}-slug`. A `publisher_transcripts/` regex table
   maps video → transcript URL. Edit it when the video's channel has a known site.

### 03_video.sh — dd ladder + Tor escape
1. **yt-dlp** — the 90% case. Fails hard against IP-flagged YouTube with
   `Sign in to confirm you're not a bot`. Every player_client (android/ios/tv/mweb/web_music)
   was still blocked from a flagged IP.
2. **Invidious API round-trip** (worked here):
   - `GET {api instance}/api/v1/videos/{id}` → adaptiveFormats with googlevideo URLs
     IP-locked to the *instance*, not you.
   - If the instance gates media: solve its browser CAPTCHA
     (**cap.js** proof-of-work: FNV-1a-seeded xorshift challenges; see `scripts/cap_solver.py`)
     then reuse the `captcha_verified` cookie; if still 403 (companion serves only real
     browsers), **do the whole flow in one headful-chromium-under-Xvfb session with proxy**:
     click the `cap-widget` shadow-DOM button, wait for `captcha_verified`, fetch the DASH
     manifest page token (`check=`), then plain `curl` the `/companion/videoplayback` BaseURLs.
3. **Tor escape when everything 403s/rate-limits**: install `tor`, point every call at
   `--socks5-hostname 127.0.0.1:9050`, and re-run step 2. A fresh exit IP resets the bot
   gates. Viable for content-sized transfers (a 130 MB talk) unless the instance also lists
   Tor exits.
4. **Mux**: video-only `itag 299` + `itag 140` audio → `ffmpeg -c copy -map 0:v -map 1:a`.

Useful invariants worth writing down (learned the hard way here):

- googlevideo URLs are IP-locked to whoever asked for them (the instance), not to you.
- An Invidious instance's `/api/…` can work while its `/videoplayback`/`/latest_version` is
  companion-gated (new Invidious+companion split).
- The companion uses a per-page `check=` HMAC token that is session/IP-bound.
- Rate-limit storms look like **hanging requests, not 403s** — detect and back off or rotate IP.
- Real browser + real Tor exit beats every bot wall tried; a headless playwright got blocked by
  the instrumentation fingerprint (`cap.js` standalone "blocks headless browsers" is on by
  default).

### 04_slides.sh — graphics from two angles
**A. The speaker's artifacts** — conference talks ship code. Before frame-grabbing, find the
repo: `gh api` search the speaker/affiliation slug; look for `img/` and `*.png` in demos. The
Neo4j case gave the compiled-skill graphs, inspector screenshots and Browser graphs, all
uncompressed.

**B. ffmpeg scene-detect frame grabs from the video** (when the deck is only in the video):
```bash
ffmpeg -vn -loglevel info -i talk.mp4 \
  -vf "select='gt(scene,0.10)',showinfo" \
  -vsync vfr -fps_mode passthrough -f null - 2> scenes.log
grep -oE "n: *[0-9]+ .*pts_time:[0-9.]+" scenes.log | head   # timestamp index
```
Threshold ladder 0.18 → 0.10 → 0.055 with `-ss/-to` windows between chapter marks; then a
`tile=` contact sheet for visual dedupe. Name kept frames by offset
(`NN_talk_at_XXmYYs.jpg`) — the filename *is* the referrer an agent needs.

### 05_bundle.sh — the agent pack
One folder, zero network once built:

```
<pack>/
  INDEX.md                    ← manifest + suggested entry points per task
  TRANSCRIPT.md               ← polished transcript (from captions or publisher site)
  video/talk.mp4
  slide-captions/TRANSCRIPT-captions-en.vtt
  slide-captions/NN_talk_at_*.jpg
  docs/                       ← artifacts the speaker published; see 04_slides A
  paper/                      ← the paper the talk cites, if known
```

The point of `INDEX.md`: the agent's first file. It names the per-task reading order:
understand-fast → TRANSCRIPT.md; exact words at a moment → grep the VTT by timestamp; every
slide → GRAPHICS-INDEX → slide-captions/NN_*.jpg; reproduce demo → docs/.
Real-world reference: the baked example this repo was extracted from lives at
`/tmp/opencode/slides-graph-engineering/` (INDEX.md, INDEX of 15 graphics, video, VTT, 25
repo docs, AIP paper PDF).

## Layout

```
scripts/           run_all.sh, 01..05, cap_solver.py, probe_instance.sh
publisher_transcripts.tsv   table of known channels → transcript template URL
example/           the manifest & INDEX.md shape (content stripped out)
```

## Known limits

- Publisher-page transcripts are edited prose, not verbatim ASR; keep the VTT in the pack as
  ground truth and treat the polished file as a study aid.
- Some auto-dubbed talks offer many audio tracks; pick the original (`xtags` absent) unless
  dubbed was requested.
- The cap.js solver is best-effort; the browser path is the robust one.
- Tor doesn't help if the *instance* also blocks Tor (none seen yet).

## License

Code: MIT. Content you fetch belongs to its rights holder; keep packs private or comply with
the channel's terms.
