---
name: promptguard-api
description: "Generate correct PromptGuard API calls for scanning, redacting, and guarding LLM traffic. Use when writing code that calls PromptGuard endpoints, building integrations, or when the user asks about PromptGuard scan, redact, guard, or proxy APIs."
---

# PromptGuard API Reference

## Base URL

```
https://api.promptguard.co/api/v1
```

All requests require the `X-API-Key` header with a key starting with `pg_live_`.

## Endpoints

### POST /security/scan

Scan text for prompt injection, jailbreaks, toxicity, and other threats.

**Request:**

```json
{
  "content": "string (required, max 100k chars)",
  "type": "prompt | response"
}
```

**Response:**

```json
{
  "blocked": true,
  "decision": "allow | block | redact",
  "reason": "Prompt injection detected",
  "threatType": "injection | jailbreak | toxicity | null",
  "confidence": 0.95,
  "eventId": "evt_abc123",
  "processingTimeMs": 42.5
}
```

### POST /security/redact

Remove PII from text (emails, phones, SSNs, credit cards, API keys).

**Request:**

```json
{
  "content": "string (required, max 100k chars)",
  "pii_types": ["email", "phone", "ssn"]
}
```

`pii_types` is optional; omit to redact all detected PII.

**Response:**

```json
{
  "original": "Email me at john@example.com",
  "redacted": "Email me at [EMAIL_REDACTED]",
  "piiFound": ["email"]
}
```

### POST /guard

Full guard endpoint with OpenAI-style message array. Preferred for framework integrations.

**Request:**

```json
{
  "messages": [
    { "role": "user", "content": "Tell me about AI safety" }
  ],
  "direction": "input | output",
  "model": "your-model",
  "context": {
    "framework": "langchain",
    "session_id": "sess_123",
    "agent_id": "agent_1",
    "tool_calls": [{ "name": "search", "arguments": "{}" }]
  }
}
```

Only `messages` is required. All other fields are optional.

**Response:**

```json
{
  "decision": "allow | block | redact",
  "event_id": "evt_abc123",
  "confidence": 0.95,
  "threat_type": "injection | null",
  "redacted_messages": null,
  "threats": [
    { "type": "injection", "confidence": 0.95, "details": "..." }
  ],
  "latency_ms": 38.2
}
```

When `decision` is `"redact"`, `redacted_messages` contains sanitized messages.

## Code examples

### Python

```python
import os
import httpx

BASE_URL = "https://api.promptguard.co/api/v1"
HEADERS = {"X-API-Key": os.environ["PROMPTGUARD_API_KEY"]}

# Scan
resp = httpx.post(f"{BASE_URL}/security/scan", json={
    "content": user_input,
    "type": "prompt",
}, headers=HEADERS)
result = resp.json()
if result["blocked"]:
    raise ValueError(result["reason"])

# Redact
resp = httpx.post(f"{BASE_URL}/security/redact", json={
    "content": user_input,
}, headers=HEADERS)
clean_text = resp.json()["redacted"]

# Guard (message array)
resp = httpx.post(f"{BASE_URL}/guard", json={
    "messages": [{"role": "user", "content": user_input}],
    "direction": "input",
}, headers=HEADERS)
verdict = resp.json()
if verdict["decision"] == "block":
    raise ValueError(f"Blocked: {verdict['threats']}")
```

### Node.js / TypeScript

```typescript
const BASE_URL = "https://api.promptguard.co/api/v1";
const headers = { "X-API-Key": process.env.PROMPTGUARD_API_KEY! };

// Scan
const scan = await fetch(`${BASE_URL}/security/scan`, {
  method: "POST",
  headers: { ...headers, "Content-Type": "application/json" },
  body: JSON.stringify({ content: userInput, type: "prompt" }),
});
const scanResult = await scan.json();
if (scanResult.blocked) throw new Error(scanResult.reason);

// Redact
const redact = await fetch(`${BASE_URL}/security/redact`, {
  method: "POST",
  headers: { ...headers, "Content-Type": "application/json" },
  body: JSON.stringify({ content: userInput }),
});
const { redacted } = await redact.json();

// Guard
const guard = await fetch(`${BASE_URL}/guard`, {
  method: "POST",
  headers: { ...headers, "Content-Type": "application/json" },
  body: JSON.stringify({
    messages: [{ role: "user", content: userInput }],
    direction: "input",
  }),
});
const verdict = await guard.json();
if (verdict.decision === "block") throw new Error(JSON.stringify(verdict.threats));
```

## Error responses

All endpoints return structured errors:

```json
{
  "error": {
    "message": "Human-readable description",
    "type": "authentication_error | quota_exceeded | validation_error",
    "code": "missing_api_key | monthly_quota_exceeded | invalid_request"
  }
}
```

| Status | Meaning |
|--------|---------|
| 401 | Missing or invalid `X-API-Key` |
| 422 | Invalid request body |
| 429 | Quota exceeded (includes `upgrade_url`) |
| 500 | Internal error (fail-open: LLM call proceeds) |

## SDK shortcuts

When using the official SDKs, prefer the SDK over raw HTTP:

- **Python**: `pip install promptguard-sdk` → `import promptguard; promptguard.init(api_key=...)`
- **Node.js**: `npm install promptguard-sdk` → `import { init } from "promptguard-sdk"`
- **CLI**: `promptguard scan --text "..."` or `promptguard verify`

For SDK integration details, see the [secure-llm-integration skill](../secure-llm-integration/SKILL.md).
