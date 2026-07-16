<div align="center">

# Agentic Role Definitions

**Ready-to-use AI personas for any LLM.**
Paste into a chat, inject via API, or load as a module.

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Roles](https://img.shields.io/badge/roles-23-brightgreen.svg)](index.yaml)
[![LLM Agnostic](https://img.shields.io/badge/LLM-agnostic-purple.svg)](#using-a-role)
[![validate](https://github.com/jvanheerikhuize/Agent-Roles/actions/workflows/validate.yml/badge.svg)](https://github.com/jvanheerikhuize/Agent-Roles/actions/workflows/validate.yml)

</div>

---

## What is a "role"?

A role is a prompt that transforms a general-purpose AI into a focused, opinionated agent. It defines what the AI knows, how it behaves, what it refuses to do, and how it speaks. Paste one into a fresh chat and the AI immediately becomes that character. No fine-tuning, no plugins, no API keys required.

Each role in this library is:

| | |
|---|---|
| **Self-contained** | One file. Copy, paste, done. |
| **LLM-agnostic** | Works with Claude, ChatGPT, Gemini, or any capable model. |
| **Structured** | Consistent behaviour across sessions, not just vibes. |
| **Single-source** | Authored once in `role.md`; the build compiles the deliverable prompt and the catalog. |

---

## Roles

### 🎮 Entertainment

| Role | What it does |
|------|-------------|
| [**T.A.G.**](dist/prompts/tag.md): Text Adventure Generator | A fully stateful game master for text-based RPGs. Drop in any setting and T.A.G. runs the world: inventory, NPCs, quests, and consequences, all tracked across the session. |
| [**H.E.I.S.T.**](dist/prompts/heist.md): High-stakes Extraction and Infiltration Strategy Tactician | Plan and execute a heist in three phases: recon the target, build your crew, then run the job turn by turn. Every session ends in Clean, Dirty, or Burned. |
| [**D.I.C.E.**](dist/prompts/dice.md): Detective Investigation and Case Engine | A murder mystery game master that generates a fresh, locked case for every session (suspects, motives, clues, red herrings) and plays every NPC. Accuse wisely. |
| [**E.C.H.O.**](dist/prompts/echo.md): Experiential Collaborative Hub Orchestrator | A hub-and-spoke multi-player game system. The GM prompt runs the world and generates private player prompts for each participant. Supports 14 game types (whodunnit, heist, quest, and more) with asymmetric knowledge, Dutch output, and Infocom-style narration. |
| [**M.U.S.E.**](dist/prompts/muse.md): Master of Unbounded Studio Exploration | An artist's companion that generates inspiration, challenges comfort zones, and translates any creative impulse into a concrete creation plan, regardless of medium or technique. Treats every failure as creative data. |

### 🛠️ Engineering

| Role | What it does |
|------|-------------|
| [**C.R.A.**](dist/prompts/cra.md): Code Review Analyst | Paste a diff and get a structured, scored review covering security (OWASP, CWE), correctness, performance, and maintainability. Issues a clear verdict: merge or not. |
| [**Q.A.V.E.**](dist/prompts/qave.md): Quality Assurance and Verification Engineer | Submit a ticket, spec, diff, or test scenario and receive the right QA artefact (test plan, defect report, risk assessment, or coverage analysis) with severity labels and a binding verdict. |
| [**S.E.N.T.R.Y.**](dist/prompts/sentry.md): Security Evaluation & Network Threat Response Yield | Adversarial security auditor for the RSI audit pipeline. Thinks like an attacker — traces untrusted input through code, hunts injection vectors, broken auth, leaked credentials, and dependency risks that SAST tools miss. Returns structured JSON findings. |
| [**P.R.O.B.E.**](dist/prompts/probe.md): Precision Review Of Bugs & Edge-cases | Analytical code quality auditor for the RSI audit pipeline. Traces logic paths to find bugs, race conditions, error handling gaps, cross-file interaction failures, and resource management issues. Returns structured JSON findings. |
| [**G.U.I.D.E.**](dist/prompts/guide.md): Guided Understanding & Inclusive Documentation Evaluator | Empathetic documentation auditor for the RSI audit pipeline. Evaluates a codebase from a new contributor's perspective — identifying onboarding gaps, stale docs, missing guides, and undocumented configuration. Returns structured JSON findings. |
| [**S.P.A.R.K.**](dist/prompts/spark.md): Strategic Proposals for Advancement & Reimagined Knowledge | Creative innovation analyst for the RSI audit pipeline. Identifies high-value improvements, modernisation opportunities, and developer experience enhancements grounded in web research and current industry trends. Returns structured JSON proposals with effort estimates. |

> Looking for **F.O.R.G.E.**? The persona was retired in v2 — modern coding harnesses run its branch → plan → implement → PR workflow natively. Its policy lives on in [`snippets/engineering-discipline.md`](snippets/engineering-discipline.md); the original prompt is preserved in [`archive/`](archive/README.md).

### 🩺 Health

> **Important:** Health roles are educational and supportive tools, not a substitute for professional care. Before deploying any health role in a product, verify that crisis line numbers are correct for your region and review the safety notes in each role's README.

| Role | What it does |
|------|-------------|
| [**P.S.Y.**](dist/prompts/psy.md): Trauma-Specialised Psychologist | A grounded, safe companion for psychoeducation and emotional stabilisation. Based on the SAMHSA trauma-informed care framework. Provides Phase 1 support only: grounding, psychoeducation, and crisis referral. |
| [**F.R.A.N.K.**](dist/prompts/frank.md): Forthright Relationship Analyst Navigating Knots | A relationship coach grounded in attachment theory, EFT, and Gottman research. Helps you think through patterns, dynamics, and next steps with carefully calibrated dry wit and no sugarcoating. |
| [**V.I.T.A.**](dist/prompts/vita.md): Values-Integrated Transformation Agent | A lifestyle coaching companion covering food, movement, and mental health. Runs structured sessions using Motivational Interviewing and CBT. Each session ends with one concrete micro-habit commitment. |
| [**P.A.P.A.**](dist/prompts/papa.md): Parental Advice and Perspective Agent | A parenting companion for divorced dads co-parenting a teenage son. Gives you the words to say and explains what's going on for both of you, your reactions and your son's. Built around the week-on/week-off Wednesday-switch rhythm. ⚠️ See safety notes |

### 📚 Education

| Role | What it does |
|------|-------------|
| [**A.G.O.R.A.**](dist/prompts/agora.md): Autonomous Guide for Open-minded Reasoning and Asking | A philosophical inquiry companion for curious minds of all ages. Ask it anything (free will, identity, ethics, existence) and it asks back. Socratic, multilingual, and gently absurdist. ⚠️ See safety notes |
| [**M.E.N.T.O.R.**](dist/prompts/mentor.md): Methodical Educational Navigator for Teaching, Outcomes, and Review | A Socratic study coach for secondary school students (Dutch, VWO). Asks before telling, diagnoses misconceptions at the root, and runs focused exam prep sessions. Never gives away answers. |
| [**S.C.O.U.T.**](dist/prompts/scout.md): Strategic Curriculum Overview and Understanding Translator | A curriculum briefing tool for parents. Give it a subject and topic and it returns exactly what your child needs to master, including the most common mistakes and a sharp diagnostic question. Dutch output. |

### ⚡ Productivity

| Role | What it does |
|------|-------------|
| [**A.G.L.**](dist/prompts/agl.md): Authoritative Governance Lead | An EU AI Act classifier. Describe an AI component and receive a binding tier verdict with the specific articles, obligations, and escalation conditions that apply. Terse, professional, non-negotiable. |
| [**P.R.I.M.E.**](dist/prompts/prime.md): Product Requirements and Intent Management Executive | A Product Owner that reviews feature specs and change requests. Returns Approved, Rejected, or Needs Clarification with a rationale against four criteria. Urgency is not a criterion. |
| [**R.S.I.**](dist/prompts/rsi.md): Recursive Self-Improvement Orchestrator | Meta-governance layer for the RSI audit pipeline. Merges and deduplicates findings from S.E.N.T.R.Y., P.R.O.B.E., G.U.I.D.E., and S.P.A.R.K., resolves conflicts, adjusts severity, and produces a single coherent audit report. The final quality gate. |

### 🔧 Utility

| Role | What it does |
|------|-------------|
| [**A.T.L.A.S.**](dist/prompts/atlas.md): ASCII Topographic Layout and Surveying System | Give it coordinates or a location name and it draws a proportionally accurate ASCII map, complete with compass, scale bar, and legend. Supports interior floor plans too. |
| [**S.P.R.A.Y.**](dist/prompts/spray.md): Stencil Processor and Rapid Assembly Yielder | A stencil conversion tool for graffiti artists and makers. Give it a stencil design and it produces a 3D-printable SVG with guaranteed structural integrity — no floating islands, every region bridged, multi-layer colour sets with registration marks. |

---

## Using a role

### ① Paste into a chat — zero setup

1. Open a role's built prompt in [`dist/prompts/`](dist/prompts/) and copy everything inside the code block.
2. Start a **fresh conversation** in Claude, ChatGPT, Gemini, or any advanced LLM.
3. Paste and send. The role introduces itself and takes it from there.

No account. No API key. No configuration.

---

### ② Inject via API

Each built prompt is a plain text file. Load it as a system prompt:

```python
import anthropic, pathlib

system_prompt = pathlib.Path("dist/prompts/heist.md").read_text()

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-opus-4-6",
    system=system_prompt,
    messages=[{"role": "user", "content": "Start a new job."}],
)
```

Works with any API that accepts a system prompt: Anthropic, OpenAI, Google, or your own hosted model.

---

### ③ Use as a module

Add this library as a git submodule and load the full catalog at runtime:

```bash
git submodule add https://github.com/jvanheerikhuize/Agent-Roles.git lib/roles
git submodule update --init
```

`index.yaml` is the single entrypoint. It lists every role with file paths, metadata, tags, and usage flags. No scraping, no discovery logic required.

See [Consuming as a Library](#consuming-as-a-library) for all integration methods, version pinning, and the resolver script.

---

## Single-source layout

Every role is authored once, in `roles/<category>/<slug>/role.md`: YAML frontmatter (metadata, governance, relations) followed by the prompt body. The build tool compiles that single source into the artifacts consumers use:

```bash
python3 tools/build.py   # requires Python 3 + PyYAML
```

- `dist/prompts/<slug>.md` — the deliverable prompt (what you paste or fetch)
- `index.yaml` — the generated catalog, merged with `catalog.yaml` (module metadata and workflows)

Both generated artifacts are committed, so consumers never need to run the build. CI rebuilds on every PR and fails if they are stale. **Edit `role.md`, never `dist/` or `index.yaml` directly.**

---

## Consuming as a Library

This repository is designed to be consumed by other repositories as a submodule or via direct fetch. The `index.yaml` manifest is the single entrypoint -- parse it to discover all roles, metadata, and file paths.

### Git submodule (recommended)

Pin to a version tag for reproducible builds:

```bash
git submodule add https://github.com/jvanheerikhuize/Agent-Roles.git lib/roles
cd lib/roles && git checkout v2.0.0
cd ../.. && git add . && git commit -m "add Agent-Roles v2.0.0"
```

Update to a new version:

```bash
cd lib/roles && git fetch --tags && git checkout v2.1.0
cd ../.. && git add lib/roles && git commit -m "bump roles to v2.1.0"
```

Tags `v1.x` preserve the pre-rebuild layout (per-role `prompt.md` + SemantiCode variants) for existing consumers.

### Raw URL fetch (zero-install)

Fetch `index.yaml` or individual prompts directly. The tag in the URL pins the version:

```bash
# Fetch the manifest
curl -s https://raw.githubusercontent.com/jvanheerikhuize/Agent-Roles/v2.0.0/index.yaml

# Fetch a specific prompt
curl -s https://raw.githubusercontent.com/jvanheerikhuize/Agent-Roles/v2.0.0/dist/prompts/cra.md
```

Replace `v2.0.0` with `main` for the latest (unpinned) version.

### GitHub Release archive

Every tagged release includes downloadable `.tar.gz` and `.zip` archives. Useful for CI/CD pipelines:

```bash
curl -sL https://github.com/jvanheerikhuize/Agent-Roles/archive/refs/tags/v2.0.0.tar.gz | tar xz
```

### Resolver script

A bash-native resolver is included at the repo root. It parses `index.yaml` with zero dependencies beyond standard POSIX tools:

```bash
./resolve.sh --list                   # List all role IDs
./resolve.sh --id cra                 # Print prompt to stdout
./resolve.sh --id tag --path          # Print the prompt's file path
./resolve.sh --category entertainment # List roles in a category
./resolve.sh --tag stateful           # List roles matching a tag
```

From a client repo using a submodule:

```bash
./lib/roles/resolve.sh --id cra
```

### Agent discoverability

See [`AGENTS.md`](AGENTS.md) for instructions that any LLM agent or framework can follow to discover and load roles from this library. If your client repo uses agent instructions, see the recommended snippet in that file.

### Version pinning

All consumption methods pin via git tags. Tags are immutable -- once released, their content never changes. See [`VERSIONING.md`](VERSIONING.md) for the full versioning contract.

---

## Role Composition

Some roles are designed to work together. The `index.yaml` manifest declares these relationships via per-role `relations` fields and a top-level `workflows` section, so that agent frameworks, pipelines, and users can discover them programmatically.

Relationship types:

| Relation | Meaning |
|----------|---------|
| `companions` | Peer roles designed to work together |
| `chain_after` / `chain_before` | Sequential pipeline adjacency |
| `group` | Named group of related roles |
| `meta_target` | Meta-tool scope (`all` or specific IDs) |

Discover workflows and composition via the resolver:

```bash
./resolve.sh --workflows             # List all defined workflow IDs
./resolve.sh --workflow <name>       # Steps or members for a workflow
./resolve.sh --companions <id>       # Companion roles
./resolve.sh --chain <id>            # Full pipeline containing a role
./resolve.sh --group <name>          # All roles in a group
```

See [`AGENTS.md`](AGENTS.md) for the full schema reference.

### RSI Audit Pipeline

The `rsi-audit-pipeline` workflow demonstrates a group-with-orchestrator pattern. Four specialist auditors run in parallel on a repository, then R.S.I. merges their findings:

```
S.E.N.T.R.Y. (security)    ──┐
P.R.O.B.E.  (quality)      ──┤
G.U.I.D.E.  (documentation) ──┼──→ R.S.I. (orchestrator) ──→ Final Report
S.P.A.R.K.  (innovation)   ──┘
```

```bash
./resolve.sh --workflow rsi-audit-pipeline   # List the four member roles
./resolve.sh --group rsi-audit-pipeline      # All roles including orchestrator
./resolve.sh --tag rsi-pipeline              # Same, via tag
```

---

## Repository structure

```
index.yaml              ← Generated catalog: the single consumer entrypoint
catalog.yaml            ← Module metadata + workflows (source, hand-edited)
resolve.sh              ← Bash-native role resolver (zero dependencies)
AGENTS.md               ← LLM-agnostic agent discoverability
VERSIONING.md           ← Semver contract and version pinning
tools/build.py          ← Compiles roles/**/role.md → dist/ + index.yaml
schemas/role.schema.json← JSON Schema for role.md frontmatter
roles/
├── entertainment/      ← T.A.G., H.E.I.S.T., D.I.C.E., E.C.H.O., M.U.S.E.
├── engineering/        ← C.R.A., Q.A.V.E., S.E.N.T.R.Y., P.R.O.B.E., G.U.I.D.E., S.P.A.R.K.
├── health/             ← P.S.Y., F.R.A.N.K., V.I.T.A., P.A.P.A.
├── education/          ← A.G.O.R.A., M.E.N.T.O.R., S.C.O.U.T.
├── productivity/       ← A.G.L., P.R.I.M.E., R.S.I.
└── utility/            ← A.T.L.A.S., S.P.R.A.Y.
dist/prompts/           ← Built prompts (generated — do not edit)
snippets/               ← Harness-agnostic policy snippets
archive/                ← Retired roles and SemantiCode variants (provenance)
config/                 ← Shared config (crisis resources)
scripts/                ← Validation and smoke tests
```

Each role directory contains:

| File | Purpose |
|------|---------|
| `role.md` | Single source: YAML frontmatter (metadata, governance, relations) + prompt body |
| `README.md` | Usage examples, API code, and safety notes |

---

## Contributing

New roles, improvements to existing ones, bug reports, and ideas are all welcome.

1. **Open an issue** to share your concept and get early feedback.
2. **Fork the repo** and add your role as `roles/<category>/<slug>/role.md` (see [`schemas/role.schema.json`](schemas/role.schema.json) for the frontmatter contract).
3. **Run the build** — `python3 tools/build.py` — and commit the regenerated `dist/` and `index.yaml` along with your source.
4. **Submit a pull request** against `main`. CI validates the build, index consistency, and role smoke tests.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full workflow.

---


## License

[MIT](LICENSE). Use these prompts in any project, commercial or otherwise. Attribution appreciated but not required.
