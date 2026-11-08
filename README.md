[![CI](https://github.com/promptguardhq/promptguard-plugin/actions/workflows/ci.yml/badge.svg)](https://github.com/promptguardhq/promptguard-plugin/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/promptguardhq/promptguard-plugin)](https://github.com/promptguardhq/promptguard-plugin/blob/main/LICENSE)

# PromptGuard Agent Skills

LLM security for AI coding agents, protect applications from prompt injection, PII leakage, and data exfiltration. Works with **Cursor, Claude Code, Codex, Copilot, Gemini CLI, Windsurf, VSCode**, and any MCP-compatible agent.

## Install the plugin

The plugin gives your agent PromptGuard's skills, a security reviewer, coding
rules, and PromptGuard's hosted MCP server at `https://api.promptguard.co/mcp`.
Nothing needs installing besides the plugin: the MCP server runs at
PromptGuard, and the tools that need an account ask you to sign in to
PromptGuard the first time you use them. You need a PromptGuard account
([promptguard.co](https://promptguard.co)) for those tools.

<details>
<summary>Install in <b>Claude Code</b></summary>
<br />

This repository is its own plugin marketplace, so one line installs it, in a
Claude Code session:

```
/plugin install promptguard --marketplace promptguardhq/promptguard-plugin
```

or in two steps, from your shell:

```bash
claude plugin marketplace add promptguardhq/promptguard-plugin
claude plugin install promptguard@promptguard
```

Sign in to PromptGuard from `/mcp` when a tool asks you to.

The plugin adds the `promptguard:llm-security-reviewer` subagent; it does not
change your main agent. Ask for a security review, or pick the agent from
`/agents`, to use it. The skills run as `/promptguard:promptguard-scan`,
`/promptguard:promptguard-secure` and so on, or on their own when a request
matches them.

**MCP server only** (no skills, rules or reviewer):

```bash
claude mcp add --transport http promptguard https://api.promptguard.co/mcp
```

</details>

<details>
<summary>Install in <b>Cursor</b></summary>
<br />

For the plugin's rules, skills and reviewer as well as the MCP server, install
the plugin from the Cursor Marketplace once it is listed there (Customize →
Marketplace, search "PromptGuard"). Until then, clone this repository into
`~/.cursor/plugins/local/promptguard` and restart Cursor.

**MCP server only.** [One-click install](cursor://anysphere.cursor-deeplink/mcp/install?name=promptguard&config=eyJ1cmwiOiJodHRwczovL2FwaS5wcm9tcHRndWFyZC5jby9tY3AifQ==)
(opens Cursor and adds the hosted server only), or add to `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "promptguard": {
      "type": "http",
      "url": "https://api.promptguard.co/mcp"
    }
  }
}
```

</details>

<details>
<summary>Install in <b>Codex</b></summary>
<br />

**As a plugin** (skills and the MCP server). Copy it to your repo's plugins
directory and register it in your marketplace:

```bash
cp -R /path/to/promptguard-plugin ./plugins/promptguard
```

Add to `.agents/plugins/marketplace.json`:

```json
{
  "name": "local-plugins",
  "plugins": [{
    "name": "promptguard",
    "source": { "source": "local", "path": "./plugins/promptguard" },
    "policy": { "installation": "AVAILABLE", "authentication": "ON_INSTALL" },
    "category": "Security"
  }]
}
```

**MCP server only.** Codex reads MCP servers from `~/.codex/config.toml` (or
`.codex/config.toml` in a trusted project):

```bash
codex mcp add promptguard --url https://api.promptguard.co/mcp
codex mcp login promptguard
```

or add the table yourself, then run `codex mcp login promptguard`:

```toml
[mcp_servers.promptguard]
url = "https://api.promptguard.co/mcp"
```

</details>

<details>
<summary>Install the <b>skills only</b>, in any agent</summary>
<br />

The four skills install on their own, into Claude Code, Cursor, Codex and the
other agents the [`skills`](https://github.com/vercel-labs/skills) CLI
supports:

```bash
npx skills add promptguardhq/promptguard-plugin
```

They teach the agent how to add PromptGuard to an application, how to call
its API, and how to scan a project for unprotected LLM calls. They work
without any MCP server.

</details>

<details>
<summary>Use the MCP server in <b>VS Code / Copilot</b></summary>
<br />

Add to your `.vscode/mcp.json`:

```json
{
  "servers": {
    "promptguard": {
      "type": "http",
      "url": "https://api.promptguard.co/mcp"
    }
  }
}
```

</details>

<details>
<summary>Use the MCP server in <b>Gemini CLI</b></summary>
<br />

Add to `~/.gemini/settings.json`, then run `/mcp auth promptguard` when a tool
asks you to sign in:

```json
{
  "mcpServers": {
    "promptguard": {
      "httpUrl": "https://api.promptguard.co/mcp"
    }
  }
}
```

</details>

<details>
<summary>Use the MCP server in <b>Windsurf or any other MCP client</b></summary>
<br />

Point the client at `https://api.promptguard.co/mcp` as a remote
(streamable HTTP) MCP server. How a client names that setting varies; check its
MCP documentation.

</details>

## MCP tools

The plugin's MCP server is PromptGuard's hosted server. It has these tools:

| Tool | Needs sign-in | Description |
|------|---------------|-------------|
| `promptguard_scan_text` | yes | Scan text for prompt injection, jailbreaks, PII leakage, and toxicity. |
| `promptguard_redact` | yes | Redact PII (emails, phones, SSNs, credit cards, API keys) from text. |
| `promptguard_status` | yes | Show whether you are signed in, and your plan. |
| `promptguard_scan_code` | no | Find LLM SDK imports and clients in a piece of code you pass it. |

> Source: the tool definitions in `backend/api/chatgpt/mcp_server.py` in the
> PromptGuard platform.

## Add the local server too

The PromptGuard CLI has its own MCP server, which runs on your machine. It is
optional, and it has three tools the hosted server cannot have, because they
work on your disk:

| Tool | Description |
|------|-------------|
| `promptguard_scan_project` | Scan a project directory for unprotected LLM SDK usage. |
| `promptguard_auth` | Save a PromptGuard API key for the CLI. Opens the dashboard to copy one. |
| `promptguard_logout` | Remove the CLI's locally stored credentials. |

It also has its own `promptguard_scan_text`, `promptguard_redact` and
`promptguard_status`, which use your API key instead of a sign-in.

> Source: `tool_definitions()` in `src/commands/mcp.rs` in the PromptGuard CLI.

**1. Install the CLI:**

- macOS/Linux: `curl -fsSL https://raw.githubusercontent.com/promptguardhq/promptguard-cli/main/install.sh | sh`
- Windows, or any platform: download the binary from [GitHub Releases](https://github.com/promptguardhq/promptguard-cli/releases/latest)
- Every method, including building from source: [the CLI's installation table](https://github.com/promptguardhq/promptguard-cli#installation)

**2. Get an API key** from [app.promptguard.co/settings/api-keys](https://app.promptguard.co/settings/api-keys)
and give it to the CLI with `promptguard login`, the `promptguard_auth` tool,
or the `PROMPTGUARD_API_KEY` environment variable.

**3. Add the server to your agent** as `promptguard-local`, so it sits beside
the plugin's `promptguard`. It runs `promptguard mcp -t stdio`:

- Claude Code: `claude mcp add promptguard-local -- promptguard mcp -t stdio`
- Codex: `codex mcp add promptguard-local -- promptguard mcp -t stdio`
- Cursor: [one-click install](cursor://anysphere.cursor-deeplink/mcp/install?name=promptguard-local&config=eyJjb21tYW5kIjoicHJvbXB0Z3VhcmQiLCJhcmdzIjpbIm1jcCIsIi10Iiwic3RkaW8iXX0=), or the JSON below in `.cursor/mcp.json`
- Gemini CLI (`~/.gemini/settings.json`) and Windsurf
  (`~/.codeium/windsurf/mcp_config.json`): the JSON below
- VS Code (`.vscode/mcp.json`): the same entry under `"servers"` instead of
  `"mcpServers"`
- Any other client: spawn `promptguard mcp -t stdio` as a subprocess

```json
{
  "mcpServers": {
    "promptguard-local": {
      "command": "promptguard",
      "args": ["mcp", "-t", "stdio"]
    }
  }
}
```

## What this plugin sends where

- **The MCP server runs at PromptGuard**, at `https://api.promptguard.co/mcp`.
  The plugin itself contains no server and runs no program on your machine.
- **`promptguard_scan_text` and `promptguard_redact`** send the text you (or
  your agent) pass them to `api.promptguard.co`, which scans or redacts it
  under your PromptGuard account.
- **`promptguard_scan_code`** sends the code you pass it to
  `api.promptguard.co`. It needs no sign-in.
- **`promptguard_status`** sends nothing but the request itself.
- **Signing in** goes through PromptGuard's Auth0 tenant
  (`dev-zefwlqziaprlzc11.us.auth0.com`) in your browser; your agent then holds
  the sign-in token and sends it with each tool call.
- **Skills, rules and the reviewer** are local text your agent reads. They send
  nothing themselves. Some of them tell the agent how to call the MCP tools
  above, or the PromptGuard API from your own code.
- **The optional local CLI server** (`promptguard-local`) scans your project on
  your machine (`promptguard_scan_project` sends nothing). Its
  `promptguard_scan_text` and `promptguard_redact` send the text to
  `api.promptguard.co` with your API key, `promptguard_auth` checks a key
  against `api.promptguard.co` and opens `app.promptguard.co` in your browser,
  and the key is stored on your machine until `promptguard_logout` removes it.

## What's included

| Component | Description |
|-----------|-------------|
| **Skills** | **Secure LLM Integration**: walks through adding PromptGuard to any project. **PromptGuard API**: teaches the agent exact request/response schemas for scan, redact, and guard endpoints. **promptguard-scan**: finds unprotected LLM calls and hardcoded secrets. **promptguard-secure**: adds PromptGuard to a project end-to-end. |
| **Agent** | LLM Security Reviewer, specialized code reviewer for prompt injection, PII leakage, agent tool abuse, and other LLM-specific vulnerabilities. |
| **Rules** (Cursor) | Guidance that attaches when the agent works on Python or JavaScript/TypeScript source, so it writes secure LLM code with OpenAI, Anthropic, or any supported provider; and a production-readiness review checklist the agent applies when you ask for a review, or that you @-mention. |
| **MCP server** | PromptGuard's hosted server (above). |

These components work natively in Cursor and Claude Code (via their plugin
systems), and the skills and MCP server in Codex. The skills use the standard
`SKILL.md` format, which any agent that reads skill files can load.

## Project attribution

Every request is attributed to the project of the API key it uses. There is no
per-request project setting.

- **Hosted server:** after you sign in, it uses your account's API key named
  "ChatGPT MCP" if you have one, otherwise your most recently created active
  key, and creates a key if you have none (`_select_api_key` and
  `_resolve_api_key` in `backend/api/chatgpt/mcp_server.py`).
- **Local server:** it uses the key you give the CLI. To attribute its traffic
  to a different project, create an API key in that project (in the
  dashboard, under the project's API keys) and give that key to the CLI, for
  example with `promptguard login` or the `PROMPTGUARD_API_KEY` environment
  variable.

## Supported LLM providers

OpenAI, Anthropic, Google Generative AI (Gemini), Cohere, AWS Bedrock, LangChain, CrewAI, LlamaIndex, Vercel AI SDK.

## Versioning and support

- **Versions** follow [semantic versioning](https://semver.org), with the same
  version in the Claude Code, Cursor and Codex manifests, and every change is
  in [`CHANGELOG.md`](./CHANGELOG.md).
- **Requirements:** none beyond the host for the plugin; the MCP tools that
  need an account need a PromptGuard sign-in. The optional local server needs
  the PromptGuard CLI on your `PATH` (see
  [Add the local server too](#add-the-local-server-too)).
- **API version:** the skills and the optional local server use PromptGuard's
  `/api/v1` API; the hosted MCP server is `https://api.promptguard.co/mcp`.
- **Security fixes:** The 12-month security-fix window for a previous major version, which [Versioning & support](https://docs.promptguard.co/versioning-and-support#sdks) promises, covers the Python and Node.js SDKs, not the plugin: security fixes ship in a new release, so stay on the latest one.

The full policy: [Versioning & support](https://docs.promptguard.co/versioning-and-support).

## Links

- [Documentation](https://docs.promptguard.co)
- [Dashboard](https://app.promptguard.co)
- [CLI](https://github.com/promptguardhq/promptguard-cli)
- [Python SDK](https://github.com/promptguardhq/promptguard-python)
- [Node.js SDK](https://github.com/promptguardhq/promptguard-node)
- [Website](https://promptguard.co)
