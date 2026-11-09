# Bundle: "Graph Engineering" talk — complete collection

**Talk:** Make Your AI Agents Predictable With Graph Engineering — Zachary Blumenfeld, Neo4j
**Video:** https://www.youtube.com/watch?v=g_NgCLTibiM (AI Engineer, Nov 3 2026, 20:35)
**Collected:** 2026-11-09

Everything in this folder is self-contained; the agent needs no network access.

```
/video/talk.mp4                                   ← 1080p60 + English audio, full talk (133 MB)
/slide-captions/TRANSCRIPT-captions-en.vtt        ← word-timed caption track, 4,552 lines
/slide-captions/NN_talk_at_HHmMMs.jpg             ← 29 frame grabs of the actual "Graph Engineering 101" deck
                                                    (AI Engineer NYC 2026 Expo session) + demo screens
 (*.png / *.jpg in the bundle root)               ← 15 clean uncompressed graphics from the demo repo:
                                                    compiled-skill graphs, AIP inspector screenshots,
                                                    Neo4j Browser demo graphs
/docs/talk-transcript-ai.engineer.md              ← polished full talk text, chapter-keyed, + resource links
/docs/demo-loan-*.md                              ← loan-approval demo: README, STORY, PLAN, policy, SOP,
                                                    compiled AIP skill (YAML body, rev2), live-run checkpoints,
                                                    Cypher queries
/docs/demo-aip-*.md                               ← sibling demo (launch-email-blast): same set
/docs/demo-loan-AIPSKILL-rev2.md                  ← the actual compiled graph-shaped skill artifact
/docs/demo-aip-SKILL-launch-email-blast.md        ← same for the email-blast skill
/paper/aip-paper-2606.04781.pdf                   ← the AIP paper behind the SkillsBench claims
/TRANSCRIPT.md                                    ← chat-format full transcript + key tables ( ← QUICK START )
/GRAPHICS-INDEX.md                                ← file → talk-moment map for every graphic ( ← MANIFEST )
```

## Suggested entry points

| Task | Read |
|---|---|
| Understand the talk fast | `TRANSCRIPT.md` |
| Every slide/tool graphic | `GRAPHICS-INDEX.md`, then `slide-captions/*.jpg` |
| Exact words at a moment | `slide-captions/TRANSCRIPT-captions-en.vtt` (grep by timestamp) |
| Reproduce the demo | `docs/demo-loan-README.md` → `docs/demo-loan-AIPSKILL-rev2.md` → `docs/demo-loan-STORY.md` |
| Source claims (0.599→0.705 task reward, 53.3%→67.4% pass, p=0.011) | `paper/aip-paper-2606.04781.pdf` + `docs/demo-aip-live-runs.md` |

## Where the wares came from

1. ai.engineer official talk page (full text) — no auth needed
2. Neo4j conversations obviously not part of the YouTube video but included as speaker artifacts from `github.com/zach-blumenfeld/graph-memory-system-one-demo`
3. DASH streams via Tor through a working Invidious instance, muxed with ffmpeg
