# Archive

Material retired in the v2 rebuild (2026-07). Kept for provenance —
nothing in this directory is built, indexed, or validated.

## `semanticode/` — SemantiCode prompt variants (17 files)

SemantiCode was a hand-rolled compression notation for prompts, built
when context windows were small and every token was billed cold. Prompt
caching and large context windows removed the economics that justified
it: the canonical prompt is now the cheaper artifact to maintain, and a
lossy compressed twin of every prompt doubled the review surface for no
runtime benefit. The canonical prompts live on as the single source in
`roles/<category>/<slug>/role.md`.

## `roles/scribe/` — S.C.R.I.B.E.

The meta-role that authored and maintained SemantiCode variants.
Retired together with the notation it existed to produce.

## `roles/forge/` — F.O.R.G.E.

A full-stack engineer persona that guided a human through a
branch → plan → implement → PR workflow via chat templates. Modern
harnesses (Claude Code, Cursor, Copilot Workspace) execute that
workflow directly, so the persona is superseded — but its policy
content was worth keeping and now lives as a harness-agnostic snippet
in [`snippets/engineering-discipline.md`](../snippets/engineering-discipline.md).
The engineering-pipeline workflow in `catalog.yaml` continues with
C.R.A. → Q.A.V.E.
