# Versioning

This library follows [Semantic Versioning](https://semver.org/).

## Version source

The `module.version` field in `index.yaml` is the source of truth.
Every release is tagged in git with a matching `v`-prefixed tag (e.g., `v1.0.0`).

## Tag format

```
v{MAJOR}.{MINOR}.{PATCH}
```

## What constitutes each level

| Level | When to bump | Examples |
|-------|-------------|----------|
| **PATCH** | Wording fixes, typo corrections, metadata corrections | Fix a crisis line number, rephrase a prompt section |
| **MINOR** | New roles added, new fields added to index.yaml, non-breaking schema changes | Add a new role, add a `variant` file type |
| **MAJOR** | Breaking changes to index.yaml schema, removal of roles, file path structure changes | Rename `files.prompt` to `files.canonical`, remove a category |

## Immutability

Once a tag is pushed, its content never changes.
If a fix is needed, bump the version and create a new tag.

## Pinning

Consumers should pin to a specific tag:

```bash
# Submodule
cd lib/roles && git checkout v1.0.0

# Raw URL
curl https://raw.githubusercontent.com/jvanheerikhuize/Agent-Roles/v1.0.0/index.yaml
```
