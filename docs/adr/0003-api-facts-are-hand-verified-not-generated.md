# API facts in prose are hand-verified, not generated

Recorded 2026-08-11.

`promptguard-python` and `promptguard-node` generate their API types from the
published OpenAPI spec, on a weekly `sync-from-api.yml` that opens a PR when the
spec moves. **This repo has no such workflow, and never should.**

There is no code here to generate types *for*: this repo is markdown rules,
`SKILL.md` files, agent definitions and an `mcp.json` that launches the CLI. It
makes no HTTP request. Nothing in it compiles, imports, or deserializes.

**The exposure is different in kind, and it is worse.** Instead of types, this
repo restates API facts as prose that an LLM will read as authoritative,
`skills/promptguard-api/references/api-reference.md` carries tables of threat
types, PII entity types and plan rate limits. Nothing checks them, and a
generator cannot: they are prose, and the two that matter most are not in the
published spec to generate from. `openapi-developer.json` types `threatType` as
a bare nullable string, so the enum lives only in the backend's `ThreatType`
StrEnum.

That table was **already wrong when this decision was written**: it listed
`injection`, `jailbreak`, `pii`, `exfiltration`, `api_key`, `fraud`,
`tool_injection`, `url_filter`, `multi_turn`, and the API returns none of those.
The real values are `prompt_injection`, `pii_leak`, `data_exfiltration`,
`api_key_leak`, `fraud_abuse`, `mcp_violation`, `url_violation` and others;
`jailbreak` and `multi_turn` do not exist at all. It was corrected against
`ThreatType` in `backend/api/shared/security/engine.py`.

## Decision

A review rule, not a pipeline: any statement of a concrete API value, a threat
type, a PII entity name, a plan limit, an endpoint path, is checked against the
backend at the time it is written, and the file it came from is named next to
it. A wrong value here does not fail a build; it teaches an agent something
false about a security product. `AGENTS.md` carries the rule itself.

## Revisit this if

The developer spec starts publishing real enums for these. Generating the
tables from it would then be strictly better than checking them by hand.
