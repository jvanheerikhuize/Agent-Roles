#!/usr/bin/env python3
"""Compile roles/**/role.md + catalog.yaml into index.yaml and dist/prompts/.

Each role is a single role.md: YAML frontmatter (metadata) + markdown body
(the prompt). This tool validates the frontmatter, writes the paste-ready
prompt body to dist/prompts/<slug>.md, and regenerates index.yaml in the
exact indentation layout that resolve.sh and the scripts/ validators parse.

Usage: python3 tools/build.py [--base-dir <repo-root>]

Requires: Python 3.10+, PyYAML.
"""

import argparse
import sys
import textwrap
from pathlib import Path

import yaml

STATUSES = {"stable", "beta", "deprecated"}
INTERACTIONS = {"conversational", "single-shot", "pipeline"}
TARGETS = {"system-prompt", "subagent", "skill", "plugin", "gpt"}
USAGE_KEYS = {"paste_in", "system_prompt", "auto_init"}
RELATION_KEYS = {"group", "companions", "chain_after", "chain_before", "meta_target"}
GOVERNANCE_REQUIRED = ["risk_tier", "ai_tier", "data_classification", "gdpr_special_category"]
GOVERNANCE_ORDER = GOVERNANCE_REQUIRED + ["eu_ai_act_tier", "minors_involved"]
REQUIRED_FIELDS = [
    "id", "name", "category", "version", "status", "description",
    "tags", "targets", "interaction", "usage", "governance", "provenance",
]
OPTIONAL_FIELDS = ["safety_notes", "relations"]
# Keys whose values are always emitted double-quoted (names/dates/versions that
# YAML could otherwise reinterpret).
QUOTED_KEYS = {"name", "author", "version", "created", "last_updated"}


class BuildError(Exception):
    pass


# ---------------------------------------------------------------------------
# role.md parsing
# ---------------------------------------------------------------------------

def load_role_md(path: Path):
    """Split role.md into (frontmatter dict, body str)."""
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        raise BuildError(f"{path}: missing YAML frontmatter (must start with ---)")
    # Split on the FIRST closing delimiter only — prompt bodies may contain
    # `---` horizontal rules of their own.
    fm, sep, body = text.removeprefix("---\n").partition("\n---\n")
    if not sep:
        raise BuildError(f"{path}: unterminated frontmatter (need a closing --- line)")
    meta = yaml.safe_load(fm + "\n")
    if not isinstance(meta, dict):
        raise BuildError(f"{path}: frontmatter is not a mapping")
    return meta, body.lstrip("\n")


def validate_role(meta: dict, path: Path, slug: str, category: str):
    errors = []
    for field in REQUIRED_FIELDS:
        if field not in meta:
            errors.append(f"missing required field '{field}'")
    unknown = set(meta) - set(REQUIRED_FIELDS) - set(OPTIONAL_FIELDS)
    if unknown:
        errors.append(f"unknown fields: {sorted(unknown)}")
    if meta.get("id") != slug:
        errors.append(f"id '{meta.get('id')}' != directory name '{slug}'")
    if meta.get("category") != category:
        errors.append(f"category '{meta.get('category')}' != parent directory '{category}'")
    if meta.get("status") not in STATUSES:
        errors.append(f"status must be one of {sorted(STATUSES)}")
    if meta.get("interaction") not in INTERACTIONS:
        errors.append(f"interaction must be one of {sorted(INTERACTIONS)}")
    targets = meta.get("targets") or []
    if not isinstance(targets, list) or not targets or not set(targets) <= TARGETS:
        errors.append(f"targets must be a non-empty subset of {sorted(TARGETS)}")
    tags = meta.get("tags")
    if not isinstance(tags, list) or not tags:
        errors.append("tags must be a non-empty list")
    usage = meta.get("usage")
    if not isinstance(usage, dict) or set(usage) != USAGE_KEYS or \
            not all(isinstance(v, bool) for v in usage.values()):
        errors.append(f"usage must be a mapping with boolean keys {sorted(USAGE_KEYS)}")
    gov = meta.get("governance")
    if not isinstance(gov, dict) or not set(GOVERNANCE_REQUIRED) <= set(gov):
        errors.append(f"governance must include {GOVERNANCE_REQUIRED}")
    elif not set(gov) <= set(GOVERNANCE_ORDER):
        errors.append(f"unknown governance keys: {sorted(set(gov) - set(GOVERNANCE_ORDER))}")
    prov = meta.get("provenance")
    if not isinstance(prov, dict) or not {"author", "created", "last_updated"} <= set(prov):
        errors.append("provenance must include author, created, last_updated")
    rel = meta.get("relations")
    if rel is not None and (not isinstance(rel, dict) or not set(rel) <= RELATION_KEYS):
        errors.append(f"relations keys must be a subset of {sorted(RELATION_KEYS)}")
    if errors:
        raise BuildError(f"{path}:\n  " + "\n  ".join(errors))


