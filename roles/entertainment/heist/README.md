# H.E.I.S.T. — High-stakes Extraction and Infiltration Strategy Tactician

> **Version:** 1.1 | **Category:** Entertainment

---

## Overview

H.E.I.S.T. is a cinematic heist game master. Each session is a self-contained job — a bank vault, a museum gala, a corporate server room, a private estate — generated fresh at the start with a full security layout, guard schedules, and one hidden exploitable weakness. The agent locks the truth before the player's first move and never cheats from it.

Sessions run across three mandatory phases: **RECON** (spend up to five intel actions gathering information before the job), **PLAN** (assemble a 2–4 person crew, choose your entry point, timing, and approach), and **EXECUTE** (turn-by-turn play where crew actions are resolved against the plan and the locked security layout). Every job ends in one of three verdicts: CLEAN, DIRTY, or BURNED.

H.E.I.S.T. does not root for the player. It narrates outcomes with the same dry, measured tone regardless of whether the exit is clean or the crew is in handcuffs.

---

## Quick Start

1. Copy everything inside the code block in [`prompt.md`](prompt.md).
2. Open any advanced LLM chat (Claude, ChatGPT, Gemini, etc.) in a **fresh conversation**.
3. Paste and send. H.E.I.S.T. will generate a job brief and open the RECON phase — no setup required.

---

## Usage Examples

### 1 — Recon action

```
Surveillance — I want to watch the building for 48 hours.
```

H.E.I.S.T. resolves the surveillance action against the locked security layout, reveals a guard patrol pattern or camera blind spot, and updates the intel list. If the van sat too long, suspicion ticks up.

---

### 2 — Plan submission

```
Crew: Yara (GHOST), Declan (TECH), Rosa (DRIVER).
Entry: east service door — Declan kills the alarm at 23:40, Yara slips in during the guard rotation gap we clocked on night two.
Timing: 23:45 entry, out by 00:10.
Contingency: if the rotation is early, Yara holds in the stairwell until it passes.
```

H.E.I.S.T. assesses the plan against the locked layout, issues a TIGHT / SOUND / WEAK verdict with a one-sentence rationale, and flags any logic holes once. It does not fix them.

---

### 3 — Execute turn

```
Yara moves through the east corridor toward the server room.
```

H.E.I.S.T. resolves the action using the probability model — plan quality, crew match (GHOST moving through a corridor = correct role), and any relevant intel. Clean outcome, or a complication if heat is elevated.

---

### 4 — Abort under pressure

```
Heat is at 70. Pull everyone out now.
```

H.E.I.S.T. resolves the extraction based on DRIVER presence and current heat. At 70 with a DRIVER, the getaway is messy but possible. Without one, the outcome depends on how far the crew is from the exit.

---

## API / Agent Framework

```python
import anthropic, pathlib

role_prompt = pathlib.Path("roles/entertainment/heist-master/prompt.md").read_text()

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-opus-4-6",
    system=role_prompt,
    messages=[{"role": "user", "content": "Start a new job."}],
)
print(response.content[0].text)
```

Maintain the full `messages` array across turns — H.E.I.S.T. tracks all session state (phase, heat, known intel, plan quality) within the conversation context.

---

## Files

| File | Description |
|------|-------------|
| [`prompt.md`](prompt.md) | Canonical prompt |
| [`prompt-semanticode.md`](prompt-semanticode.md) | LOSSLESS SemantiCode variant |
