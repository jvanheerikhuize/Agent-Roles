# Versioning

This library follows [Semantic Versioning](https://semver.org/).

## Version source

The `module.version` field in `catalog.yaml` is the source of truth; the build copies it into the generated `index.yaml`.
Every release is tagged in git with a matching `v`-prefixed tag (e.g., `v2.0.0`).

**Current status:** `2.0.0-alpha.1` — the v2 single-source rebuild. Tags `v1.x` preserve the pre-rebuild layout (per-role `prompt.md` + SemantiCode variants) for existing consumers; `v2.0.0` will be tagged when the rebuild stabilises.

## Tag format

```
v{MAJOR}.{MINOR}.{PATCH}
```

## What constitutes each level

| Level | When to bump | Examples |
|-------|-------------|----------|
| **PATCH** | Wording fixes, typo corrections, metadata corrections | Fix a crisis line number, rephrase a prompt section |
| **MINOR** | New roles added, new fields added to index.yaml, non-breaking schema changes | Add a new role, add a new `targets` value |
| **MAJOR** | Breaking changes to index.yaml schema, removal of roles, file path structure changes | Rename `files.prompt` to `files.canonical`, remove a category, move built prompts out of `dist/` |

The v1 → v2 rebuild was a MAJOR bump: `files.semanticode` and `files.variant` were removed, per-role sources moved to `role.md`, and consumable prompts moved to `dist/prompts/`.

## Immutability

Once a tag is pushed, its content never changes.
If a fix is needed, bump the version and create a new tag.

## Pinning

Consumers should pin to a specific tag. Consume the built artifacts (`index.yaml`, `dist/prompts/`) — never the `role.md` sources:

```bash
# Submodule
cd lib/roles && git checkout v2.0.0

# Raw URL
curl https://raw.githubusercontent.com/jvanheerikhuize/Agent-Roles/v2.0.0/index.yaml
curl https://raw.githubusercontent.com/jvanheerikhuize/Agent-Roles/v2.0.0/dist/prompts/cra.md
```
