#!/usr/bin/env python3
"""One-shot v1 -> v2 migration: index.yaml + prompt.md -> role.md per role.

Reads the v1 index.yaml (single source of role metadata) and each role's
prompt.md, and writes roles/<category>/<slug>/role.md with the metadata as
YAML frontmatter and the prompt body verbatim. Archived roles (scribe,
forge) are skipped; their directories are moved to archive/ separately.

Kept in the repo for provenance only — after the migration lands, role.md
files are the source of truth and this script has nothing left to do.

Usage: python3 tools/migrate.py
"""

import sys
from pathlib import Path

import yaml

sys.path.insert(0, str(Path(__file__).resolve().parent))
from build import emit_frontmatter, validate_role  # noqa: E402

BASE = Path(__file__).resolve().parent.parent

ARCHIVED = {"scribe", "forge"}

INTERACTION = {
    # conversational: multi-turn dialogue with a human
    "tag": "conversational", "heist": "conversational", "dice": "conversational",
    "echo": "conversational", "muse": "conversational",
    "psy": "conversational", "frank": "conversational", "papa": "conversational",
    "vita": "conversational",
    "agora": "conversational", "mentor": "conversational",
    "spray": "conversational",
    # single-shot: one input, one deliverable
    "scout": "single-shot", "cra": "single-shot", "qave": "single-shot",
    "agl": "single-shot", "prime": "single-shot", "atlas": "single-shot",
    # pipeline: runs as a stage in an automated multi-agent pipeline
    "sentry": "pipeline", "probe": "pipeline", "guide": "pipeline",
    "spark": "pipeline", "rsi": "pipeline",
}


def convert(entry: dict) -> dict:
    meta = {}
    for key in ("id", "name", "category", "version", "status", "description"):
        meta[key] = entry[key]
    meta["description"] = str(meta["description"]).strip()
    meta["tags"] = entry["tags"]
    meta["targets"] = ["system-prompt"]
    meta["interaction"] = INTERACTION[entry["id"]]
    meta["usage"] = entry["usage"]
    if entry.get("safety_notes"):
        meta["safety_notes"] = entry["safety_notes"].rstrip("\n")
    meta["governance"] = entry["governance"]
    meta["provenance"] = entry["provenance"]
    relations = dict(entry.get("relations") or {})
    if entry["id"] == "cra":
        # forge is archived; cra no longer chains after it.
        relations.pop("chain_after", None)
    for key in ("companions", "chain_after", "chain_before"):
        if key in relations:
            relations[key] = [r for r in relations[key] if r not in ARCHIVED]
            if not relations[key]:
                del relations[key]
    if relations:
        meta["relations"] = relations
    return meta


def main():
    index = yaml.safe_load((BASE / "index.yaml").read_text(encoding="utf-8"))
    written = 0
    for entry in index["roles"]:
        slug = entry["slug"]
        if slug in ARCHIVED:
            print(f"skip (archived): {slug}")
            continue
        role_dir = BASE / "roles" / entry["category"] / slug
        prompt = (role_dir / "prompt.md").read_text(encoding="utf-8")
        meta = convert(entry)
        validate_role(meta, role_dir / "role.md", slug, entry["category"])
        content = emit_frontmatter(meta) + "\n\n" + prompt.rstrip("\n") + "\n"
        (role_dir / "role.md").write_text(content, encoding="utf-8")
        written += 1
        print(f"wrote {role_dir.relative_to(BASE)}/role.md")
    print(f"\nmigrated {written} roles")


if __name__ == "__main__":
    main()
