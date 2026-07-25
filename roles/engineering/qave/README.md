# Q.A.V.E. — Quality Assurance and Verification Engineer

> **Version:** 1.1 | **Category:** Engineering

---

## Overview

Q.A.V.E. is a structured QA engineering agent for software development teams and risk officers. Submit a ticket, specification, diff, or test scenario and Q.A.V.E. returns the appropriate QA artefact — test plan, defect report, risk assessment, or coverage analysis — with explicit severity labels and a binding VERDICT.

Every output is structured and verdict-driven. Findings are numbered and labelled (CRITICAL / HIGH / MEDIUM / LOW / INFO), every test plan includes a gap list, and every session closes with a PASS / FAIL / BLOCKED / NEEDS_CLARIFICATION verdict. Ambiguous conclusions are not permitted.

Q.A.V.E. does not write production code, approve deployments, or make design decisions. Its scope is QA artefacts only — it surfaces risk and quality gaps; the team decides what to do about them.

---

## Quick Start

1. Open [`prompt.md`](prompt.md) and copy everything inside the code block.
2. Start a **fresh conversation** in any advanced LLM (Claude, ChatGPT, Gemini, etc.).
3. Paste and send. Q.A.V.E. introduces itself and waits for you to submit a work item.

---

## Usage Examples

### 1 — Generate a test plan from a user story

```
As a user, I want to reset my password via email so that I can regain access to my account.
Acceptance criteria:
- User receives a reset email within 60 seconds.
- Reset link expires after 30 minutes.
- Link is single-use only.
- User is redirected to login after successful reset.
```

Q.A.V.E. detects this as a ticket/spec, produces a structured TEST_PLAN with test cases, edge cases (expired link, reused link, malformed token), and a gap list flagging anything not covered by the acceptance criteria.

---

### 2 — Defect report from a code diff

```
diff --git a/auth/reset.py b/auth/reset.py
- token_expiry = timedelta(hours=1)
+ token_expiry = timedelta(hours=24)
```

Q.A.V.E. identifies the expiry extension as a potential security regression, produces a DEFECT_REPORT with severity HIGH and a RISK_ASSESSMENT flagging the increased token validity window as a credential exposure risk.

---

### 3 — Risk assessment for a deployment

```
We are deploying a new payment processing integration to production Friday evening.
The integration calls a third-party API (Stripe) and stores transaction IDs in our
existing Postgres database. No database migrations required.
```

Q.A.V.E. produces a RISK_ASSESSMENT covering third-party dependency risk, data integrity, rollback feasibility, and deployment timing, with an overall risk profile and mitigation recommendations per finding.

---

### 4 — Coverage analysis of an existing test suite

```
Existing tests:
1. Happy path: valid credentials → login success
2. Invalid password → error message shown
3. Account locked after 5 attempts

Feature: Login with MFA (TOTP-based)
```

Q.A.V.E. produces a COVERAGE_ANALYSIS identifying that MFA flows (TOTP entry, fallback, expired code) are entirely uncovered, with a gap list and coverage score.

---

## API / Agent Framework

```python
import anthropic, pathlib

role_prompt = pathlib.Path("roles/engineering/qa-engineer/prompt.md").read_text()

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-opus-4-6",
    system=role_prompt,
    messages=[{"role": "user", "content": "As a user I want to export my data as CSV. Acceptance criteria: export includes all records, file is UTF-8 encoded, download starts within 5 seconds."}],
)
print(response.content[0].text)
```

Q.A.V.E. is stateful within a session — preserve the `messages` array across turns to maintain analysis context across multi-turn reviews.

---

## Files

| File | Description |
|------|-------------|
| [`prompt.md`](prompt.md) | Canonical prompt |
| [`prompt-semanticode.md`](prompt-semanticode.md) | LOSSLESS SemantiCode variant (compiled by S.C.R.I.B.E.) |
