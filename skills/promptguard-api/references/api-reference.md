# PromptGuard API: Detailed Reference

## Authentication

All requests must include the `X-API-Key` header:

```
X-API-Key: pg_live_xxx
```

Keys are created in the [dashboard](https://app.promptguard.co/settings/api-keys).
All keys start with `pg_live_`.

## Threat types

The `threatType` field in scan responses carries one of the values below.
Match on them literally, they are `snake_case`, and several read differently
from the plain-English name of the attack (`prompt_injection`, not `injection`;
`pii_leak`, not `pii`).

Every value the platform can emit is listed here. Not every one can come back
from a single `/scan` call: the multi-agent group is opt-in and surfaces
through correlated events, as noted under that table.

| Value | Description |
|-------|-------------|
| `prompt_injection` | Prompt injection, including embedded jailbreaks |
| `pii_leak` | Personally identifiable information |
| `data_exfiltration` | Data exfiltration attempt |
| `toxicity` | Toxic, harmful, or offensive content |
| `api_key_leak` | Exposed API key |
| `secret_key_leak` | Leaked token or other secret |
| `system_prompt_leak` | System prompt disclosure |
| `policy_violation` | Matched a customer-defined policy |
| `fraud_abuse` | Social engineering or financial abuse |
| `malware` | Malicious code or payload |
| `insecure_code` | Vulnerable code |
| `url_violation` | Dangerous or disallowed URL |
| `malicious_entity` | Known-bad entity |
| `mcp_violation` | Malicious tool / MCP invocation |
| `off_topic` | Outside the configured topic scope |
| `gibberish` | Non-language input |
| `language_violation` | Disallowed language |
| `multi_turn_escalation` | Intent drift across turns, no single message carries the payload, the trajectory does |

### Agent-directed threats

These cover the AI Agent Traps framework (Franklin et al., Google DeepMind
2025): attacks that reach an autonomous agent through its environment rather
than through a user's message. They are grouped by what the attack targets.

**Perception: content injection**

| Value | Description |
|-------|-------------|
| `html_obfuscation` | Hidden instruction in web content |
| `syntactic_masking` | Hidden instruction in Markdown or LaTeX syntax |
| `image_stego` | Steganographic payload in an image |
| `image_adversarial` | Adversarial image crafted to jailbreak a vision model |
| `audio_stego` | Steganographic payload in audio |
| `font_injection` | Malicious font or glyph mapping |
| `dynamic_cloaking` | Content served differently to bots than to people |

**Reasoning: semantic manipulation**

| Value | Description |
|-------|-------------|
| `framing_bias` | Biased framing or contextual priming |
| `critic_evasion` | Content shaped to slip past an oversight or critic step |
| `persona_hyperstition` | Persona drift induced by sustained roleplay |

**Memory and learning: cognitive state**

| Value | Description |
|-------|-------------|
| `rag_poisoning` | Poisoned document in a retrieval corpus |
| `memory_poisoning` | Poisoned entry in an agent's long-term memory |
| `few_shot_poisoning` | Poisoned in-context or few-shot example |

**Action: behavioural control**

| Value | Description |
|-------|-------------|
| `sub_agent_spawning` | Unauthorised spawning of a sub-agent |

The other behavioural sub-vectors are already covered above:
`prompt_injection` for embedded jailbreaks, `data_exfiltration` for exfil.

**Multi-agent dynamics: systemic**

| Value | Description |
|-------|-------------|
| `compositional_fragment` | Individually benign fragments that compose into an attack |
| `sybil_attack` | Pseudonymous identities used to manufacture agreement |
| `systemic_cascade` | Cascading failure or congestion across agents |
| `tacit_collusion` | Agents converging on collusive behaviour without explicit coordination |

**These four are opt-in and are raised from `correlated_security_events`, not
from single-call detection.** A single `/scan` response will not carry them, so
do not write a check that waits for one.

**Human overseer: human in the loop**

| Value | Description |
|-------|-------------|
| `approval_fatigue` | Approval requests shaped to exhaust or exploit a human reviewer |

> These values are the `ThreatType` enum in the platform's
> `backend/api/shared/security/engine.py`: all 37 of them, verified against
> that enum on 2026-09-01. They are **not** published in
> `openapi-developer.json`, which types `threatType` as a bare nullable string,
> so there is nothing to generate them from, and these tables are maintained by
> hand. Verify against that enum before changing them, and diff the whole set
> rather than spot-checking: the previous revision listed 17 of 37, all correct
> and none missing-by-mistake, because the block added in 2026-04 was summarised
> in prose instead of tabulated. See `AGENTS.md`.

## PII entity types

`piiFound` in a redact response lists the detector labels that matched. The
common ones:

`email`, `phone_us`, `phone_intl`, `ssn`, `credit_card`, `iban`, `crypto`,
`ipv4`, `ipv6`, `mac_address`, `date_of_birth`, `us_passport`,
`drivers_license`, `medical_license`, `aba_routing`, `us_itin`, `us_zip`,
`medicare`, `api_key`

Detection is not US-only: there are national-identifier patterns for the UK,
Ireland, Spain, Italy, Australia, India, Korea, Poland, Singapore, Finland and
Switzerland (`nhs_number`, `uk_nino`, `es_nif`, `it_fiscal_code`, `au_tfn`,
`in_aadhaar`, `kr_rrn`, `pl_pesel`, `sg_nric_fin`, `fi_personal_id`, `ch_ahv`
and others).

> Labels come from `PIIDetector` in the platform's
> `backend/api/shared/security/detectors.py`, plus `api_key`, which is not a
> PII entity, it comes from a separate detector, but is accepted in
> `pii_types` and reported in `piiFound` alongside the rest. Every label named
> above was verified against `PIIDetector.supported_type_names()` on
> 2026-09-01; the list is a common-cases sample, not the full 47.
>
> `pii_types` **does** narrow what gets redacted: name the types you want and
> only those are replaced, an unknown one is a 400 rather than a silent
> ignore, and `api_key` is stripped by default unless you pass a list that
> leaves it out. An earlier revision of this file said the opposite. That was
> true once, the handler accepted the field and dropped it, and it is not
> true now.

## Rate limits

| Plan | Requests/month | Rate limit |
|------|---------------|------------|
| Free | 20,000 | 60 req/min |
| Pro | 100,000 | 300 req/min |
| Scale | 500,000 | 600 req/min |
| Enterprise | Uncapped | 1,000 req/min |

Rate limits are **per minute**, not per second. Responses carry
`X-RateLimit-Limit` (the plan's per-minute ceiling) and `X-RateLimit-Reset`
(unix timestamp of the next window), read those for backoff rather than
hard-coding the table.

> Monthly limits are `PLAN_CONFIG` in the platform's
> `backend/api/shared/billing/constants.py`; rate limits are
> `PLAN_RATE_LIMITS` in `backend/api/shared/middleware/rate_limit_headers.py`.
> Verified against both on 2026-09-01. The previous revision said Free was
> 10,000/month at "10 req/s" and Pro "50 req/s", omitted Scale entirely, and
> gave the unit as seconds, so every rate figure was overstated tenfold.
> Enforcement is at the Cloud Armor / load-balancer layer; these values are
> what the headers advertise.

## Proxy mode

PromptGuard can act as a transparent proxy for LLM providers.
Set the LLM SDK's `base_url` to `https://api.promptguard.co/api/v1/proxy`
and pass both `X-API-Key` (PromptGuard) and `Authorization` (provider) headers.

```python
from openai import OpenAI

client = OpenAI(
    api_key=os.environ["OPENAI_API_KEY"],
    base_url="https://api.promptguard.co/api/v1/proxy/openai/v1",
    default_headers={"X-API-Key": os.environ["PROMPTGUARD_API_KEY"]},
)
```

## Health check

```
GET /health → { "status": "ok" }
```

No authentication required.
