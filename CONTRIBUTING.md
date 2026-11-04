# Contributing to the PromptGuard Plugin

## Overview

This repository is a multi-agent plugin -- a collection of static configuration files that AI coding agents (Cursor, Claude Code, Codex, Copilot, Gemini CLI, Windsurf, VSCode, and any MCP-compatible client) load to provide PromptGuard capabilities. There is no build step, no compiled code, and no test suite.

Each agent reads a different manifest: `.cursor-plugin/plugin.json` (Cursor), `.claude-plugin/plugin.json` (Claude Code), and `.codex-plugin/plugin.json` (Codex). Keep them in sync when changing shared metadata (name, version, description).

## Prerequisites

| Tool | Version |
|------|---------|
| Cursor | latest |
| PromptGuard account | [promptguard.co](https://promptguard.co), to sign in to the hosted MCP server |
| PromptGuard CLI (optional) | latest, only to test the optional local server ([install](https://github.com/promptguardhq/promptguard-cli#installation)) |

## Plugin Structure

```
.cursor-plugin/plugin.json  # Cursor manifest (name, version, description, logo)
.claude-plugin/plugin.json  # Claude Code manifest (metadata and directory listing links; skills/ and .mcp.json load by default)
.claude-plugin/marketplace.json  # makes this repo its own Claude Code marketplace (one plugin, source ./)
.codex-plugin/plugin.json   # Codex manifest (adds skills + mcpServers + interface)

rules/
  secure-llm-usage.mdc      # Auto-attached on Python/JS/TS source: guides the agent to use PromptGuard
  llm-security-review.mdc   # Agent-requested or @-mentioned security review checklist

skills/
  secure-llm-integration/
    SKILL.md                # Step-by-step integration playbook
    references/
      threat-model.md       # LLM threat model reference
  promptguard-api/
    SKILL.md                # API usage skill
    references/
      api-reference.md      # Threat types, PII entities, plan limits (hand-verified, see ADR 0003)
  promptguard-scan/
    SKILL.md                # Scan a project for unprotected LLM calls and secrets
  promptguard-secure/
    SKILL.md                # Add PromptGuard to a project end-to-end

agents/
  llm-security-reviewer.md  # LLM Security Reviewer agent definition

mcp.json, .mcp.json         # MCP server registration (hosted https://api.promptguard.co/mcp); byte-identical, see ADR 0002
assets/logo.svg             # Logo referenced by the manifests

.githooks/pre-push          # Secret scan + manifest validation (enable: git config core.hooksPath .githooks)
docs/adr/                   # Architecture decisions
CONTEXT.md                  # Domain glossary
```

### Key Components

| Component | File(s) | Purpose |
|---|---|---|
| **Plugin manifest** | `.cursor-plugin/plugin.json` | Metadata: name, version, description, logo |
| **Rules** | `rules/*.mdc` | Cursor rules: guidance attached by file type, or by the agent when relevant |
| **Skills** | `skills/*/SKILL.md` | Playbooks the agent follows when a request matches, or that you invoke by name |
| **Agents** | `agents/*.md` | Specialized agent definitions |
| **MCP config** | `mcp.json`, `.mcp.json` | Registers PromptGuard's hosted MCP server |

## Development Workflow

### Making Changes

1. Edit the relevant `.md`, `.mdc`, or `.json` file
2. Test in Cursor (see below)
3. Commit and push to `main`

### Testing

Testing is manual. There is no automated test suite for Cursor plugins.

**To test locally:**

1. Install the plugin into the agent you are testing (e.g. clone/symlink into your Cursor plugins directory, run `claude --plugin-dir .` for Claude Code, or `claude plugin marketplace add .` then `claude plugin install promptguard@promptguard` to test the marketplace install, or register it in your Codex marketplace -- see the README's per-agent setup)
2. Restart the agent to pick up changes
3. Verify each component:

| Component | How to verify |
|---|---|
| **Rules** | Open a file with LLM imports (e.g., `import openai`). The agent should suggest PromptGuard when writing LLM code. |
| **Skills** | Ask the agent: "Add PromptGuard to this project". It should follow the skill playbook. Invoke `promptguard-scan` and `promptguard-secure` by name (`/promptguard:promptguard-scan` in Claude Code). |
| **MCP tools** | Open the MCP panel in your agent's settings. Verify the `promptguard` server (`https://api.promptguard.co/mcp`) is listed and its tools appear (`promptguard_scan_text`, `promptguard_redact`, `promptguard_status`, `promptguard_scan_code`); sign in when a tool asks. |
| **Agents** | Select the "LLM Security Reviewer" agent and ask it to review code. |

### MCP Server Testing

The MCP server is PromptGuard's hosted server, not part of this plugin. The plugin only registers it, in `mcp.json` / `.mcp.json` (and the `mcpServers` key in the Codex manifest). In Claude Code, `claude mcp list` shows `plugin:promptguard:promptguard: https://api.promptguard.co/mcp (HTTP)` with the plugin installed.

To test the optional local server the README documents:

```bash
promptguard mcp -t stdio        # Verify CLI MCP server starts
promptguard --version            # Verify CLI is installed
```

## CI/CD

CI runs on pushes to `main` and on PRs (`.github/workflows/ci.yml`, one `validate` job):

- every tracked `*.json` parses
- the required rule, skill, agent and manifest files exist
- the three plugin manifests carry the same `version`
- `mcp.json` and `.mcp.json` are byte-identical

Secret scanning (gitleaks) runs on every push and PR in `.github/workflows/secret-scan.yml`. The tracked `.githooks/pre-push` hook runs both locally; enable it once per clone with `git config core.hooksPath .githooks`. There is no Dependabot configuration.

## Publishing

Changes are published by pushing to the `main` branch. Agents pull plugin updates from the repository directly. There is no build, packaging, or registry publishing step.

To bump the plugin version, update `version` in all three manifests (`.cursor-plugin/plugin.json`, `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`) so they stay in sync.

A version is released by tagging it and publishing a GitHub Release whose notes are its `CHANGELOG.md` section (`gh release create vX.Y.Z --notes-file <section>`). Publishing it runs `.github/workflows/release.yml`, which announces it in Slack `#releases` through `scripts/post-release.sh` and the `SLACK_RELEASES_WEBHOOK_URL` secret; a failed post only warns.

## PR Checklist

- [ ] All three manifests are valid JSON and in sync: `.cursor-plugin/plugin.json`, `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`
- [ ] `claude plugin validate . --strict` passes (it checks `marketplace.json` and the Claude Code manifest together)
- [ ] `.mcp.json` and `mcp.json` are valid JSON
- [ ] Rules, skills, and agents render correctly in markdown
- [ ] Manually tested in Cursor **and** Claude Code **and** Codex (at minimum the MCP server connects and one skill runs in each)
- [ ] PR description explains the change

## Reporting Issues

Open an issue at https://github.com/promptguardhq/promptguard-plugin/issues with:

- Agent and version (e.g. Cursor, Claude Code, Codex)
- PromptGuard CLI version (`promptguard --version`)
- What you expected vs. what happened
- Screenshots if applicable
