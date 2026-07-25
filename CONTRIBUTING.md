# Contributing to Agentic Role Definitions

First off -- thank you for considering a contribution. This library grows through the ideas and effort of people like you, and every role added makes it more useful for everyone.

There are several ways to contribute, from fixing a typo to proposing an entirely new role persona. All are welcome.

---

## Ways to contribute

### Add a new role

Have an idea for an AI persona that belongs in this library? Open an issue to share your concept and get early feedback, then follow the steps below to build it out.

### Improve an existing role

Found a behaviour that feels off? A scenario the prompt doesn't handle well? A better way to phrase something? Open a pull request with your change and explain what it fixes and why.

Edit the role's `role.md` (the single source), then run `python3 tools/build.py` and commit the regenerated `dist/` and `index.yaml` along with your change. Never edit `dist/` or `index.yaml` by hand — CI rejects stale or hand-edited artifacts.

### Report a bug

Open a [GitHub Issue](../../issues) and describe:
- Which role and which LLM you were using
- What you expected the role to do
- What it actually did
- The input that triggered it (if reproducible)

### Improve documentation

Spotted something unclear, outdated, or missing? Documentation PRs are just as valuable as prompt improvements -- submit one.

---

## Adding a new role

**Step 1 -- Open an issue first**

Share your concept before building. Include:
- What the role does and who it's for
- The category it belongs to (`entertainment`, `engineering`, `health`, `education`, `utility`, or `productivity`)
- The persona -- tone, humor, voice
- Any special constraints (sensitive topics, language requirements, scope limits)

Early feedback saves rework later.

**Step 2 -- Fork and build**

Fork the repo and create your role under `roles/<category>/<slug>/`. Each role directory contains:
- `role.md` -- YAML frontmatter (metadata, governance, relations) followed by the full prompt body. See [`schemas/role.schema.json`](schemas/role.schema.json) for the frontmatter contract, or copy an existing role's frontmatter as a starting point.
- `README.md` -- usage examples, API code, and safety notes

Then run the build and commit the generated artifacts:

```bash
python3 tools/build.py        # regenerates dist/prompts/<slug>.md and index.yaml
scripts/validate-index.sh     # index ↔ disk consistency
scripts/test-roles.sh         # structural smoke tests
```

There is no manual `index.yaml` step — the build generates your role's entry from the frontmatter.

**Step 3 -- Open a pull request**

Submit your PR against `main`. Fill in the template with:
- A summary of the role
- The concept and target user
- Any design decisions that aren't obvious from the prompt itself

CI runs the build and both validation scripts; it fails if `dist/` or `index.yaml` is out of date.

---

## Pull request guidelines

- **One concern per PR** -- a new role, a prompt fix, or a docs update. Not all three at once.
- **Test your prompt** -- paste it into at least one LLM and verify it behaves as intended before submitting.
- **Commit source and artifacts together** -- every `role.md` change ships with the regenerated `dist/` and `index.yaml` in the same PR.
- **Health and sensitive roles** -- if your role touches mental health, crisis risk, minors, or GDPR Art. 9 data, follow the safety notes pattern in existing health roles.
- **Run `scripts/validate-index.sh`** before submitting. Fix any reported mismatches.

---

## Role quality standards

Every contributed role should meet the following bar before merge.

### Structural requirements

- **Self-contained.** The prompt works when pasted into a fresh chat session with no prior context and no external tooling.
- **LLM-agnostic.** Tested against at least two of: Claude, ChatGPT, Gemini. Note any model-specific behavior in the role README.
- **Deterministic lifecycle.** The prompt defines explicit phases or states (OPEN → ... → CLOSE) rather than relying on the model to improvise structure.
- **Token efficient.** Prompts should justify their length. Aim for < 6k tokens; cut anything that does not change observable behavior.
- **Valid frontmatter.** The build fails on missing or invalid metadata — `tags`, `governance`, `provenance`, `targets`, and `interaction` must all be accurate.

### Cross-LLM compatibility

- Avoid provider-specific features (Claude XML tags, OpenAI tool schemas) in the canonical prompt. Use plain Markdown and natural-language directives.
- If behavior diverges across models, document the divergence in the role README under a "Known model differences" section.

### Safety review checklist (health, education, minors, GDPR Art. 9)

Required for any role tagged `health`, any role with `minors_involved: true`, or any role where `gdpr_special_category` is `true` or `conditional`.

- [ ] **Crisis detection protocol** defined, or an explicit note that none is included and why (see P.A.P.A. for an acceptable no-detection rationale).
- [ ] **Safe-messaging compliance** — prompt does not enable means, does not romanticize, surfaces resources when user is in distress. See WHO / Samaritans safe-messaging guidelines.
- [ ] **Regional crisis resources** referenced via `config/crisis-resources.yaml`, not hardcoded. Deployer-facing safety note explains the splice.
- [ ] **GDPR Art. 9 disclosure** shown at session open when special-category data is foreseeable.
- [ ] **Scope limits** stated — what the role is NOT (e.g., "not a substitute for licensed care", "single-user perspective only").
- [ ] **Age-appropriateness** — if minors may interact with the role, explicit language and topic guardrails.
- [ ] **`safety_notes` block** present in the role's frontmatter, listing items the deployer must verify.

### Governance metadata

Set honestly based on the role's worst-case session, not the typical case:

- `risk_tier` — `low` / `medium` / `high`
- `ai_tier` (EU AI Act) — `minimal` / `limited` / `high` / `prohibited`
- `data_classification` — `public` / `internal` / `confidential` / `restricted`
- `gdpr_special_category` — `true` / `false` / `conditional` (with comment explaining the condition)

Unsure? Run the spec through the `A.G.L.` role in this library for a tier classification.

---

## Code of conduct

Be respectful and constructive. Critique the work, not the person. This is a collaborative project and everyone is here to build something useful.

---

## Questions?

Open a [GitHub Discussion](../../discussions) or an [Issue](../../issues). Happy to help.
