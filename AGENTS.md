# AGENTS.md -- Agent-Roles

This is a content library of LLM agent role definitions (system prompts).
Any agent or framework can read this file to understand how to consume the library.

## For agents working IN this repo

- `index.yaml` is the manifest, but it is **generated** — never edit it by hand.
- Each role's single source is `roles/{category}/{slug}/role.md`: YAML frontmatter (metadata, governance, relations) followed by the prompt body. The frontmatter contract is documented in `schemas/role.schema.json`.
- Module metadata and workflows live in `catalog.yaml` (hand-edited).
- After changing any `role.md` or `catalog.yaml`, run `python3 tools/build.py` (requires PyYAML). It regenerates `dist/prompts/<slug>.md` and `index.yaml`; commit the regenerated artifacts together with the source. CI fails if they are stale.
- Validate with `scripts/validate-index.sh` and `scripts/test-roles.sh`.
- `archive/` holds retired material (F.O.R.G.E., S.C.R.I.B.E., SemantiCode variants) for provenance only — nothing there is built or indexed.

## For agents CONSUMING this repo as a library

### Discovery

Parse `index.yaml` to discover roles. The file is the single entrypoint -- no directory scanning needed.

### Loading a prompt

1. Read `index.yaml`.
2. Find the role by `id`, `slug`, `category`, or `tags`.
3. Read the file at `files.prompt` (relative to repo root) for the deliverable prompt — this points into `dist/prompts/`.
4. `files.source` points to the role's `role.md` source; use it only when you need the raw frontmatter, not for prompting.

### Using the resolver

```bash
./resolve.sh --list                   # List all role IDs
./resolve.sh --id cra                 # Print prompt content to stdout
./resolve.sh --id tag --path          # Print the prompt's file path
./resolve.sh --category entertainment # List roles in a category
./resolve.sh --tag stateful           # List roles matching a tag
./resolve.sh --base-dir lib/roles     # Use from a client repo via submodule path
```

### Key fields in index.yaml

| Field | Purpose |
|-------|---------|
| `files.prompt` | Relative path to the built, deliverable prompt (`dist/prompts/<slug>.md`) |
| `files.source` | Relative path to the role's single source (`role.md`) |
| `targets` | Deployment targets the role is packaged for (`system-prompt` today; `subagent`, `skill`, `plugin`, `gpt` planned) |
| `interaction` | `conversational`, `single-shot`, or `pipeline` |
| `usage.paste_in` | Can be pasted into a chat session |
| `usage.system_prompt` | Can be injected as an API system prompt |
| `usage.auto_init` | Agent initialises itself without user input |
| `status` | `stable`, `beta`, or `deprecated` |
| `governance.risk_tier` | `low`, `medium`, or `high` |

### Role composition

Roles can declare relationships to other roles via the optional `relations` field in `index.yaml`. These are declarative hints for consumers -- this library does not enforce or orchestrate them.

| Relation | Meaning |
|----------|---------|
| `companions` | Peer roles designed to work together (bidirectional by convention) |
| `chain_after` / `chain_before` | Sequential pipeline adjacency (directional) |
| `group` | Named group of related or interchangeable roles |
| `meta_target` | Roles this meta-tool can operate on (`all` or list of IDs) |

The `workflows` section in `index.yaml` defines named multi-role patterns. Sequential workflows have `steps` (order matters); group workflows have `members` (order irrelevant) with an optional `orchestrator`.

#### Composition queries via the resolver

```bash
./resolve.sh --companions <id>       # List companion roles
./resolve.sh --chain <id>            # Full ordered pipeline containing a role
./resolve.sh --group <name>          # All roles in a named group
./resolve.sh --workflows             # List all defined workflow IDs
./resolve.sh --workflow <name>       # Steps or members for a named workflow
```

### Recommended client AGENTS.md snippet

If your repo consumes this library, add the following to your own `AGENTS.md` or equivalent agent instructions file:

```markdown
## External Libraries

### Agent-Roles (LLM Role Library)
- Location: `lib/roles/` (git submodule)
- Manifest: `lib/roles/index.yaml`
- To load a role: parse index.yaml, find the role by id/slug/tags, read the file at `files.prompt` relative to the submodule root.
- List available roles: `./lib/roles/resolve.sh --list`
- Version: v2.0.0 (pinned via git tag)
```
