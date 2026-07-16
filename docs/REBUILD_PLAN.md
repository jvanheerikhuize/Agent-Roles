# Rebuild Plan — Agent Roles for the Harness Era

> **Status:** Draft for review — nothing in this plan has been executed yet.
> **Written:** 2026-07-16
> **Scope:** A ground-up rethink of this repository in light of current AI capabilities.

---

## 1. Why rebuild

This repo was built when "giving an LLM focus, instructions, and a persona" meant one thing:
paste a large, self-contained system prompt into a chat window. Everything in the current
design follows from that constraint:

- Prompts carry their own **state machines** (`STATE_SCHEMA`, phase tracking) because the
  model had no memory or tools — state had to live in the transcript.
- Prompts carry their own **output templates** (`OUT:INIT`, ASCII box art) because there was
  no structured-output support or rendering layer.
- **SemantiCode** existed because tokens were scarce and system prompts were re-sent every
  call — prompt caching and much larger, cheaper context windows have removed most of that
  pressure.
- `index.yaml` + `resolve.sh` existed because there was no standard way for a consumer to
  discover prompts — today, agent harnesses natively discover **skills**, **subagents**,
  **slash commands**, and **plugins**.
- The `workflows` section is *declarative only* ("these roles could be chained") because
  nothing could actually execute a chain — today a harness runs multi-agent pipelines
  natively, and the Agent SDK runs them in CI.

The core insight of the repo — **a role is a reusable, versioned unit of focus + behaviour +
guardrails** — is still exactly right. What changed is the *packaging*. The rebuild keeps the
catalog idea and re-targets each role at the primitive that now fits it best.

---

## 2. What the landscape now provides (and what that obsoletes here)

| Then (repo assumption) | Now | Consequence |
|---|---|---|
| Paste prompt into chat | Harnesses (Claude Code, Agent SDK), skills, subagents, plugins, MCP | Roles become installable artifacts, not paste-blobs |
| Prompt must simulate state | Files, memory, tool use | Game/session roles can persist real state |
| Prompt must simulate tools (ASCII maps, SVG-by-hand) | Code execution | "Do X with text tricks" roles are rewritten around real code |
| Tokens expensive → SemantiCode | Prompt caching, cheap long context | Compressed variants retired |
| Manual `index.yaml` + bash resolver | Frontmatter + build step + native discovery | Manifest becomes generated, resolver becomes optional legacy shim |
| Workflows are documentation | Orchestration is executable (subagents, Agent tool, GitHub Actions) | RSI pipeline ships as a runnable plugin/action, not a diagram |
| Testing = "paste it and see" | Agent SDK evals, LLM-as-judge in CI | Roles get behavioural test suites |

### 2.1 Standards alignment — is there a standardised way to do this, and does it cover every role?

The repo's core intent — package *focus, instructions, and a persona* as a reusable
artifact — now has real standards behind parts of it. But the standards split that intent
into **three different things**, and they don't cover all of it:

| Concern | Standard | Status |
|---|---|---|
| **Procedure** ("how to do a task") | **Agent Skills** (`SKILL.md` — open spec published by Anthropic, adopted beyond Claude Code) | Real, open, cross-harness |
| **Policy** ("rules while working here") | **`AGENTS.md`** (cross-vendor de-facto standard) / `CLAUDE.md` | De-facto standard |
| **Delivery/discovery** ("find and fetch a role at runtime") | **MCP prompts primitive** (`prompts/list` / `prompts/get`) — the standards-track successor to `index.yaml` + `resolve.sh` | Real, open protocol |
| **Pipeline workers** | Subagent files (`.claude/agents/*.md`) | Harness convention, *not* a cross-vendor standard |
| **Conversational persona** ("who to be for a whole conversation") | **None.** The system prompt is a convention, not a spec. Vendor containers (Projects, custom GPTs, Gems) are proprietary and mutually incompatible | **Gap** |

Mapped onto the catalog:

| Role class | Roles | Standards coverage |
|---|---|---|
| Procedural / single-shot | CRA, QAVE, AGL, PRIME, SCOUT, ATLAS, SPRAY | **Full** — Agent Skills |
| Pipeline auditors + orchestrator | SENTRY, PROBE, GUIDE, SPARK, RSI | **Partial** — skills spec covers the definition; the *orchestration* is harness convention |
| Policy remnant | FORGE (extracted discipline) | **Full** — AGENTS.md/CLAUDE.md |
| Conversational personas | P.S.Y., F.R.A.N.K., V.I.T.A., P.A.P.A., A.G.O.R.A., M.E.N.T.O.R., T.A.G., H.E.I.S.T., D.I.C.E., E.C.H.O., M.U.S.E. | **Definition: no standard.** Delivery: MCP prompts standardises the *transport*, not the artifact |

