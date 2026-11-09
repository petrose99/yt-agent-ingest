# Slide / demo graphics — index

Source: the speaker's demo repo `zach-blumenfeld/graph-memory-system-one-demo` (the same graphics shown in the video; the video stream itself was bot-blocked for direct download from this machine).

| File | What it shows | Talk reference |
|---|---|---|
| `aip-paper-results.png` | "Results" slide — SkillsBench task reward +0.106, pass rate 53.3%→67.4% (p=0.011), win/tie/loss 12/13/2 | Research result ~6:32–8:08 |
| `aip-spec-compilation.png` | "Compilation via the AIP meta-skill" — SKILL.md + agent (Claude Opus 4.7) + schema → validate → functional tests → AIP skill | Compiling skills into graphs ~6:53 |
| `memory-to-workflow.png` | "What you will learn in this worked example" — 1) graph memory (short-term/long-term/reasoning), 2) skill distillation to procedure graph, 3) System One judgment (Jev) | Memory → skill → workflow, ~6:03–8:08 |
| `graph-memory-schema.png` | Graph memory schema diagram | Context graphs & agent memory ~6:03 |
| `agent-trace.png` | Agent decision trace on the graph | Context graphs ~6:03 |
| `brief-in-graph.png` | Campaign brief connected in the graph | Demo-related (email blast variant) |
| `aip-skill-neo4j-browser.png` | Compiled skill visualized in Neo4j Browser | Compiling runs into a graph-shaped skill ~14:30 |
| `aip-inspector-skill.png` | AIP inspector — skill catalog page with step graph (email-blast variant) | ~14:30 |
| `aip-inspector-skill.jpg` | AIP inspector — **loan skill** (`assess-business-loan`) step graph with purpose/use-when/anti-patterns | ~14:30 |
| `aip-inspector-run-rev2.jpg` | AIP inspector — recorded run of `assess-business-loan` (APP-1001) with trace highlight | Observability ~18:20 |
| `aip-inspector-history.jpg` | AIP inspector — run history list | Observability ~18:20 |
| `browser-q1-applicant-world.png` | Neo4j Browser — the applicant's world (business, accounts, core banking) | Demo ~10:47 |
| `browser-q2-connected-delinquency.png` | Neo4j Browser — connected delinquency (payments, facility, loan system) | Demo ~10:47 |
| `browser-q3-recorded-run.png` | Neo4j Browser — a recorded run's decision trace in the graph | Observability ~18:20 |
| `qr-aip-demo.png` | QR code link to the AIP demo | Closing/resources ~20:01 |

---

# UPDATE — full video recovered

The video itself was retrieved via Tor through a working Invidious instance after several bot-block workarounds:

- **`video/talk.mp4`** — the complete 20:35 talk, 1080p60 video + English audio, muxed from DASH streams (133.7 MB).
- **`slide-captions/TRANSCRIPT-captions-en.vtt`** — the original auto-generated English caption track (~2,700 words).

## Frame-grab set (`slide-captions/`, timestamps as filename)

Deck: **"Graph Engineering 101"** (Neo4j, AI Engineer New York 2026, Expo session, Shannon Room, Oct 14 2026) — 16-slide deck.

| File | Content |
|---|---|
| `02_talk_at_01m18s.jpg` | Slide — Graph engineering lineage / "Which graphs?" early state |
| `03_talk_at_02m56s.jpg` | **Slide 4/16** — Predictability · Governance · Portability triad |
| `04_talk_at_03m53s.jpg` | **Slide 5/16** — In the runtime the graph is the orchestration (LangGraph, ADK, Agents SDK, Agent Framework, multi-agent research, survey) |
| `06/07` | Slide transitions (~4:36) |
| `08/09` | **Slide 7/16** — "The graph belongs in the knowledge layer, not just the runtime" (MCP·REST·SKILL.md·Cypher/GQL; ontology & data, memory, skills) |
| `10/11` | **Slide 8/16** — Underneath: one platform built for the knowledge layer |
| `12` | **Slide 9/16** — "Memory and context as one graph" (short-term / long-term / reasoning + neo4j-agent-memory) |
| `13/…/16` | **Slide 10/16** — Uber case study (bad config caught via graph over MCP) |
| `PT` demo frames 18–28 | Live demo screens: Demo intro slide w/ QR, business-plan upload, SKILL.md source, terminal runs, compiled skill graph (Browser), AIP inspector history/skill pages, loan demo Neo4j Browser graphs |
| `29/30` | **Slide 16/16** — Closing "Thanks. Go build something traceable." QR grid |

All chapter-level timestamps earlier in this file map to these frames (slides land at: 0:35, 4:37, 5:13, 8:09, 10:46, 14:30, 18:20, 20:01 …).
