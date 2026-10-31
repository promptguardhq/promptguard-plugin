[![CI](https://github.com/promptguardhq/promptguard-plugin/actions/workflows/ci.yml/badge.svg)](https://github.com/promptguardhq/promptguard-plugin/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/promptguardhq/promptguard-plugin)](https://github.com/promptguardhq/promptguard-plugin/blob/main/LICENSE)

# PromptGuard Agent Skills

LLM security for AI coding agents — protect applications from prompt injection, PII leakage, and data exfiltration. Works with **Cursor, Claude Code, Codex, Copilot, Gemini CLI, Windsurf, VSCode**, and any MCP-compatible agent.

## Installing the MCP Server

PromptGuard ships a native MCP server built into the CLI. Install the CLI first, then add the MCP server to your agent.

### Prerequisites

- **PromptGuard CLI**:
  - macOS/Linux: `curl -fsSL https://raw.githubusercontent.com/promptguardhq/promptguard-cli/main/install.sh | sh`
  - Windows, or any platform: download the binary from [GitHub Releases](https://github.com/promptguardhq/promptguard-cli/releases/latest)
  - Every method, including building from source: [the CLI's installation table](https://github.com/promptguardhq/promptguard-cli#installation)
- **PromptGuard account** — sign up at [promptguard.co](https://promptguard.co)
- **API key** — get one from [app.promptguard.co/settings/api-keys](https://app.promptguard.co/settings/api-keys)

### Per-agent setup

<details>
<summary>Install in <b>Cursor</b></summary>
<br />

**One-click install** (opens Cursor and adds the MCP server only; the plugin's rules, commands and agent are a separate install, below):

[Install PromptGuard in Cursor](cursor://anysphere.cursor-deeplink/mcp/install?name=promptguard&config=eyJjb21tYW5kIjoicHJvbXB0Z3VhcmQiLCJhcmdzIjpbIm1jcCIsIi10Iiwic3RkaW8iXX0=)

Or add to `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "promptguard": {
      "command": "promptguard",
      "args": ["mcp", "-t", "stdio"]
    }
  }
}
```

Cursor also supports the plugin's rules, commands, and agent — install via Settings > Plugins > search "promptguard".

</details>

<details>
<summary>Install in <b>Claude Code</b></summary>
<br />

**One-line MCP install** (fastest — registers the MCP server via the Claude CLI):

```bash
claude mcp add promptguard -- promptguard mcp -t stdio
```

**As a plugin** (includes skills, agents, and the MCP server):

```bash
claude --plugin-dir /path/to/promptguard-plugin
```

> **The plugin replaces Claude Code's main agent.** Its `settings.json` sets
> `"agent": "llm-security-reviewer"`, so while the plugin is enabled every
> Claude Code session runs as the LLM Security Reviewer: that agent's system
> prompt applies to the whole conversation, not only to security reviews. If
> you want the MCP tools without this, use the one-line MCP install above
> instead of the plugin. To keep the plugin but choose your own main agent, set
> `agent` in `~/.claude/settings.json`; your own settings take precedence over
> a plugin's defaults.

To submit to the official Claude Code marketplace: [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit)

</details>

<details>
<summary>Install in <b>VSCode / Copilot</b></summary>
<br />

Add to your `.vscode/mcp.json`:

```json
{
  "servers": {
    "promptguard": {
      "command": "promptguard",
      "args": ["mcp", "-t", "stdio"]
    }
  }
}
```

</details>

<details>
<summary>Install in <b>Windsurf</b></summary>
<br />

Add to `~/.codeium/windsurf/mcp_config.json`:

```json
{
  "mcpServers": {
    "promptguard": {
      "command": "promptguard",
      "args": ["mcp", "-t", "stdio"]
    }
  }
}
```

</details>

<details>
<summary>Install in <b>Codex</b></summary>
<br />

**As a plugin** (includes skills and MCP server):

Copy to your repo plugins directory and register in your marketplace:

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

Or add the MCP server on its own. Codex reads MCP servers from
`~/.codex/config.toml` (or `.codex/config.toml` in a trusted project), so either
run:

```bash
codex mcp add promptguard -- promptguard mcp -t stdio
```

or add the table yourself:

```toml
[mcp_servers.promptguard]
command = "promptguard"
args = ["mcp", "-t", "stdio"]
```

</details>

<details>
<summary>Install in <b>Gemini CLI</b></summary>
<br />

Add to `~/.gemini/settings.json`:

```json
{
  "mcpServers": {
    "promptguard": {
      "command": "promptguard",
      "args": ["mcp", "-t", "stdio"]
    }
  }
}
```

</details>

<details>
<summary>Install in <b>any other MCP client</b></summary>
<br />

Run the MCP server via stdio:

```bash
promptguard mcp -t stdio
```

Configure your MCP client to spawn `promptguard mcp -t stdio` as a subprocess.

</details>

## MCP Tools

When connected, the agent can call these tools directly:

| Tool | Description |
|------|-------------|
| `promptguard_auth` | Authenticate with PromptGuard. Opens the dashboard to copy an API key. |
| `promptguard_logout` | Remove locally stored credentials. |
| `promptguard_scan_text` | Scan text for prompt injection, jailbreaks, PII leakage, and toxicity. |
| `promptguard_scan_project` | Scan a project directory for unprotected LLM SDK usage. |
| `promptguard_redact` | Redact PII (emails, phones, SSNs, credit cards, API keys) from text. |
| `promptguard_status` | Show current configuration, active providers, and key type. |

## What's included

Beyond the MCP server, this repo includes agent skills and workflows:

| Component | Description |
|-----------|-------------|
| **Skills** | **Secure LLM Integration** — walks through adding PromptGuard to any project. **PromptGuard API** — teaches the agent exact request/response schemas for scan, redact, and guard endpoints. |
| **Commands** | `/promptguard-scan` finds unprotected LLM calls and hardcoded secrets. `/promptguard-secure` adds PromptGuard to a project end-to-end. |
| **Agent** | LLM Security Reviewer — specialized code reviewer for prompt injection, PII leakage, agent tool abuse, and other LLM-specific vulnerabilities. |
| **Rules** | Always-on guidance ensuring the agent writes secure LLM code when using OpenAI, Anthropic, or any supported provider. |

These components work natively in Cursor and Claude Code (via their plugin systems). In Claude Code the agent also becomes the session's main agent; see the note under [Claude Code](#per-agent-setup). For other agents, the skills and agent definitions use standard `SKILL.md` format compatible with Claude Code, Codex, and any agent that reads markdown skill files.

## Project attribution

Every request is attributed to the project the API key belongs to. There is no
per-request project setting: to attribute MCP traffic to a different project,
create an API key in that project (in the dashboard, under the project's API
keys) and give that key to the MCP server, for example with
`promptguard login` or the `PROMPTGUARD_API_KEY` environment variable.

## Supported LLM providers

OpenAI, Anthropic, Google Generative AI (Gemini), Cohere, AWS Bedrock, LangChain, CrewAI, LlamaIndex, Vercel AI SDK.

## Versioning and support

- **Versions** follow [semantic versioning](https://semver.org), with the same
  version in the Claude Code, Cursor and Codex manifests, and every change is
  in [`CHANGELOG.md`](./CHANGELOG.md).
- **Requirements:** the PromptGuard CLI on your `PATH`, on any platform it
  ships for: the MCP server is `promptguard mcp` (see
  [Prerequisites](#prerequisites)).
- **API version:** the MCP server and the skills use PromptGuard's `/api/v1`
  API.
- **Security fixes:** The 12-month security-fix window for a previous major version, which [Versioning & support](https://docs.promptguard.co/versioning-and-support#sdks) promises, covers the Python and Node.js SDKs, not the plugin: security fixes ship in a new release, so stay on the latest one.

The full policy: [Versioning & support](https://docs.promptguard.co/versioning-and-support).

## Links

- [Documentation](https://docs.promptguard.co)
- [Dashboard](https://app.promptguard.co)
- [CLI](https://github.com/promptguardhq/promptguard-cli)
- [Python SDK](https://github.com/promptguardhq/promptguard-python)
- [Node.js SDK](https://github.com/promptguardhq/promptguard-node)
- [Website](https://promptguard.co)
