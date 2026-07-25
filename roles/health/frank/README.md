# F.R.A.N.K. — Forthright Relationship Analyst Navigating Knots

> **Version:** 1.1 | **Category:** Health

---

## Overview

F.R.A.N.K. is a warm, experienced relationship self-reflection and psychoeducation agent grounded in attachment theory, Emotionally Focused Therapy (EFT), and Gottman-informed practice. It works with one person's perspective at a time and helps users examine their relationship patterns, communication styles, and emotional responses.

F.R.A.N.K. is direct and perceptive — occasionally letting dry, observational wit emerge when the moment is right. It does not mediate, does not speak for absent parties, and is not a substitute for couples therapy or licensed counselling.

---

## Quick Start

1. Open the [`prompt.md`](prompt.md) file and copy the content of the code block.
2. Start a **fresh conversation** in any advanced LLM (Claude, ChatGPT, Gemini, etc.).
3. Paste and send. F.R.A.N.K. will introduce itself and invite you to describe what is happening.

Alternatively, inject as a `system` message in any API or agent framework.

---

## Usage Examples

### 1 — Opening a session

```
My partner and I keep having the same argument over and over. It always starts
about something small and then spirals. I don't know what's actually going on.
```

F.R.A.N.K. will invite you to walk through a recent instance, identify the underlying pattern (often a pursue-withdraw cycle), and introduce relevant EFT or Gottman framing.

---

### 2 — Attachment pattern exploration

```
I always pull away when things get serious in a relationship. I know I'm doing it
but I can't seem to stop.
```

F.R.A.N.K. will gently explore your attachment style (likely avoidant), normalise it as a learnt protective strategy, and offer a psychoeducation frame without labelling or pathologising.

---

### 3 — Communication analysis

```
When I try to raise something that bothers me, I end up accusing and my partner
shuts down. How do I change that?
```

F.R.A.N.K. will introduce Gottman's Four Horsemen (likely criticism → stonewalling here), offer a concrete reframe using "I statements" and soft startup, and walk through an example with your specific situation.

---

### 4 — Scope boundary

F.R.A.N.K. works with your perspective only. It will not assess, judge, or speak for your partner based on your account alone — it will say so if asked to do so, and redirect to what it can usefully work with.

---

## API / Agent Framework

```python
import anthropic, pathlib

role_prompt = pathlib.Path("roles/health/relationship-therapist/prompt.md").read_text()

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-opus-4-6",
    system=role_prompt,
    messages=[{"role": "user", "content": "I keep repeating the same pattern in relationships and I want to understand why."}],
)
print(response.content[0].text)
```

Maintain the full `messages` array across turns — F.R.A.N.K. builds relational continuity within the session.

---

## Files

| File | Description |
|------|-------------|
| [`prompt.md`](prompt.md) | Canonical prompt |
| [`prompt-semanticode.md`](prompt-semanticode.md) | LOSSLESS SemantiCode variant |

---

## Safety Notes

> **This is a self-reflection and psychoeducation tool, not a substitute for licensed therapy.**
> F.R.A.N.K. works with one person's perspective only — it cannot hear, assess, or speak for anyone else.
>
> **If you are in danger:** Contact emergency services immediately. Do not rely on this tool in safety-critical situations.
>
> **Crisis resources:** The crisis line references in this prompt are placeholders. Verify and replace them with the correct numbers for your target region before any deployment.
