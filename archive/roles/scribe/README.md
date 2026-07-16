# S.C.R.I.B.E. — Semantic Compression and Reasoning-Informed Brevity Encoder

> **Version:** 1.0 | **Category:** Utility

---

## Overview

S.C.R.I.B.E. is a stateless prompt compiler. It converts any structured system prompt into a token-efficient SemantiCode logic stream — preserving all semantic content while significantly reducing token count. Three compression modes are available:

| Mode | Token reduction | Use case |
|------|----------------|----------|
| `lossless` (default) | ≥35% | Full fidelity; production system prompts |
| `balanced` | ≥55% | Reduced context windows; API cost optimisation |
| `aggressive` | ≥70% | Maximum compression; advanced LLMs only |

Add `annotated` to any mode for inline `// comments` explaining compression decisions.

---

## Quick Start

1. Open the [`prompt.md`](prompt.md) file and copy the content of the code block.
2. Start a **fresh conversation** in any advanced LLM (Claude, ChatGPT, Gemini, etc.).
3. Paste and send. S.C.R.I.B.E. is ready immediately — paste the prompt you want to compile as your first message.

Alternatively, inject as a `system` message in any API or agent framework.

---

## Usage Examples

### 1 — Compile a simple role prompt (LOSSLESS, default)

Paste any prompt with MODEL/VIEW/CONTROLLER structure directly:

```
<MODEL>
NAME: DEMO
ROLE: Example assistant
PERSONA: Helpful and concise.
BHV:![NO_LIES] Never fabricate facts.
BHV:+[CITE_SOURCES] Always cite the source of factual claims.
</MODEL>
<VIEW>
OUT:RESPONSE: "[Answer]. Source: [citation]"
</VIEW>
<CONTROLLER>
STEP-1: Parse input → STEP-2
STEP-2: Generate response with citation → STEP-3
STEP-3: Output
</CONTROLLER>
```

S.C.R.I.B.E. returns a compressed SemantiCode stream with a SCRIBE_META block showing the compression ratio achieved.

---

### 2 — BALANCED compression

```
balanced

[paste your prompt here]
```

S.C.R.I.B.E. strips rationale prose and secondary detail, targeting ≥55% token reduction while preserving all behavioural rules and output templates.

---

### 3 — AGGRESSIVE with annotations

```
aggressive annotated

[paste your prompt here]
```

S.C.R.I.B.E. compresses to rules-only form and adds inline `// comments` explaining each compression decision — useful for auditing what was elided.

---

### 4 — Compile this library's own prompts

S.C.R.I.B.E. was used to generate all `prompt-semanticode.md` files in this repository. To recompile any role:

1. Load S.C.R.I.B.E.
2. Paste the canonical `prompt.md` content.
3. Use `lossless` mode to produce the `prompt-semanticode.md` variant.

---

## API / Agent Framework

```python
import anthropic, pathlib

role_prompt = pathlib.Path("roles/utility/semanticode-compiler/prompt.md").read_text()
target_prompt = pathlib.Path("roles/engineering/code-reviewer/prompt.md").read_text()

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-opus-4-6",
    system=role_prompt,
    messages=[{"role": "user", "content": f"balanced\n\n{target_prompt}"}],
)
print(response.content[0].text)
```

S.C.R.I.B.E. is stateless — each compilation request is independent.

---

## Files

| File | Description |
|------|-------------|
| [`prompt.md`](prompt.md) | Canonical prompt |
| [`prompt-semanticode.md`](prompt-semanticode.md) | LOSSLESS SemantiCode variant (compiled by S.C.R.I.B.E. itself) |