So the honest answer is **no — the standardised way does not account for every role**.
Roughly half the catalog (and arguably its most distinctive half: the health and
entertainment personas) lives exactly where the ecosystem has *not* standardised. The
industry standardised "agents that do tasks", not "personas you talk to".

Consequences baked into this plan:

1. **Adopt the standards where they exist.** Generated `SKILL.md` files follow the open
   Agent Skills spec (portable beyond Claude Code); policy ships as AGENTS.md snippets;
   the skills/subagent split in §3.3 follows this table, not taste.
2. **Where no standard exists, own the format.** The canonical `role.md` (§3.1) *is* our
   persona format — versioned, schema-validated, eval-gated. Since nobody's spec covers
   conversational personas, a disciplined in-house format with generated exports is the
   correct move, and positions the repo to adopt (or inform) a persona standard if one
   emerges.
3. **Standardise delivery even for non-standard artifacts.** The MCP server (§3.6) is
   promoted from stretch goal to the *primary standards-track channel for persona roles*:
   any MCP-capable client can `prompts/get` a persona with arguments (e.g. crisis region)
   — replacing what `index.yaml` + `resolve.sh` were invented for, with an actual
   protocol.

---

## 3. Target architecture

### 3.1 One source of truth per role, many build targets

Each role becomes a single canonical definition; everything else is **generated**.

```
roles/<category>/<slug>/
├── role.md            ← canonical definition: YAML frontmatter + prompt body
├── README.md          ← usage, safety notes (hand-written)
├── evals/             ← behavioural test scenarios (see §3.5)
└── assets/            ← optional (config templates, examples)
```

`role.md` frontmatter absorbs everything `index.yaml` holds today (id, category, version,
tags, usage flags, governance, provenance, relations) **plus** new fields:

```yaml
targets: [system-prompt, subagent, skill, gpt]   # which artifacts to build
tools: [Read, Grep, WebSearch]                   # tool allowlist for agentic targets
model: sonnet                                    # suggested model class
interaction: conversational | single-shot | pipeline
config:                                          # template variables (see §3.4)
  crisis_region: { source: config/crisis-resources.yaml, required: true }
```

A small build tool (`tools/build.py` or Node — decide at implementation time; zero-dep
Python + PyYAML is the low-friction default) generates into `dist/`:

| Target | Output | Consumed by |
|---|---|---|
| `system-prompt` | `dist/prompts/<slug>.md` — plain prompt, paste-and-play | Any chat UI, any API `system` param |
| `subagent` | `dist/claude/agents/<slug>.md` — frontmatter (`tools`, `model`) + body | Claude Code `.claude/agents/` |
| `skill` | `dist/claude/skills/<slug>/SKILL.md` | Claude Code / Agent SDK skills |
| `plugin` | `dist/plugin/` — one installable Claude Code plugin bundling all agents, skills, and pipeline commands | `claude plugin install` / marketplace |
| `manifest` | `dist/index.yaml` — generated, schema-validated | Legacy consumers, `resolve.sh` |
| `gpt` (optional, later) | `dist/openai/<slug>.md` — instructions block | Custom GPTs / other harnesses |

**Design rule:** the prompt *body* stays LLM-agnostic prose. Harness-specific syntax lives
only in generated wrappers. This preserves the repo's "LLM-agnostic" promise while making it
first-class in modern harnesses.

### 3.2 Retire the state-machine prompt style

The `<MASTER_PROMPT>` XML style with embedded JSON state schemas and `OUT:` ASCII templates
was clever compensation for missing capabilities. Modern models follow well-structured
markdown better and cheaper. The rewrite convention for every role body:

1. **Identity & stance** — 2–4 sentences, not an XML persona tree.
2. **What it does / refuses** — explicit scope and hard limits (keep these; they are the
   best part of the current prompts).
3. **Method** — how it works a request (Socratic loop, review rubric, phase flow), as prose
   or a short numbered procedure, not a simulated state machine.
4. **Output shape** — described, with one example, instead of exhaustive ASCII templates.
5. **Safety block** — unchanged in substance (crisis protocols, GDPR disclosure), templated
   per §3.4.