# ---------------------------------------------------------------------------
# YAML emission (hand-rolled: the layout is a compatibility contract with the
# awk parsers in resolve.sh, scripts/validate-index.sh and scripts/test-roles.sh)
# ---------------------------------------------------------------------------

def scalar(value, key=""):
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "true" if value else "false"
    value = str(value)
    if key in QUOTED_KEYS:
        return '"' + value.replace('"', '\\"') + '"'
    return value


def folded(text: str, indent: int, width: int = 86) -> list[str]:
    """Emit `key: >` content: wrapped lines at the given indent."""
    pad = " " * indent
    lines = []
    for para in text.strip().split("\n"):
        wrapped = textwrap.wrap(para.strip(), width=width - indent) or [""]
        lines.extend(pad + w for w in wrapped)
    return lines


def literal(text: str, indent: int) -> list[str]:
    pad = " " * indent
    return [(pad + line).rstrip() for line in text.strip("\n").split("\n")]


def block_list(items, indent: int) -> list[str]:
    pad = " " * indent
    return [f"{pad}- {item}" for item in items]


def inline_list(items) -> str:
    return "[" + ", ".join(str(i) for i in items) + "]"


def emit_role(meta: dict, slug: str, category: str) -> list[str]:
    out = []
    out.append(f"  - id: {meta['id']}")
    out.append(f"    name: {scalar(meta['name'], 'name')}")
    out.append(f"    slug: {slug}")
    out.append(f"    category: {category}")
    out.append(f"    version: {scalar(meta['version'], 'version')}")
    out.append(f"    status: {meta['status']}")
    out.append("")
    out.append("    files:")
    out.append(f"      prompt: dist/prompts/{slug}.md")
    out.append(f"      source: roles/{category}/{slug}/role.md")
    out.append("")
    out.append("    description: >")
    out.extend(folded(meta["description"], 6))
    out.append("")
    out.append("    tags:")
    out.extend(block_list(meta["tags"], 6))
    out.append("")
    out.append("    targets:")
    out.extend(block_list(meta["targets"], 6))
    out.append(f"    interaction: {meta['interaction']}")
    out.append("")
    out.append("    usage:")
    for key in ("paste_in", "system_prompt", "auto_init"):
        out.append(f"      {key}: {scalar(meta['usage'][key])}")
    if "safety_notes" in meta:
        out.append("")
        out.append("    safety_notes: |")
        out.extend(literal(meta["safety_notes"], 6))
    out.append("")
    out.append("    governance:")
    for key in GOVERNANCE_ORDER:
        if key in meta["governance"]:
            out.append(f"      {key}: {scalar(meta['governance'][key])}")
    out.append("")
    out.append("    provenance:")
    for key in ("author", "created", "last_updated"):
        out.append(f"      {key}: {scalar(meta['provenance'][key], key)}")
    rel = meta.get("relations")
    if rel:
        out.append("")
        out.append("    relations:")
        for key in ("group", "companions", "chain_after", "chain_before", "meta_target"):
            if key in rel:
                value = rel[key]
                if isinstance(value, list):
                    # Inline bracket form: resolve.sh's chain/companion parsers
                    # only understand `key: [a, b]`.
                    out.append(f"      {key}: {inline_list(value)}")
                else:
                    out.append(f"      {key}: {value}")
    return out


def emit_index(catalog: dict, roles: list[dict]) -> str:
    module = catalog["module"]
    categories = catalog["categories"]
    out = [
        "# " + "=" * 77,
        f"# Module Index — {module['name']}",
        "# " + "=" * 77,
        "# GENERATED FILE — do not edit by hand.",
        "# Source of truth: roles/<category>/<slug>/role.md + catalog.yaml.",
        "# Regenerate with: python3 tools/build.py",
        "# " + "=" * 77,
        "",
        "module:",
        f"  name: {module['name']}",
        f"  version: {scalar(module['version'], 'version')}",
        "  description: >",
        *folded(module["description"], 4),
        f"  license: {module['license']}",
        f"  author: {scalar(module['author'], 'author')}",
        f"  repository: {module['repository']}",
        "",
        "roles:",
    ]
    for cat in categories:
        cat_roles = sorted(
            (r for r in roles if r["category"] == cat), key=lambda r: r["slug"]
        )
        if not cat_roles:
            continue
        out.append("")
        out.append("  # " + "-" * 75)
        out.append(f"  # {cat.capitalize()}")
        out.append("  # " + "-" * 75)
        for role in cat_roles:
            out.append("")
            out.extend(emit_role(role["meta"], role["slug"], role["category"]))
    out.append("")
    out.append("workflows:")
    for wf_name, wf in catalog["workflows"].items():
        out.append("")
        out.append(f"  {wf_name}:")
        out.append(f"    name: {scalar(wf['name'], 'name')}")
        out.append("    description: >")
        out.extend(folded(wf["description"], 6))
        for list_key in ("steps", "members"):
            if list_key in wf:
                out.append(f"    {list_key}:")
                out.extend(block_list(wf[list_key], 6))
        if "orchestrator" in wf:
            out.append(f"    orchestrator: {wf['orchestrator']}")
    out.append("")
    return "\n".join(out)


