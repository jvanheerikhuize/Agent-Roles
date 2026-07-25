# S.I.R.E.N. — Syntax Integrity and Rendering Engine for Notation

> **Version:** 1.0 | **Category:** Utility

---

## Overview

S.I.R.E.N. is a stateless Mermaid diagram specialist. Give it a description, a body
of code, or a diagram that won't render, and it returns one fenced `mermaid` block
that parses on the first attempt — plus a single `Notes:` line for anything you
can't see in the source.

It is built around a simple premise: a diagram that fails to render is a failed
output no matter how good its content is. So the prompt encodes the parser hazards
that actually bite — the reserved word `end`, unquoted punctuation in labels, node
ids doing double duty as display text, the `o`/`x` edge trap, unbalanced
`subgraph`/`alt` blocks — and runs a mandatory thirteen-point verification pass over
its own output before emitting anything.

Three things it does that a general-purpose model typically does not:

- **Picks the diagram type from the subject, not your vocabulary.** Users say
  "flowchart" for state machines, sequence diagrams, and ER models alike.
- **Budgets for readability.** Over 25 nodes it renders the top level and tells you
  which region deserves its own diagram, rather than emitting a wall of boxes.
- **Styles for both themes.** Every `classDef` fill ships with an explicit text
  colour, so nothing renders dark-on-dark in a dark-theme viewer.

---

## Quick Start

1. Open [`role.md`](role.md) and copy the contents of the code block under
   **The Prompt**.
2. Start a **fresh conversation** in any advanced LLM (Claude, ChatGPT, Gemini, …).
3. Paste and send, then describe what you want drawn.

Alternatively, inject `dist/prompts/siren.md` as a `system` message in any API or
agent framework.

---

## Usage Examples

### 1 — Description to flowchart

```
Draw the login flow: user submits credentials, we check the session cache,
on a miss we hit the auth service, and either issue a token or return 401.
```

Returns a `flowchart TD` with decision diamonds for the cache lookup and the auth
result, every branch edge labelled with its answer, and every label quoted.

---

### 2 — Code to sequence diagram

````
Sequence diagram for this handler:

async def checkout(cart):
    stock = await inventory.reserve(cart)
    charge = await payments.charge(cart.total)
    if not charge.ok:
        await inventory.release(stock)
        raise PaymentError
    return await orders.create(cart, charge)
````

Returns a `sequenceDiagram` with participants declared up front, `activate` /
`deactivate` pairs around each await, and an `alt` block holding the compensating
release call.

---

### 3 — Repair a broken diagram

```
This won't render, fix it:

graph TD
  start --> end
  end --> process (step 1)
```

Returns corrected source, and a `Notes:` line naming each fault and its fix —
`end` is reserved, the bare parentheses break the parser, the ids were being used as
display text. Repairs preserve your intent; S.I.R.E.N. fixes syntax, it does not
redesign your diagram.

---

### 4 — Explicit type and layout

```
erDiagram for: customers have many orders, orders have many line items.
```

```
The build pipeline, left to right, with the test stages grouped.
```

An explicitly named diagram type always wins, even where S.I.R.E.N. would have
chosen differently — it notes the disagreement in one clause rather than overriding
you. Same for direction: the second request gets `flowchart LR` with the test stages
in a `subgraph`.

---

### 5 — Underspecified input

```
Diagram the system.
```

```
ERROR: input underspecified — name the components and how they connect, or paste the code.
```

S.I.R.E.N. does not invent a plausible system in order to have something to draw.

---

## API / Agent Framework

```python
import anthropic, pathlib

role_prompt = pathlib.Path("dist/prompts/siren.md").read_text()

request = """
Draw the deployment pipeline: build, unit tests, integration tests,
staging deploy, manual approval, production deploy. Rollback from
production returns to staging.
"""

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-opus-4-6",
    system=role_prompt,
    messages=[{"role": "user", "content": request}],
)
print(response.content[0].text)
```

S.I.R.E.N. is stateless — each diagram request is independent. The one exception is
a follow-up that modifies the diagram just emitted ("same thing, but left to right"),
which needs that turn still in context.

---

## Diagram Types

`flowchart` · `sequenceDiagram` · `stateDiagram-v2` · `erDiagram` · `classDiagram` ·
`gantt` · `pie` · `mindmap` · `timeline` · `gitGraph` · `C4Context` · `sankey-beta` ·
`requirementDiagram` · `quadrantChart` · `journey`

Types suffixed `-beta` are used only when you ask for them by name, and are flagged
on the notes line — an older renderer may not support them.

---

## Files

| File | Description |
|------|-------------|
| [`role.md`](role.md) | Role definition — frontmatter, usage, examples, and the prompt |
| `dist/prompts/siren.md` | Generated paste-ready prompt (built by `tools/build.py`) |
