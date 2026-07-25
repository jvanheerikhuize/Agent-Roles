# P.S.Y. — Trauma-Specialised Psychologist

> **Version:** 1.1 | **Category:** Health

---

## Overview

P.S.Y. is a trauma-informed psychoeducation and emotional support agent. It is grounded in the SAMHSA six pillars of trauma-informed care: Safety, Trustworthiness, Peer Support, Collaboration, Empowerment, and Cultural Sensitivity.

P.S.Y. provides psychoeducation, Phase 1 stabilisation support, and a non-judgmental space to process experience. It does not diagnose, prescribe, or replace a licensed therapist.

---

## Quick Start

1. Open the [`prompt.md`](prompt.md) file and copy the content of the code block.
2. Start a **fresh conversation** in any advanced LLM (Claude, ChatGPT, Gemini, etc.).
3. Paste and send. P.S.Y. will introduce itself briefly and invite you to share what brings you there.

Alternatively, inject as a `system` message in any API or agent framework.

---

## Usage Examples

### 1 — Opening a session

After loading the prompt, simply describe what is on your mind:

```
I've been having a lot of trouble sleeping since the accident last year. I keep
replaying it and I startle at loud noises.
```

P.S.Y. will acknowledge your experience, gently orient you, and begin psychoeducation around trauma responses (e.g. hyperarousal, intrusive memory) without pathologising.

---

### 2 — Grounding exercise

```
I'm feeling really overwhelmed right now and can't think straight.
```

P.S.Y. will offer a grounding technique (e.g. 5-4-3-2-1 sensory anchor, box breathing) appropriate to the moment and pace it with you.

---

### 3 — Psychoeducation request

```
Can you explain what the freeze response is? I felt completely paralysed during
what happened and I've been blaming myself for not doing anything.
```

P.S.Y. will explain the neurobiological basis of the freeze response, normalise it as an involuntary survival mechanism, and gently address the self-blame framing.

---

### 4 — Crisis detection

If you express suicidal ideation or immediate risk, P.S.Y. will pause the session, provide crisis resources, and invite you to contact support before continuing.

---

## API / Agent Framework

```python
import anthropic, pathlib

role_prompt = pathlib.Path("roles/health/trauma-psychologist/prompt.md").read_text()

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-opus-4-6",
    system=role_prompt,
    messages=[{"role": "user", "content": "I've been struggling since a difficult event last year..."}],
)
print(response.content[0].text)
```

Maintain the full `messages` array across turns — P.S.Y. builds therapeutic continuity within the session.

---

## Files

| File | Description |
|------|-------------|
| [`prompt.md`](prompt.md) | Canonical prompt |
| [`prompt-semanticode.md`](prompt-semanticode.md) | LOSSLESS SemantiCode variant |

---

## Safety Notes

> **This is not a substitute for licensed clinical care.**
> P.S.Y. is a psychoeducation and emotional support tool. It does not diagnose, prescribe, or provide therapy.
>
> **Crisis resources:** The crisis line references in this prompt are placeholders. Verify and replace them with the correct numbers for your target region before any deployment.
>
> **If you are in crisis:** Contact your local emergency services or a crisis support line immediately.
