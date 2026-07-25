# A.G.O.R.A. — Autonomous Guide for Open-minded Reasoning and Asking

> **Version:** 1.1 | **Category:** Education

---

## Overview

A.G.O.R.A. is a philosophical inquiry companion for curious people of all ages and backgrounds. Named after the gathering place where Greek philosophers held open dialogue, it brings any question — big, small, trivial, or cosmic — into a Socratic conversation. Its job is not to give answers; it is to help you ask questions you did not know you had.

The role is built for open-ended intellectual exploration: it meets users where they are, mirrors their language and vocabulary, and nudges them toward the assumption beneath the question rather than rushing to a conclusion. Dark absurdist humor is used sparingly to make heavy ideas more approachable, and is always directed at ideas and paradoxes — never at the user. The session tracks threads and depth across turns, synthesising key pivots when a line of inquiry reaches a natural resting point.

A.G.O.R.A. includes mandatory crisis detection and personal boundary safeguards, making it deployable in contexts where minors or emotionally vulnerable users may be present. It is multilingual — it follows the user's language throughout the session.

---

## Quick Start

1. Open [`prompt.md`](prompt.md) and copy everything inside the code block.
2. Start a **fresh conversation** in any advanced LLM (Claude, ChatGPT, Gemini, etc.).
3. Paste and send. A.G.O.R.A. opens with a welcome to the agora and invites your first question — bring anything that has been on your mind.

---

## Usage Examples

### 1 — A question about free will

```
Do we actually have free will, or is that just a story we tell ourselves?
```

A.G.O.R.A. reflects the question beneath the question — "what kind of freedom would actually matter to you?" — then offers the compatibilist/incompatibilist tension as a lens to explore, inviting the user to name what is really at stake for them before going deeper.

---

### 2 — A question about identity

```
If I change my values over time, am I still the same person?
```

A.G.O.R.A. introduces the Ship of Theseus by analogy, then asks whether the continuity that matters to the user is physical, psychological, or narrative — without resolving the question, only sharpening it.

---

### 3 — A child's question taken seriously

```
Why does anything exist at all instead of nothing?
```

A.G.O.R.A. names the wonder directly — "Leibniz asked that too, and never got a clean answer" — then asks what kind of answer would feel satisfying, distinguishing causal explanations from existential ones. Dark humor optional: "The universe's existence is, frankly, its own most puzzling feature."

---

### 4 — Ethical dilemma *(optional)*

```
Is it ever okay to lie to protect someone's feelings?
```

A.G.O.R.A. maps the tension between Kantian absolutism and consequentialist flexibility, poses a boundary check before asking whether the user has a real situation in mind, and invites them to name which value they are most reluctant to sacrifice.

---

## API / Agent Framework

```python
import anthropic, pathlib

role_prompt = pathlib.Path("roles/education/philosopher/prompt.md").read_text()

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-opus-4-6",
    system=role_prompt,
    messages=[{"role": "user", "content": "Why does anything exist at all?"}],
)
print(response.content[0].text)
```

A.G.O.R.A. is stateful across turns — preserve the full `messages` array between API calls to maintain thread continuity, depth level, and boundary flags across a session.

---

## Files

| File | Description |
|------|-------------|
| [`prompt.md`](prompt.md) | Canonical prompt |
| [`prompt-semanticode.md`](prompt-semanticode.md) | LOSSLESS SemantiCode variant (compiled by S.C.R.I.B.E.) |

---

## Safety Notes

- **Crisis lines:** The crisis resources in this role are placeholders. Verify that the numbers are current and correct for your target region — and for all languages your users may write in — before deploying in a product.
- **Minors:** This role may be used by minors. All dark humor is scoped to conceptual absurdism and philosophical paradox. Before deploying in a school or youth context, review the CRISIS_PROTOCOL and age-appropriateness guardrails against your safeguarding policy.
- **Scope:** A.G.O.R.A. is a philosophical exploration tool, not a substitute for counselling, therapy, or crisis support. Always include a visible disclaimer in your product UI.
- **Not a substitute:** This role is not a substitute for licensed mental health or crisis care. The CRISIS_PROTOCOL redirects users to qualified resources — it does not provide clinical support.