# role.md frontmatter emission (used by tools/migrate.py; kept next to the
# index emitter so both serializations stay in sync).

def emit_frontmatter(meta: dict) -> str:
    out = ["---"]
    for key in ("id", "name", "category", "version", "status"):
        out.append(f"{key}: {scalar(meta[key], key)}")
    out.append("description: >")
    out.extend(folded(meta["description"], 2))
    out.append("tags:")
    out.extend(block_list(meta["tags"], 2))
    out.append("targets:")
    out.extend(block_list(meta["targets"], 2))
    out.append(f"interaction: {meta['interaction']}")
    out.append("usage:")
    for key in ("paste_in", "system_prompt", "auto_init"):
        out.append(f"  {key}: {scalar(meta['usage'][key])}")
    if "safety_notes" in meta:
        out.append("safety_notes: |")
        out.extend(literal(meta["safety_notes"], 2))
    out.append("governance:")
    for key in GOVERNANCE_ORDER:
        if key in meta["governance"]:
            out.append(f"  {key}: {scalar(meta['governance'][key])}")
    out.append("provenance:")
    for key in ("author", "created", "last_updated"):
        out.append(f"  {key}: {scalar(meta['provenance'][key], key)}")
    rel = meta.get("relations")
    if rel:
        out.append("relations:")
        for key in ("group", "companions", "chain_after", "chain_before", "meta_target"):
            if key in rel:
                value = rel[key]
                if isinstance(value, list):
                    out.append(f"  {key}: {inline_list(value)}")
                else:
                    out.append(f"  {key}: {value}")
    out.append("---")
    return "\n".join(out)


# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

def collect_roles(base: Path, categories: list[str]) -> list[dict]:
    roles = []
    for role_md in sorted((base / "roles").glob("*/*/role.md")):
        category = role_md.parent.parent.name
        slug = role_md.parent.name
        if category not in categories:
            raise BuildError(f"{role_md}: category '{category}' not listed in catalog.yaml")
        meta, body = load_role_md(role_md)
        validate_role(meta, role_md, slug, category)
        roles.append({"slug": slug, "category": category, "meta": meta, "body": body})
    # Every roles/<cat>/<slug>/ directory must carry a role.md.
    for role_dir in sorted(p for p in (base / "roles").glob("*/*") if p.is_dir()):
        if not (role_dir / "role.md").is_file():
            raise BuildError(f"{role_dir}: missing role.md")
    ids = [r["meta"]["id"] for r in roles]
    if len(ids) != len(set(ids)):
        raise BuildError("duplicate role ids")
    return roles


def check_references(catalog: dict, roles: list[dict]):
    known = {r["meta"]["id"] for r in roles}
    for role in roles:
        rel = role["meta"].get("relations") or {}
        for key in ("companions", "chain_after", "chain_before"):
            for ref in rel.get(key) or []:
                if ref not in known:
                    raise BuildError(f"{role['slug']}: relations.{key} references unknown role '{ref}'")
    for wf_name, wf in catalog["workflows"].items():
        for ref in (wf.get("steps") or []) + (wf.get("members") or []) + \
                ([wf["orchestrator"]] if "orchestrator" in wf else []):
            if ref not in known:
                raise BuildError(f"workflow {wf_name}: references unknown role '{ref}'")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-dir", default=Path(__file__).resolve().parent.parent,
                        type=Path, help="repository root (default: parent of tools/)")
    args = parser.parse_args()
    base = args.base_dir

    catalog = yaml.safe_load((base / "catalog.yaml").read_text(encoding="utf-8"))
    roles = collect_roles(base, catalog["categories"])
    check_references(catalog, roles)

    prompts_dir = base / "dist" / "prompts"
    prompts_dir.mkdir(parents=True, exist_ok=True)
    expected = {f"{r['slug']}.md" for r in roles}
    for stale in prompts_dir.glob("*.md"):
        if stale.name not in expected:
            stale.unlink()
    for role in roles:
        (prompts_dir / f"{role['slug']}.md").write_text(
            role["body"].rstrip("\n") + "\n", encoding="utf-8")

    (base / "index.yaml").write_text(emit_index(catalog, roles), encoding="utf-8")
    print(f"built {len(roles)} roles -> dist/prompts/ + index.yaml")


if __name__ == "__main__":
    try:
        main()
    except BuildError as e:
        print(f"BUILD FAILED: {e}", file=sys.stderr)
        sys.exit(1)