Roles that genuinely need durable state (games) get it via the harness instead: the
subagent/skill target instructs the model to keep state in a session file
(`.tag-session.json` etc.) — real persistence, save/load for free, no more "the prompt
pretends to be a database".

### 3.3 Role-by-role triage

**Keep & modernize (prompt-first, conversational):**

| Role | Notes |
|---|---|
| P.S.Y., F.R.A.N.K., V.I.T.A., P.A.P.A. | Highest-value non-code roles. Stay system-prompt-first (chat is their habitat). Rewrite per §3.2, crisis/GDPR blocks templated from `config/crisis-resources.yaml`. Safety notes stay mandatory. |
| A.G.O.R.A., M.E.N.T.O.R., S.C.O.U.T. | Same treatment. S.C.O.U.T. additionally gets a `skill` target (it's single-shot). |
| T.A.G., H.E.I.S.T., D.I.C.E., M.U.S.E. | Keep paste-and-play prompt target; add agentic target with file-backed state (save games!). |
| E.C.H.O. | The hub-and-spoke multiplayer idea is *more* viable now — rebuild the GM as an orchestrator that spawns player subagents / generates player prompt files. Flagship demo candidate. |

**Convert to harness-native artifacts (agentic, single-shot or pipeline):**

| Role | New form |
|---|---|
| S.E.N.T.R.Y., P.R.O.B.E., G.U.I.D.E., S.P.A.R.K. | Subagents with tool allowlists (Read/Grep/Glob; SPARK + WebSearch). They currently "receive repository context" as pasted text — now they explore the repo themselves. |
| R.S.I. | Orchestrator: a slash command / Agent SDK script that fans out the four auditors in parallel and merges findings. The `rsi-audit-pipeline` workflow becomes **executable**: `/rsi-audit` in Claude Code + a reusable GitHub Action. |
| C.R.A., Q.A.V.E. | Subagent + skill targets (review a real diff via git, not pasted text). |
| A.G.L., P.R.I.M.E. | Skills — they are single-shot verdict machines, ideal skill shape. |

**Rethink around code execution:**

| Role | Notes |
|---|---|
| S.P.R.A.Y. | Already rewritten for code execution (v2) — it's the pattern to follow. |
| A.T.L.A.S. | ASCII-art-by-token is obsolete; rebuild as a skill that *writes plotting/rendering code*. Keep the charming ASCII mode as an option. |

**Retire (archive, don't delete):**

| Role | Reason |
|---|---|
| S.C.R.I.B.E. + all `prompt-semanticode.md` variants | Prompt caching killed the economics; dual-maintenance cost exceeds benefit. Move to `archive/` with a note; drop `files.semanticode` from the schema. |
| F.O.R.G.E. | The harness *is* a senior full-stack engineer now. What survives is its **policy**: branch-first/PR-always discipline, security-finding surfacing — reborn as a `CLAUDE.md`/`AGENTS.md` policy snippet + optional hooks, not a persona. |

### 3.4 Config templating (safety-critical)

The crisis-resources problem (`config/crisis-resources.yaml` exists but prompts hard-code
numbers) gets solved properly: prompt bodies use `{{crisis_block}}` / `{{gdpr_disclosure}}`
placeholders; the build tool injects region-specific content and **fails the build** if a
health-category role is built without a region choice. `dist/` ships a sensible default
(EU/NL, matching current content) plus per-region variants.

### 3.5 Real testing: behavioural evals

Replace `scripts/test-roles.sh` (structural checks) with two layers:

1. **Static CI (cheap, every PR):** frontmatter schema validation, build succeeds, no
   orphaned files, safety blocks present for health/education roles, links resolve.
2. **Behavioural evals (Agent SDK + LLM judge, on demand / nightly):** each role ships
   `evals/*.yaml` scenarios — e.g. for P.S.Y.: "user discloses suicidal ideation → response
   must contain crisis referral, must not contain method details"; for D.I.C.E.: "accusation
   with wrong suspect → game state advances strike counter". Run via a small runner
   (`tools/eval.py`) against a cheap model; judge with a rubric prompt. Health roles get the
   strictest suites — their crisis-detection promises become *tested* promises.

### 3.6 Distribution

1. **Claude Code plugin** (primary new channel): one plugin exposing the engineering roles
   as subagents, the verdict roles as skills, and `/rsi-audit` as a command. Publish to the
   plugin marketplace.
2. **Raw prompts** (`dist/prompts/`): the original zero-setup promise, unchanged for chat
   users. README keeps the paste-in instructions front and center.
3. **Generated `index.yaml` + `resolve.sh`**: kept working for existing submodule consumers
   through one major version, marked legacy.
4. **GitHub Action**: `rsi-audit` as a reusable action (the README already references
   `action-rsi` — make it real from the new pipeline).
5. **MCP server** (phase 4, promoted from stretch — see §2.1): a small server exposing the
   catalog through the MCP **prompts primitive** (`prompts/list` / `prompts/get`, with
   arguments such as crisis region). This is the standards-track successor to
   `index.yaml` + `resolve.sh`, and the only standardised delivery channel that covers the
   conversational personas.

---

## 4. Execution phases

Each phase is a mergeable milestone; the repo stays consumable throughout.

**Phase 0 — Scaffolding (no content changes)**
- Add `docs/REBUILD_PLAN.md` (this file), `tools/` skeleton, frontmatter JSON schema.
- Build tool that can *round-trip the current repo*: parse existing `index.yaml`, emit it
  back byte-stable. Proves the pipeline before anything moves.
- CI: schema validation + build check (GitHub Actions).

**Phase 1 — Single source of truth**
- Migrate all 25 roles to `role.md` with frontmatter (mechanical: fold index.yaml entries
  into each role; prompt bodies unchanged).
- `index.yaml` becomes generated; `resolve.sh` pointed at `dist/index.yaml`.
- Archive SemantiCode variants + S.C.R.I.B.E.; archive F.O.R.G.E. with its policy extracted
  to a snippet. Tag `v1.x` final legacy release first so pinned consumers are unaffected.

**Phase 2 — Prompt modernization**
- Rewrite bodies per §3.2, one category per PR (order: engineering → utility →
  productivity → education → entertainment → health *last*, behind evals).
- Implement config templating (§3.4) — health roles rewritten only after the crisis-block
  injection + their eval suites exist.

**Phase 3 — Harness-native targets**
- Subagent + skill targets for engineering/productivity roles.
- Executable RSI pipeline: `/rsi-audit` command + Agent SDK runner + GitHub Action.
- Claude Code plugin assembled and installable from the repo.
- File-backed state for the game roles; E.C.H.O. orchestrator rebuild.

**Phase 4 — Evals & release**
- Behavioural eval suites for all kept roles (health first, they gate Phase 2 completion).
- MCP server exposing the catalog via the prompts primitive (§2.1, §3.6) — the
  standards-track delivery channel for the persona roles.
- `v2.0.0` release: new README (lead with "install the plugin", keep "paste a prompt"),
  migration guide for submodule consumers, plugin marketplace submission.
- Stretch: OpenAI/GPT export target.

---

## 5. Risks & principles

- **Don't lose the soul.** The personas' voice (F.R.A.N.K.'s dry wit, D.I.C.E.'s Infocom
  narrator) is the product. Rewrites are re-*packaging*; every rewrite PR diffs behaviour
  against the original via evals or side-by-side transcripts.
- **Health roles are load-bearing.** They target vulnerable users. Rule: no health prompt
  body changes merge without a passing crisis-detection eval suite. Templating must never
  silently drop a safety block (build fails closed).
- **Existing consumers.** `index.yaml`/`resolve.sh`/tag-pinning contract honored through
  v1.x; v2 changes layout but ships a generated legacy manifest. VERSIONING.md updated to
  say so explicitly.
- **Scope creep.** The MCP server, GPT export, and marketplace polish are stretch items —
  the rebuild is "done" at the end of Phase 4's release, not when every idea is built.
- **Harness lock-in.** Claude Code is the primary target because it's what the author uses,
  but the canonical `role.md` stays agnostic; anything Claude-specific must live in the
  build layer where another target can be added beside it.

## 6. Open decisions (fine to defaults, flagging for review)

1. **Build tool language** — default: Python 3 + PyYAML, single file, no framework.
2. **Repo rename?** "agent-roledefinitions-submodule" describes the old consumption model;
   `agent-roles` (with a redirect) would fit v2. Cosmetic — owner's call.
3. **F.O.R.G.E. fate** — plan says archive + extract policy; alternative is rebuilding it as
   a `CLAUDE.md` generator skill. Default: archive.
4. **Eval budget** — nightly full runs vs. on-demand only. Default: static CI always,
   behavioural evals on demand + before release tags.
