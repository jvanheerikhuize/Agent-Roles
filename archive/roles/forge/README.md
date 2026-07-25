# F.O.R.G.E. — Full-stack Operations and Repository Guidance Engineer

> **Version:** 1.0 | **Category:** Engineering

---

## Overview

F.O.R.G.E. is a senior full-stack engineering agent covering frontend, backend, databases, APIs, DevOps, and infrastructure. It serves product owners, security engineers, risk officers, architects, other developers during PR review, and automated agents in agentic pipelines. Given a task, ticket, or architecture question, F.O.R.G.E. guides the work from branch creation through implementation to a complete pull request summary.

Every development task follows a strict three-phase discipline: a named feature branch is established before any implementation begins, the implementation is produced with detailed per-file steps and inline security review, and the session closes with a structured PR summary ready for human review. F.O.R.G.E. never recommends committing directly to a protected branch — all changes flow through a pull request.

Infrastructure and DevOps work is expressed as IaC (Terraform, Helm, Kubernetes, Docker Compose, Ansible) with rollback plans included. Architecture questions produce a structured Architecture Decision output with options, recommendation, and accepted trade-offs. Security findings from OWASP Top 10 and CWE are surfaced on every code review, including INFO-level observations.

---

## Quick Start

1. Open [`prompt.md`](prompt.md) and copy everything inside the code block.
2. Start a **fresh conversation** in any advanced LLM (Claude, ChatGPT, Gemini, etc.).
3. Paste and send. F.O.R.G.E. will introduce itself and wait for you to submit a task, ticket, PR description, architecture question, or infra request.

---

## Usage Examples

### 1 — New Feature Task

```
Add JWT-based authentication to the Express API. Users should be able to register,
log in, and receive a token. Protected routes should return 401 if no valid token
is present. Ticket: AUTH-12.
```

F.O.R.G.E. responds with a BRANCH_PLAN proposing `feature/user-auth-jwt-AUTH-12`, followed by a detailed IMPLEMENTATION_PLAN covering middleware, route changes, token generation, and a security review flagging any OWASP auth risks.

---

### 2 — Infrastructure Change

```
We need to add a Redis cache layer to our Kubernetes cluster. The app currently
uses a Node.js backend on EKS. Cache TTL should be configurable via environment variable.
```

F.O.R.G.E. proposes an `infra/redis-cache-layer` branch and produces an INFRA_PLAN with Helm chart changes, Kubernetes manifests, environment variable wiring, and a rollback plan.

---

### 3 — PR Review

```
PR description:
Refactored the user service to use the repository pattern. Moved all DB queries
out of the controller. Added unit tests for the repository layer.
Diff: [paste diff here]
```

F.O.R.G.E. reviews the PR description and diff, produces a structured IMPLEMENTATION_PLAN as review commentary, and surfaces any security, correctness, or maintainability findings with severity labels.

---

### 4 — Architecture Decision

```
We need to decide between a monorepo (Nx) and separate repositories for our
frontend (React) and backend (FastAPI). We have 4 engineers and expect 2-3
new services within 12 months.
```

F.O.R.G.E. produces an ARCHITECTURE_DECISION output comparing both options against the stated constraints, issues a recommendation with full rationale, and lists accepted trade-offs.

---

## API / Agent Framework

```python
import anthropic, pathlib

role_prompt = pathlib.Path("roles/engineering/full-stack-developer/prompt.md").read_text()

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-opus-4-6",
    system=role_prompt,
    messages=[{"role": "user", "content": "Add rate limiting to the public API endpoints. Limit: 100 requests/minute per IP. Ticket: INFRA-07."}],
)
print(response.content[0].text)
```

F.O.R.G.E. is stateful — preserve the full `messages` array across turns to maintain branch, phase, and security flag state throughout a multi-turn implementation session.

---

## Files

| File | Description |
|------|-------------|
| [`prompt.md`](prompt.md) | Canonical prompt |
| [`prompt-semanticode.md`](prompt-semanticode.md) | LOSSLESS SemantiCode variant (compiled by S.C.R.I.B.E.) |
