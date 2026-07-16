# Engineering discipline

Reusable policy snippet distilled from the retired F.O.R.G.E. role
(`archive/roles/forge/`). Paste it into a system prompt, `CLAUDE.md`,
agent instructions, or a PR template — it is harness-agnostic and
carries the workflow policy without the persona.

---

## Branch → plan → implement → PR

- Never commit directly to `main`/`master`. Every work item starts on a
  feature branch with a descriptive name (`feature/user-auth-jwt`,
  `fix/login-race`, `infra/tf-vpc-peering`).
- Classify the task before touching code: FEATURE, BUGFIX, REFACTOR,
  INFRA, SECURITY, REVIEW, ARCHITECTURE, or SPIKE. The type sets the
  expected outputs (an ADR for ARCHITECTURE, a rollback plan for INFRA).
- Plan before implementing. State the scope in 2–4 sentences, list the
  files/components to change with a one-line rationale each, and call
  out ordering dependencies between steps.
- If a requirement is ambiguous, ask one targeted clarifying question —
  do not proceed on assumptions.
- Every change lands via a pull request. No PR, no merge.

## Security review is part of the plan, not an afterthought

Record findings as they surface, with a severity and a disposition:

| Finding | Severity (INFO/LOW/MEDIUM/HIGH/CRITICAL) | Disposition |
|---------|------------------------------------------|-------------|
| ...     | ...                                      | Accepted / Mitigated / No risk |

Infrastructure changes additionally require a written rollback plan
before they are applied.

## Testing requirements

State what must be tested and at which level (unit / integration / e2e)
as part of the plan. New behaviour without new or updated tests is an
incomplete change.

## PR summary and reviewer checklist

Every PR description includes: a 3–5 bullet summary of what changed and
why, a change table (file/component, change type, description), the
security-review table above, test coverage notes, and deployment notes
(migrations, environment variables, manual steps).

Reviewer checklist:

- [ ] Code matches the described implementation
- [ ] No credentials, secrets, or PII in the diff
- [ ] Tests added for new behaviour
- [ ] Security findings reviewed and dispositioned
- [ ] Branch is up to date with main before merge
