# The plugin registers an existing MCP server rather than shipping one

**Amended 2026-11-04 (1.5.0), renamed 2026-11-09** (was
`0001-registers-the-cli-mcp-server.md`, a name the amendment made untrue): the plugin now registers PromptGuard's hosted
MCP server, not the CLI's. The reasoning against shipping a server in this
repo still holds; what changed is which existing server the plugin points at.
See [Amendment](#amendment-2026-11-04-the-plugin-registers-the-hosted-server)
at the end.

Every MCP tool this plugin advertises, scanning text, scanning a project,
redacting PII, auth, status, is implemented in the PromptGuard CLI. What lives
here is a few lines naming the command a host should run
(`promptguard mcp -t stdio`). This repo contains no server, makes no HTTP
request, and has no build step or runtime.

The alternative was a small MCP server in this repo, which would have removed
the plugin's dependency on a separate binary being installed and on `PATH`.
That dependency is a genuine cost: the plugin is inert until the CLI is
installed, and the failure mode, tools silently absent from the host, is one
the plugin cannot report on. It was still the wrong trade. A server here would
be a second implementation of scanning, credential resolution and proxy
handling, in a repo whose entire premise is that it holds no executable code,
and it would drift from the CLI exactly the way every duplicated surface in
this project has drifted before.

## Consequences

"Install the plugin" is two steps, not one, and the README's prerequisites
section is load-bearing rather than boilerplate.

The MCP tool table in the README is a copy of what the CLI exposes, and nothing
checks it. When the CLI adds, removes or renames a tool, that table is wrong
until a person notices, the same class of unchecked-prose risk that the API
reference carries, and the reason this repo's rule is that concrete values are
verified against their source at the time they are written.

## Amendment 2026-11-04: the plugin registers the hosted server

From 1.5.0, `mcp.json` and `.mcp.json` register PromptGuard's hosted MCP server
at `https://api.promptguard.co/mcp` (`"type": "http"`) instead of
`promptguard mcp -t stdio`. The CLI's server is still supported, as an optional
second server the user adds by hand (the README's "Add the local server too").

**Why.** Two hosts the plugin is meant for cannot use a registration whose
command is a binary on `PATH`:

- Anthropic's plugin directory holds for a reviewer any local MCP server that
  is not started by running a file inside the plugin ("MCP server command
  wasn't read", [pre-submission checklist](https://claude.com/docs/plugins/pre-submission-checklist)).
  A bare `promptguard` is not a file in the plugin.
- claude.ai Chat ignores local MCP servers, so there the plugin had no tools
  at all.
- Codex's public plugin directory asks for the remote HTTPS endpoint
  ([Codex: build plugins](https://developers.openai.com/codex/plugins/build)).

The hosted server already exists and is maintained in the platform repo
(`backend/api/chatgpt/mcp_server.py`, mounted at `/mcp` in
`backend/api/main.py`), so pointing at it adds no second implementation, which
was the objection to shipping one here. It signs users in with OAuth, so the
plugin needs no API key and no `userConfig`.

**What it costs.** The hosted server does not have every CLI tool.
`promptguard_scan_project` reads the user's disk and `promptguard_auth` /
`promptguard_logout` manage the CLI's local credentials, so those three stay
CLI-only. The hosted server has `promptguard_scan_text`, `promptguard_redact`
and `promptguard_status`, which need a PromptGuard sign-in, and
`promptguard_scan_code`, which does not. It also means every tool call sends
its input to `api.promptguard.co`, which the README now says in "What this
plugin sends where".

**Consequences.** "Install the plugin" is one step: no CLI is needed for
the MCP tools. The README's tool tables are now two copies (hosted and local),
each citing its source, and neither is checked by anything. The CLI's server
is registered as `promptguard-local` in the README so it can sit beside the
plugin's `promptguard` without a name clash.
