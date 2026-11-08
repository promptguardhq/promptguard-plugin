# AGENTS.md

| Owner | Last reviewed |
|---|---|
| @cto | 2026-11-09 |

## Overview

The PromptGuard plugin: rules, skills, a reviewer definition and an MCP
registration that hosts (Cursor, Claude Code, Codex and other MCP-compatible
assistants) load. It **configures** a security capability; PromptGuard's hosted
MCP server at `https://api.promptguard.co/mcp` **provides** it (see
`docs/adr/0001-registers-an-existing-mcp-server.md`, amended 2026-11-04). The CLI's
local server (`promptguard mcp -t stdio`) is an optional extra the README
documents, not something the plugin registers.

Static Markdown and JSON, no build step. Each host loads its own manifest
(`.cursor-plugin/`, `.claude-plugin/`, `.codex-plugin/`), and the three must
carry the same `version`. `mcp.json` and `.mcp.json` stay byte-identical on
purpose (`docs/adr/0002-duplicate-mcp-registration-files.md`): edit both together.

## Every API value is verified against the backend

Everything here is prose an LLM reads as authoritative, and almost nothing
checks it: `scripts/check.sh` fails only on a stale "verified against ... on"
date, and the platform repo's tests pin the threat-type table.
Any concrete API value you write, a threat type, a PII entity name, a plan
limit, an endpoint path, is checked against the backend at the time it is
written, and the backend file it came from is named next to it. Threat types,
for example, are the `ThreatType` enum in `backend/api/shared/security/engine.py`;
the published OpenAPI spec types `threatType` as a bare string. A wrong value
fails no build; it teaches an agent something false about a security product.

Before adding generation, sync workflows or anything else that automates these
values, read `docs/adr/0003-api-facts-are-hand-verified-not-generated.md`: it
records why there is none, the incident behind the rule, and when to revisit.

## Development

**Enable the tracked git hooks once per clone.** Git will not turn on a repo's
own hooks for you:

```bash
git config core.hooksPath .githooks
```

**Before you hand back a change, run `bash scripts/check.sh`.** It is the
whole gate and exactly what CI's `validate` job runs. `.githooks/pre-push` runs
it too, after a gitleaks scan of the commits you are pushing (a missing gitleaks
fails the push). The scan is scoped to the
pushed range on purpose, a scan of the whole tree or of history would fail on
its first run and teach everyone `--no-verify`.

To test a change by hand in a host, follow the Testing section of
`CONTRIBUTING.md`. The hosted MCP tools that need an account appear signed out
until you sign in to PromptGuard.

## Conventions

- Rules use `.mdc` (Cursor rule syntax); every other host reads the same files.
- Skills use the `SKILL.md` format with clear trigger conditions.
- Text and SVG only; keep binaries and large assets out of the repo.

## This repo is public

Write only what a stranger may read. A credential that reaches `main` is
world-readable at once and must be rotated, not reverted: commit no API keys,
tokens or credentials, and no infrastructure details, private repository
URLs, or local machine paths. A backend source path such as
`backend/api/shared/security/engine.py` is the one exception: it is how an API
value cites its source (above), and it names a file, not where to reach it. Give a secret-shaped test fixture an obviously fake
shape, or exempt its path in `.gitleaks.toml` so the exemption is reviewable;
never bypass the hook for it.

## GitHub holds no secrets

**Change a secret in Secret Manager; GitHub holds none.** Workflows read every
secret at run time from Google Secret Manager (`promptguard-production-472014`),
signed in as this repository through Workload Identity; GitHub keeps only
identifiers, as variables (`vars.*`). A workflow that names any `secrets.*` but
`GITHUB_TOKEN` fails CI (`scripts/check_no_github_secrets.py`). The inventory,
and how to add a secret with its per-secret grant:
[`ENVIRONMENT_VARIABLES.md` § CI/CD-only](https://github.com/promptguardhq/promptguard/blob/main/docs/04_engineering/reference/ENVIRONMENT_VARIABLES.md#cicd-only)
in the platform repo.

`.claude/settings.json` (committed) denies Claude Code reads of real `.env` files. It also turns on Claude Code's sandbox for Bash: network only to the hosts in `sandbox.network.allowedDomains`, writes only to the workspace and tool caches; a host a command needs that is not listed shows as a sandbox prompt, so add it there with the reason. Machine-only permissions go in `.claude/settings.local.json`.

## Agent skills

### Issue tracker

Issues live in this repo's GitHub Issues, worked via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical triage roles, each label string equal to its name. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` plus `docs/adr/` at the repo root; add to them as terms and decisions settle. See `docs/agents/domain.md`.
