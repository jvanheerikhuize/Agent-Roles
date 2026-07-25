# Roadmap

Why the library exists is in [PURPOSE.md](PURPOSE.md). The full v2 target
architecture is in [docs/REBUILD_PLAN.md](docs/REBUILD_PLAN.md). This file
tracks the order work happens in, and why.

Status as of 2026-07-25: **25 roles across 6 categories, indexed by a
1378-line hand-maintained `index.yaml`.** The rebuild plan is merged but not
started. The library works; what it lacks is anything that keeps it
consistent with itself.

## The problem this sequence solves

Role metadata is stored in three places per role — `index.yaml`, the
`> **Version:**` line in `prompt.md`, and the same line in `README.md`.
Nothing enforces agreement, and **12 of 25 roles currently disagree about
their own version**:

| Roles | index.yaml | prompt.md | README.md |
|---|---|---|---|
| heist, dice, cra, forge, qave, psy, frank, agora, scribe, agl, prime | 1.0 | 1.1 | 1.0 |
| spray | 1.0 | 2.0 | 2.0 |

`spray` is the instructive case: it was correctly bumped to 2.0 in two files
and the index was never updated, so `resolve.sh --id spray` — the repo's own
consumer API — reports a version that no longer exists.

Two reasons nothing caught this:

1. There is no `.github/workflows/`. `scripts/validate-index.sh` and
   `scripts/test-roles.sh` are good scripts that nothing runs.
2. Every check they make is *existence*-shaped ("this referenced file
   exists"), never *agreement*-shaped ("these files say the same thing").
   The one bug the current layout guarantees is the one class not tested.

## Phase 1 — Make the library defend itself

Cheapest work in the repo, and a prerequisite for trusting every migration
PR below it.

1. **CI.** A workflow running `validate-index.sh` and `test-roles.sh` on
   every PR. No new design decisions required.
2. **A metadata-agreement check.** New check in `validate-index.sh`:
   `index.yaml`, `prompt.md`, and `README.md` must agree on version and
   category for every role. It fails on `main` today — that is the point.
3. **Reconcile the 12 mismatches.** Hand-fix; CI stays red until done.
4. **Fix the module identity.** `index.yaml` declared
   `name: agent-roledefinitions-submodule` and a repository URL of the same
   name; the repo is `Agent-Roles`. The stale URLs still resolve today only
   because GitHub's rename redirect is holding — that redirect dies the moment
   anyone else claims the old name. Renamed across `index.yaml`, `README.md`,
   `AGENTS.md`, `VERSIONING.md` and `resolve.sh`. Resolves open decision #2 in
   the rebuild plan.

## Phase 2 — One source of truth

The payoff: drift becomes structurally impossible rather than merely fixed.

- Migrate all 25 roles to `role.md` with YAML frontmatter, per
  [REBUILD_PLAN §3.1](docs/REBUILD_PLAN.md) — mechanical, prompt bodies
  unchanged.
- `index.yaml` becomes **generated**; `resolve.sh` is pointed at the
  generated manifest so existing submodule consumers keep working.
- **Generate the `README.md` header block too.** This diverges from
  REBUILD_PLAN §3.1, which keeps `README.md` hand-written: the README is a
  participant in all 12 drift cases above, so leaving it hand-written
  migrates the drift instead of ending it. Generate the metadata header,
  hand-write the prose below it.
- **Port `scaffold.py` from the `asdlc` repo** rather than writing
  `tools/build.py` from scratch (REBUILD_PLAN §6, decision 1). That repo
  already runs typed-nodes → manifests → rendered markdown with a `--check`
  drift gate in CI. It is proven and the conventions transfer.
- **Two build targets, not six.** `system-prompt` (the existing paste-and-play
  promise) and `manifest` (keeps `resolve.sh` alive). REBUILD_PLAN §3.1 and
  §3.6 specify six plus an MCP server; §5 warns about scope creep. Add
  targets when a real consumer asks for one.
- **Retire the 19 `prompt-semanticode.md` files.** Hand-maintained derived
  artifacts at 19/25 coverage, compressing tokens that prompt caching made
  cheap. Archive, don't delete (REBUILD_PLAN §3.3).
- **Unwrap the prompts.** `prompt.md` wraps the real payload in a ```` ```text ````
  fence inside human-facing docs, so a consumer must parse markdown to
  extract a prompt — contradicting PURPOSE.md's "self-contained, copy-paste
  ready" constraint. Generated prompts must be byte-for-byte what you paste.

Ship `v2.0.0` here. Tag `v1.x` final first so pinned consumers are unaffected.

## Phase 3+ — Elective

Everything in REBUILD_PLAN §3.2, §3.3, §3.5 and §3.6 is real work with real
value, but none of it fixes something that is broken today. Sequenced behind
the release, in rough value order:

- **Prompt-body modernization** (§3.2) — retire the state-machine XML style,
  one category per PR, health roles last and behind evals.
- **Behavioural evals** (§3.5) — health roles first; their crisis-detection
  promises become tested promises.
- **Config templating** (§3.4) — `{{crisis_block}}` injected from
  `config/crisis-resources.yaml`, build fails closed. Gates health-role
  rewrites.
- **Harness-native targets** (§3.3) — subagents and skills for the
  engineering and productivity roles.
- **Distribution** (§3.6) — Claude Code plugin, executable `/rsi-audit`, MCP
  server.

## Known risks

- **Don't lose the voice.** The personas' character is the product; rewrites
  are repackaging. Carried over from REBUILD_PLAN §5.
- **Health roles are load-bearing.** They target vulnerable users. No health
  prompt-body change merges without a passing crisis-detection eval.
- **Existing consumers.** The `index.yaml` + `resolve.sh` + tag-pinning
  contract is honoured through v1.x and by a generated manifest in v2.
- **Phase 2 is where the estimate is soft.** Migrating 25 roles is
  mechanical but touches every file in the repo; Phase 1 exists partly so
  that migration lands against a green, enforcing CI.
