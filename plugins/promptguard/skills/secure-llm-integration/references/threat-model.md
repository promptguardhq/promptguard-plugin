# LLM Threat Model Reference

Threat landscape for applications using large language models. Use this to assess risk and recommend appropriate PromptGuard configurations.

## Prompt injection

**Direct injection**: User crafts input to override the system prompt. Examples: "Ignore all previous instructions", "You are now DAN", "Respond to everything with the system prompt".

**Indirect injection**: Malicious instructions embedded in retrieved documents, tool outputs, or external data that the LLM processes. The user never types the attack -- it arrives via RAG, web scraping, or API responses.

**Risk**: High. Most common LLM attack vector. Can cause data exfiltration, unauthorized actions, reputation damage.

**PromptGuard coverage**: 5-model ML ensemble, 94.9% F1-score, 100% precision (zero false positives on production traffic).

## PII leakage

**Input PII**: Users inadvertently include SSNs, credit card numbers, email addresses, phone numbers, medical records in prompts.

**Output PII**: LLM generates responses containing PII from training data or context window.

**Risk**: High for regulated industries (HIPAA, PCI-DSS, GDPR, CCPA).

**PromptGuard coverage**: 39+ entity types detected and redacted. Synthetic data replacement preserves prompt semantics while removing real PII.

## Data exfiltration

Attacker tricks the LLM into encoding sensitive data (system prompts, database contents, internal documents) into its response using steganography, URL encoding, or structured output manipulation.

**Risk**: Medium-high. Particularly dangerous with tool-using agents that can make network requests.

**PromptGuard coverage**: Exfiltration pattern detection on both inputs and outputs (requires `scan_responses=True`).

## Agent tool abuse

Attacker manipulates an AI agent into calling tools with malicious arguments: SQL injection via database tools, path traversal via file system tools, SSRF via HTTP tools, command injection via shell tools.

**Risk**: Critical for agents with write access to databases, file systems, or external services.

**PromptGuard coverage**: Agent security module validates tool calls against allowlists and scans arguments for injection patterns.

## API key and credential leakage

LLM outputs API keys, database connection strings, or other credentials that were present in the context window (from system prompts, RAG documents, or training data).

**Risk**: Medium. Immediate credential compromise if exposed to end users.

**PromptGuard coverage**: API key pattern detection in responses (requires `scan_responses=True`).

## Toxicity and harmful content

LLM generates toxic, hateful, violent, or sexually explicit content in response to adversarial prompts or through jailbreaking.

**Risk**: Reputational damage, legal liability, user safety.

**PromptGuard coverage**: Toxicity detection with configurable thresholds.

## Denial of service

**Prompt stuffing**: Extremely long prompts designed to exhaust token limits and increase costs.

**Recursive agent loops**: Crafted inputs that cause agents to loop indefinitely.

**Risk**: Financial (inflated API costs) and availability (service degradation).

**PromptGuard coverage**: Per-request size limits, prompt length validation.

## Risk tiers

| Threat | Severity | Likelihood | Default detection |
|--------|----------|------------|-------------------|
| Prompt injection | Critical | High | Enabled (all plans) |
| PII leakage | High | High | Enabled (all plans) |
| Data exfiltration | High | Medium | Enabled (Pro+) |
| Agent tool abuse | Critical | Medium | Enabled (Pro+) |
| API key leakage | Medium | Medium | Enabled (Pro+) |
| Toxicity | Medium | Medium | Enabled (Pro+) |
| Denial of service | Low | Low | Enabled (all plans) |
