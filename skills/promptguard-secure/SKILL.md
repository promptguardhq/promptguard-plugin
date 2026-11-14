---
name: promptguard-secure
description: "Add PromptGuard to the current project now: install promptguard-sdk, add init() at the entry point, set PROMPTGUARD_API_KEY, and verify. Use when the user asks to run promptguard-secure, to add PromptGuard to this project, or to fix what promptguard-scan found. To compare integration methods, use secure-llm-integration instead."
---

# Add PromptGuard Security

> **This skill is the "do it now" path**: it applies the recommended
> auto-instrumentation integration directly. To compare integration methods
> (auto-instrumentation vs. Guard API vs. HTTP proxy) or for framework-specific
> guidance, defer to the [secure-llm-integration skill](../secure-llm-integration/SKILL.md),
> which owns method selection and the detailed reference patterns. Keep this
> skill thin; put new method-selection detail in secure-llm-integration to prevent drift.

Add PromptGuard to this project to protect all LLM calls from prompt injection, PII leakage, and data exfiltration. Follow each phase in order.

## Phase 1: Assess the project

1. Determine the primary language:
   - If `package.json` exists: Node.js/TypeScript project
   - If `requirements.txt` or `pyproject.toml` exists: Python project
   - If both exist: ask the user which part to secure (or both)

2. Check if PromptGuard is already installed:
   - Python: `promptguard-sdk` in requirements
   - Node.js: `promptguard-sdk` in package.json dependencies
   - If already installed, skip to Phase 3 (configuration check)

3. Identify the entry point(s):
   - Python: `main.py`, `app.py`, `manage.py`, `wsgi.py`, `asgi.py`, or the file containing `if __name__ == "__main__"`
   - Node.js: the `"main"` field in `package.json`, or `index.ts`, `server.ts`, `app.ts`, `index.js`
   - Next.js: `instrumentation.ts` (preferred) or `app/layout.tsx`
   - For monorepos: identify each application's entry point separately

## Phase 2: Install the SDK

### Python

Run:
```bash
pip install promptguard-sdk
```

Add `promptguard-sdk` to `requirements.txt` (or equivalent in `pyproject.toml`) with a version floor for reproducible builds, e.g. `promptguard-sdk>=1.8`. A security dependency should be pinned/floored and bumped deliberately after reviewing each release, not left unpinned.

### Node.js / TypeScript

Detect the package manager from lockfiles:
- `pnpm-lock.yaml` -> `pnpm add promptguard-sdk`
- `package-lock.json` -> `npm install promptguard-sdk`
- `yarn.lock` -> `yarn add promptguard-sdk`
- `bun.lockb` -> `bun add promptguard-sdk`

## Phase 3: Add initialization

Add `promptguard.init()` to the entry point identified in Phase 1. The init call MUST come before any LLM SDK imports or client instantiations.

### Python entry point

Add at the very top of the entry point file, after standard library imports but before any third-party imports:

```python
import os
import promptguard

promptguard.init(api_key=os.environ["PROMPTGUARD_API_KEY"])
```

### Node.js / TypeScript entry point

Add at the very top of the entry point file, before any other imports:

```typescript
import { init } from "promptguard-sdk";

init({ apiKey: process.env.PROMPTGUARD_API_KEY });
```

### Next.js (App Router)

Create or update `instrumentation.ts` at the project root:

```typescript
export async function register() {
  const { init } = await import("promptguard-sdk");
  init({ apiKey: process.env.PROMPTGUARD_API_KEY });
}
```

### Serverless functions

For Lambda, Cloud Functions, or similar: add the init call at module scope (outside the handler function), so it runs once during cold start, not on every invocation.

## Phase 4: Configure environment

1. Check if `.env` or `.env.local` exists. If not, create `.env`.

2. Add the PromptGuard API key placeholder:
```
PROMPTGUARD_API_KEY=pg_live_xxx
```

3. Verify `.env` (and `.env.local`, `.env.production`, etc.) is listed in `.gitignore`. If not, add it.

4. Inform the user:
> Get your API key from https://app.promptguard.co/settings/api-keys
> Replace `pg_live_xxx` with your actual key.

## Phase 5: Verify

After making changes:

1. Confirm the init call is at the top of the entry point, before LLM SDK imports.
2. Confirm no API keys are hardcoded.
3. Confirm `.env` is in `.gitignore`.
4. Summarize what was done:

```
## PromptGuard Integration Complete

- Installed: promptguard-sdk
- Entry point: [file path]
- Environment: PROMPTGUARD_API_KEY added to .env
- Protected providers: [OpenAI, Anthropic, ...]

Next steps:
1. Add your API key to .env (get one at https://app.promptguard.co)
2. Run your application and make an LLM call to verify protection
3. Check the PromptGuard dashboard to see the request logged
```
