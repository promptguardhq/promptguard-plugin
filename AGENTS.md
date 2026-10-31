# AGENTS.md

## Overview

The PromptGuard plugin: rules, skills, slash commands, a reviewer definition and
an MCP registration that hosts (Cursor, Claude Code, Codex and other
MCP-compatible assistants) load. It **configures** a security capability; the
PromptGuard CLI **provides** it (`promptguard mcp -t stdio`, see
`docs/adr/0001-registers-the-cli-mcp-server.md`).

Static Markdown and JSON, no build step. Each host loads its own manifest
(`.cursor-plugin/`, `.claude-plugin/`, `.codex-plugin/`), and the three must
carry the same `version`. `mcp.json` and `.mcp.json` stay byte-identical on
purpose (`docs/adr/0002-duplicate-mcp-registration-files.md`): edit both together.

## Every API value is verified against the backend

Everything here is prose an LLM reads as authoritative, and nothing checks it.
Any concrete API value you write — a threat type, a PII entity name, a plan
limit, an endpoint path — is checked against the backend at the time it is
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

`.githooks/pre-push` runs a gitleaks scan of the commits you are pushing and the
manifest validation that mirrors CI's `validate` job. The scan is scoped to the
pushed range on purpose — a scan of the whole tree or of history would fail on
its first run and teach everyone `--no-verify`.

To test a change by hand in a host, follow the Testing section of
`CONTRIBUTING.md`; the MCP tools appear only when the `promptguard` CLI is on
`PATH`.

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

## Agent skills

### Issue tracker

Issues live in this repo's GitHub Issues, worked via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical triage roles, each label string equal to its name. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` plus `docs/adr/` at the repo root; add to them as terms and decisions settle. See `docs/agents/domain.md`.
