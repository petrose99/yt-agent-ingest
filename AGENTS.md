# AGENTS notes — what changed vs naive "use yt-dlp"

Everything below was learned live while inbounding `g_NgCLTibiM` (a 5-day-old AI Engineer
talk) — the pack proved it all works end-to-end.

## Ordering rules
1. **Metadata always works via oEmbed** and tells you if the video even exists.
2. **Transcripts**: try yt-dlp's captions first (cheapest), then Invidious `/api/v1/captions`,
   then the *publisher's own site* — for conference-workshops the play is the speaker's talk
   page (`ai.engineer/talks/<id>-…`); the rung matters because the polished version is
   cleaner than ASR and includes timestamps and chapter anchors.
3. **Graphics**: the speaker's *demo repository* is better than frame grabs (uncompressed,
   source-of-truth). Frame-grab from the video for anything repo-missing using the
   threshold ladder in 04_slides.
4. **Video**: the biggest risk layer. All four signals of a bad run:
   - 403 from `/videoplayback` *with a valid-looking URL*
   - `Sign in to confirm you're not a bot` from every player_client
   - Invidious instance hangs media *only*
   - `latest_version` 302s to `companion/latest_version` that 403s you

   That's the companion split: new Invidious keeps API open but media delivery goes through a
   companion process, nginx-gated. Remedies in order:
   a. different instance (api.invidious.io list),
   b. one *headful* chromium (Xvfb) click-through — gives `captcha_verified` + `check=` token;
      from then on plain curl works with those + the fresh DASH manifest BaseURLs,
   c. if requests still 403 (they fingerprint curl), retry inside that browser session,
   d. if rate-limited or IP-flagged, install tor (`apt install tor`, `service tor start`),
      add `--socks5-hostname 127.0.0.1:9050` to every call, rerun — fresh exit IP resets the
      bot walls. A 130 MB talk downloaded fine over Tor.

## Kitchen rules
- Always save intermediate JSON (`invvid.json`, cookies, check). Every rerun during a
  broken flow costs friends; resume, don't redo.
- Probe with `Range: bytes=0-1023` before committing to a big download.
- Never `re -L` without reading the redirect: `latest_version` might bounce you to a
  companion host where you need *different* credentials.
- Keep the pack's `INDEX.md` short — the agent reads it first, per task.

## Bundle shape (agent-facing)
See README's `05_bundle` tree. The invariant: filename has the timestamp; index has the map;
VTT has verbatim; publisher text has the polish.
