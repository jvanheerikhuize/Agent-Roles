# AGENTS.md -- Agent-Roles

This is a content library of LLM agent role definitions (system prompts).
Any agent or framework can read this file to understand how to consume the library.

## For agents working IN this repo

- `index.yaml` is the manifest. Every role is listed there with metadata and file paths.
- Roles live under `roles/{category}/{slug}/prompt.md`.
- Never modify `index.yaml` without also updating the corresponding role files.

## For agents CONSUMING this repo as a library

### Discovery

Parse `index.yaml` to discover roles. The file is the single entrypoint -- no directory scanning needed.

### Loading a prompt

1. Read `index.yaml`.
2. Find the role by `id`, `slug`, `category`, or `tags`.
3. Read the file at `files.prompt` (relative to repo root) for the full prompt.
4. Alternatively, read `files.semanticode` for the token-compressed variant (suitable for API system prompts).

### Using the resolver

```bash
./resolve.sh --list                   # List all role IDs
./resolve.sh --id forge               # Print prompt content to stdout
./resolve.sh --category entertainment # List roles in a category
./resolve.sh --tag stateful           # List roles matching a tag
./resolve.sh --base-dir lib/roles     # Use from a client repo via submodule path
```

### Key fields in index.yaml

| Field | Purpose |
|-------|---------|
| `files.prompt` | Relative path to the full canonical prompt |
| `files.semanticode` | Relative path to the compressed variant (may be null) |
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
- Version: v1.0.0 (pinned via git tag)
```
