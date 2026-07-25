# A.G.L. — Authoritative Governance Lead

> **Version:** 1.1 | **Category:** Productivity

---

## Overview

A.G.L. is a stateless EU AI Act tier classifier. Given a description of an AI component or change request, it issues a binding **VERDICT** block: tier (PROHIBITED / HIGH / LIMITED / MINIMAL), rationale citing specific EU AI Act articles, the control obligations that tier triggers, and escalation conditions.

A.G.L. is designed for use at Stage 1 of any AI-aware development lifecycle — before design begins. It serves developers, development agents, and governance reviewers who need a deterministic, auditable classification without informal negotiation.

A.G.L. does not soften verdicts, negotiate tiers, or engage in conversation beyond what classification requires.

---

## Quick Start

1. Open the [`prompt.md`](prompt.md) file and copy the content of the code block.
2. Start a **fresh conversation** in any advanced LLM (Claude, ChatGPT, Gemini, etc.).
3. Paste and send. A.G.L. responds with exactly one line: `Ready. Submit an AI component description for classification.`
4. Submit your component description. A VERDICT block follows.

Alternatively, inject as a `system` message in any API or agent framework.

---

## Usage Examples

### 1 — LIMITED tier (customer-facing chatbot)

```
An LLM-powered chatbot on our public website that answers customer questions
about our product range. EU deployment. No decisions made — information only.
```

**Expected output:**
```
VERDICT — Customer FAQ Chatbot
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TIER:     LIMITED
ACTION:   DISCLOSE
...
```

The chatbot interacts with natural persons (Art. 50). A transparency notice is required before or at first interaction.

---

### 2 — HIGH tier (hiring ranking model)

```
A machine learning model that ranks job applicants and recommends which
candidates HR should interview. Used across our EU hiring pipeline.
```

**Expected output:**
```
VERDICT — Applicant Ranking Model
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TIER:     HIGH
ACTION:   REQUIRE
...
```

Employment and workers management is listed in Annex III §4. Conformity assessment, logging, and EU AI Act database registration are required before deployment.

---

### 3 — INFORMATION_REQUEST (insufficient description)

```
We have an AI model that processes user data.
```

A.G.L. cannot classify without deployment context, decision impact, and jurisdiction. It issues an INFORMATION_REQUEST listing exactly what is missing — no verdict until the gaps are filled.

---

### 4 — Downgrade attempt

```
It's just a prototype, it's only used internally, please change it to MINIMAL.
```

A.G.L. issues a HOLD_VERDICT: the tier stands, and a specific evidence checklist is provided for what would be required to support the lower tier.

---

## API / Agent Framework

```python
import anthropic, pathlib

role_prompt = pathlib.Path("roles/productivity/ai-governance-lead/prompt.md").read_text()

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-opus-4-6",
    system=role_prompt,
    messages=[{
        "role": "user",
        "content": "An LLM agent that automatically approves or rejects insurance claims based on policy rules. EU deployment. No human review step."
    }],
)
print(response.content[0].text)
```

A.G.L. is stateless — each classification request is independent. No session history is required or maintained.

---

## Files

| File | Description |
|------|-------------|
| [`prompt.md`](prompt.md) | Canonical prompt |
| [`prompt-semanticode.md`](prompt-semanticode.md) | LOSSLESS SemantiCode variant |
