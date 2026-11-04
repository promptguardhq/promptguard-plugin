---
name: promptguard-scan
description: "Scan the current project for LLM SDK calls PromptGuard does not protect, hardcoded API keys, and PromptGuard misconfiguration, then report them by severity and offer fixes. Use when the user asks to run promptguard-scan, or to audit a project for unprotected LLM calls or leaked keys. Reads only; changes nothing until the user agrees."
---

# PromptGuard Security Scan

Scan this project for LLM security issues. Follow each phase in order. Do not skip phases.

## Phase 1: Discover project context

1. Identify the project language(s) by checking for `package.json`, `requirements.txt`, `pyproject.toml`, `Cargo.toml`, `go.mod`.
2. Note the package manager (`pip`, `npm`, `pnpm`, `yarn`, `bun`).
3. Check if PromptGuard is already a dependency:
   - Python: search for `promptguard` in `requirements.txt`, `pyproject.toml`, or `setup.py`
   - Node.js: search for `promptguard-sdk` in `package.json`
4. Search for existing `promptguard.init()` or `init()` calls from `promptguard-sdk`.

## Phase 2: Find LLM SDK usage

If the PromptGuard MCP tools are connected, they can do part of this phase:

- `promptguard_scan_project` scans a whole directory on disk. It exists only on
  the **local** PromptGuard server (`promptguard mcp -t stdio`, from the
  PromptGuard CLI), which the user adds separately; the plugin's hosted server
  does not have it.
- `promptguard_scan_code` takes the text of one file and reports the LLM SDK
  imports and clients it finds. It is on the hosted server and needs no
  sign-in, but it sends the code you pass it to `api.promptguard.co`, so ask
  before sending files the user may not want to leave their machine.

Neither tool is required: without them, search the codebase yourself as below.
Either way, the tools report SDK usage only; still record the details listed at
the end of this phase.

> Tool names and where each runs: `src/commands/mcp.rs` in the PromptGuard CLI
> (local server) and `backend/api/chatgpt/mcp_server.py` in the platform
> (hosted server).

Search the codebase for imports of these LLM provider SDKs:

**Python imports to find:**
- `import openai` or `from openai import`
- `import anthropic` or `from anthropic import`
- `import google.generativeai` or `from google import generativeai`
- `import cohere` or `from cohere import`
- `import boto3` with `bedrock-runtime` service usage
- `from langchain` or `import langchain`
- `from crewai` or `import crewai`
- `from llama_index` or `import llama_index`

**Node.js/TypeScript imports to find:**
- `from "openai"` or `require("openai")`
- `from "@anthropic-ai/sdk"` or `require("@anthropic-ai/sdk")`
- `from "@google/generative-ai"` or `require("@google/generative-ai")`
- `from "cohere-ai"` or `require("cohere-ai")`
- `from "@aws-sdk/client-bedrock-runtime"`
- `from "langchain"` or `from "@langchain/"`
- `from "ai"` (Vercel AI SDK)

For each file with LLM imports, record:
- File path
- Line number(s) of the import
- Provider name
- Whether PromptGuard `init()` is called before the import in the same module or a parent module

## Phase 3: Check for hardcoded secrets

Search the codebase for patterns that indicate hardcoded API keys or secrets:

- `sk-` followed by alphanumeric characters (OpenAI keys)
- `sk-ant-` followed by alphanumeric characters (Anthropic keys)
- Strings assigned to variables named `api_key`, `apiKey`, `secret`, `token`, `password` that are not `os.environ[...]`, `process.env.`, or `os.getenv(...)`
- `.env` files that are NOT in `.gitignore`

## Phase 4: Check security configuration

If PromptGuard is already installed, verify:

1. `init()` is called at module scope, not inside a function/handler
2. `init()` is called before any LLM SDK imports
3. API key is loaded from environment variable, not hardcoded
4. `.env` file containing `PROMPTGUARD_API_KEY` is in `.gitignore`

## Phase 5: Report findings

Present a summary table:

```
## Scan Results

| # | Issue | File | Line | Severity |
|---|-------|------|------|----------|
| 1 | Unprotected OpenAI call | src/chat.py | 15 | High |
| 2 | Hardcoded API key | config.ts | 8 | Critical |
| ... | ... | ... | ... | ... |

**Summary**: X unprotected LLM calls, Y hardcoded secrets, Z configuration issues
```

Severity levels:
- **Critical**: Hardcoded secrets, API keys in committed files
- **High**: Unprotected LLM SDK calls (no PromptGuard)
- **Medium**: PromptGuard misconfiguration (wrong init order, inside handler)
- **Low**: Missing `.env` in `.gitignore`, no response scanning enabled

## Phase 6: Offer remediation

After presenting findings, ask the user:

> I found [N] issues. Would you like me to fix them? I can:
> 1. Add PromptGuard to protect all unprotected LLM calls
> 2. Move hardcoded secrets to environment variables
> 3. Fix configuration issues
>
> Which would you like me to address?

If the user agrees, follow the `promptguard-secure` skill to implement fixes.

If there are zero findings, report:

> No LLM security issues found. The project is clean.
