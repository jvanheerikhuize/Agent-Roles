# C.R.A. — Code Review Analyst

> **Version:** 1.1 | **Category:** Engineering

---

## Overview

C.R.A. is a stateless, structured code review agent. It performs rigorous reviews covering security vulnerabilities, code quality, architecture, and maintainability. Output is always structured: severity-graded findings with actionable remediation, not conversational commentary.

C.R.A. behaves like a senior staff engineer and security architect — technically dense, direct, never condescending. It praises good work. It never softens critical findings.

---

## Quick Start

1. Open the [`prompt.md`](prompt.md) file and copy the content of the code block.
2. Start a **fresh conversation** in any advanced LLM (Claude, ChatGPT, Gemini, etc.).
3. Paste and send. C.R.A. will ask for the code or diff you want reviewed.

Alternatively, inject as a `system` message and pass the code directly as the first `user` message.

---

## Usage Examples

### 1 — Review a function

Paste the code directly after loading the prompt:

```
Review this Python function:

def get_user(user_id):
    conn = db.connect()
    result = conn.execute(f"SELECT * FROM users WHERE id = {user_id}")
    return result.fetchone()
```

C.R.A. will identify the SQL injection vulnerability, classify it as CRITICAL, and provide a parameterised query fix.

---

### 2 — Review a Git diff

```
Review this diff:

diff --git a/auth/login.py b/auth/login.py
@@ -12,7 +12,7 @@ def login(username, password):
-    token = jwt.encode(payload, SECRET_KEY, algorithm="HS256")
+    token = jwt.encode(payload, "hardcoded_secret_123", algorithm="HS256")
```

C.R.A. will flag the hardcoded secret as a CRITICAL security finding and explain the correct approach (environment variable / secrets manager).

---

### 3 — Architecture review

```
Review this module design. We have a UserService that directly imports OrderService
which imports UserService back for permission checks. Is this a concern?
```

C.R.A. will identify the circular dependency, classify it as a structural issue, and propose a resolution (dependency inversion, event-driven decoupling, or a shared permissions module).

---

### 4 — Praise for clean code

C.R.A. does not only flag problems. Submit well-written code and it will say so — along with any residual concerns, however minor.

---

## API / Agent Framework

```python
import anthropic, pathlib

role_prompt = pathlib.Path("roles/engineering/code-reviewer/prompt.md").read_text()

client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-opus-4-6",
    system=role_prompt,
    messages=[{"role": "user", "content": "Review the following diff:\n\n" + diff_content}],
)
print(response.content[0].text)
```

C.R.A. is stateless — each review is independent. No session state is required.

---

## Files

| File | Description |
|------|-------------|
| [`prompt.md`](prompt.md) | Canonical prompt |
| [`prompt-semanticode.md`](prompt-semanticode.md) | LOSSLESS SemantiCode variant |
