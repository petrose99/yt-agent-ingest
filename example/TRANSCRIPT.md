# Make Your AI Agents Predictable With Graph Engineering — Zachary Blumenfeld, Neo4j

- **Video:** https://www.youtube.com/watch?v=g_NgCLTibiM (AI Engineer channel, published Nov 3, 2026, 20:35)
- **Official talk page + full text:** https://ai.engineer/talks/g_NgCLTibiM-make-your-ai-agents-predictable-graph-engineering
- **Demo code:** https://github.com/zach-blumenfeld/graph-memory-system-one-demo (loan-demo)
- **Graphics in this folder** are the slide/demo graphics underlying the talk, pulled from the speaker's demo repo.

## Chapters

| Time | Chapter |
|---|---|
| 0:00 | Intro: what is graph engineering? |
| 1:42 | Three types of graphs |
| 3:04 | Predictability, governance, portability |
| 4:42 | Neo4j's knowledge layer |
| 6:03 | Context graphs and agent memory |
| 6:53 | Compiling skills into graphs |
| 8:08 | Distilling skills from memory graphs |
| 9:22 | Customer use cases |
| 10:47 | Demo: a loan-approval agent |
| 14:30 | Compiling runs into a graph-shaped skill |
| 18:20 | Observability on graph branches |
| 20:01 | Resources |

---

## Full transcript (talk text, from the official ai.engineer talk page)

### Three graphs answer different questions about an agent [0:12]

Where should the logic for an agent's work live? A framework such as LangGraph can put it in the runtime. Nodes do work, and edges carry state to the next node. The machinery is familiar from state machines and workflow graphs. Blumenfeld uses *graph engineering* to describe a practice that also lets an agent pick up a procedure stored alongside its data.

- **Execution graph.** What runs next? Agents and routers are nodes in the harness that executes the workflow.
- **Context graph.** What happened on a particular run? A decision trace connects the steps an agent took to the records involved in that decision.
- **Procedural graph.** What paths does the task allow? A step can call a script, ask a model for a decision, escalate to a person or validate an output. Many runs can follow the same procedure.

The last two graphs work together. An explicit procedure constrains the choices available to the agent. A trace lets a reviewer inspect which choices it made. Packaging the procedure as a skill also gives it a life outside the original runtime. Another harness that can run the skill can use the same routing logic.

> "Graph engineering is the practice of designing agent work as an explicit graph, so where nodes do work and edges effectively route state between them."

He credits the term's recent visibility to a tweet by Peter Steinberger in the summer of 2026, framing it as a possible successor to prompt engineering and context engineering. The name is new; the mechanisms (state machines, workflow graphs, knowledge graphs) are not.

### A knowledge layer connects decisions to records [4:32]

Neo4j places a knowledge layer between agents and their sources. Those sources can include tables in Databricks, BigQuery or Snowflake as well as a collection of Markdown files. The database stores the connected data. Memory tools around it load and retrieve that data, giving different runtimes a common place to find records and the procedures that use them.

A context graph keeps three kinds of memory together. Conversation history preserves the immediate exchange. Entities extracted from conversations or source records supply longer-term memory (short-term / long-term / reasoning memory). Decision traces capture the steps and tool calls the application recorded. With those links, a reviewer can start at a question, find the run it prompted and follow a step back to the entity it used. → [Neo4j Agent Memory](https://neo4j.com/labs/agent-memory/)

### Compile a written skill, then distill one from past runs [6:32]

What changes when a written skill becomes a graph? Neo4j's workshop research started with a `SKILL.md` file and its scripts, references and assets. The compiler represented decisions and routing points as nodes and translated some prose instructions into deterministic scripts. Where the agent once had to read a paragraph and work out what to do, a step in the graph could now invoke a particular script.

> "Can we take procedural knowledge, whether it be from past decisions or even something like a skill, and compile it down to a graph? When we do that and we force the agent to run that graph, what we see is increases in task reward and performance."

Across tasks in fields including physics, computer science and physical training, the team observed higher overall task reward, including with a smaller model (Sonnet at the time; later Haiku). The team published this at a workshop earlier in 2026 (AIP — see results slide in `aip-paper-results.png`: mean task reward 0.599 → 0.705, pass rate 53.3% → 67.4%, Wilcoxon p = 0.011, on 27 SkillsBench tasks).

The memory graph offered a second starting point. A successful run already contains examples of decisions and tool calls. Distilling a skill from those traces lets each procedural step retain links to the runs and records it came from. If a tool call changes, a reviewer can inspect its origin, compare versions and decide whether to edit the skill. The Neo4j Agent Memory Service (NAMS) is the reference architecture for this approach.

### When the applicable rule depends on linked records [9:31]

- **Asset-management audits.** An audit report may draw on compliance documents and databases that identify the same entity by different names or ticker symbols. Before applying a rule, the agent has to resolve which records refer to the entity under review. A reviewer can then follow the match behind the report.
- **Vehicle eligibility at Uber.** Which rule applies to a car component in a particular area when the relevant data is scattered across microservices. A driver can pass onboarding with a vehicle that dispatch considers ineligible for the local product — approved but receiving no rides. Linking the two services' requirements lets a validation check catch the mismatch. → [Uber's configuration graph](https://neo4j.com/customer-stories/uber/)

### Two successful loan reviews take different paths [11:00]

The loan demo begins with an uploaded business plan and a question about whether to approve a new loan (for "Rose's Bakery"). The plan is a PDF, represented by the orange data in the graph. It connects to past transactions, lending policy and earlier decisions pulled from Databricks. Following those links can uncover a prior loan or an earlier mistake that bears on the application. The agent can explain its answer with a trail back to the records it used.

Run the review twice and each conversation has a decision trace with timestamps and tool calls. The two chains differ in length because one run found a precedent — a sensible reason for paths to diverge. The difficulty is that the trace explains the divergence only after the fact. The written instructions leave the agent free to choose its route on the next application.

> "If you run these over and over again, there's nothing actually enforcing that the agent follows an exact path."

Consider the fork between approving a loan and sending it to a person. An instruction to escalate when uncertain leaves that choice to the agent's estimate of its own confidence. Here the scores were uncalibrated. A reviewer seeing a high score had little basis for estimating how often an automatic decision at that confidence would be right. His proposed fix: route such decisions to a type-safe model (TypeSafe's Jev).

### A runnable loan skill separates hard rules from judgment calls [14:30]

Using the AIP library, the team compiled the successful runs into a graph described in YAML. The skill packages that graph with execution scripts, assets and the source lending policy. The policy gives a reviewer something to check the implementation against. The YAML lets different tools read the same procedure, including the tool that displays its steps as a graph (`aip-inspector-skill.jpg` in this folder).

A small command-line interface lets the agent invoke the whole skill. Which applications still need a decision model? Scripts check the hard policy rules first. Those checks can approve an application, deny it or leave it open. Only the third case calls the decision model, whose task covers a risk-tier choice, whether there is material exposure, and an approve-or-deny outcome.

A later router handles escalation. A case requiring human review goes to a person. On the other branch, the agent writes a report and the procedure runs the report through a check-and-lint loop. Applications can still follow different paths. The command now applies the routing rules, so the agent can concentrate on the work assigned to it at each step.

Workflow:
- **Check hard rules** — scripts apply the lending policy to the application.
- **Automatic approval / automatic denial** — the application meets a rule.
- **Call the decision model** — risk tier, material exposure, approve-or-deny (only when the hard rules leave the case open).
- Then: escalate to human review, or write report → check-and-lint loop.

> "Instead of the agent deciding all the routing steps, it's just done programmatically. We took a lot of that policy and put a lot of it into these execution scripts."

### Compare the routes allowed with the routes actually taken [17:42]

Where did judgment enter a particular loan decision? The skill saves each run and its individual steps in the graph. The inspector shows the run's status, what was approved or denied and which branches it took (`aip-inspector-run-rev2.jpg`, `aip-inspector-history.jpg`). A reviewer can distinguish an outcome settled by policy from one that needed the model. Across runs, the same comparison reveals something a collection of decision letters would miss entirely: a branch that the procedure allows but no recorded application has taken.

Timings (from earlier runs; the live run was still waiting on the network):

| Configuration | Model | Result |
|---|---|---|
| Graph alone (ungoverned agent) | Fable | Correct nearly every time, 2.7 min |
| + AIP compiled procedure | Fable | Runtime roughly halved |
| + AIP procedure | Haiku | Model time and cost cut further |
| Wall-clock average | — | ~2 min, down from ~7.5 min |

The "cost cut by 100%" line is rhetorical shorthand, not a measured figure. Demo runs, one build, one run per prompt — direction, not decimals.

### Resources [20:01]

- **Neo4j Agent Memory:** https://neo4j.com/labs/agent-memory/
- **Distil and download a skill (NAMS skills quickstart):** https://neo4j.com/labs/agent-memory/tutorials/skills-quickstart/
- **Uber's Config Knowledge Graph:** https://neo4j.com/customer-stories/uber/
- **Neo4j AuraDB:** https://neo4j.com/product/auradb/ ($100 free credits)
- **Demo repo:** https://github.com/zach-blumenfeld/graph-memory-system-one-demo/tree/main/loan-demo
- **AIP:** https://github.com/zach-blumenfeld/aip · spec: https://github.com/zach-blumenfeld/aip-spec · paper: https://arxiv.org/abs/2606.04781
- **TypeSafe (Jev):** https://docs.typesafe.ai/
- **Other Neo4j + AI resources:** https://neo4j.com/developer/ai

## Key takeaways

- A context graph preserves the path one run took. Distilling a procedural graph from successful runs gives future agents a reusable skill while keeping each step linked to its history.
- In the loan skill, hard policy rules can approve or deny an application before the decision model runs. Moving that routing into scripts reduced the work the model had to do on each application.
- Storing the allowed routes alongside actual run paths lets a reviewer trace one decision and identify branches that have never been exercised.
- The strategic bet isn't the runtime — it's the stored, portable, versioned artifact (compiled skill + context graph) in a knowledge layer that any harness can run.
