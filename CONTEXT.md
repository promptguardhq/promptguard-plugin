# PromptGuard Plugin

The PromptGuard plugin for AI coding assistants. It ships no runnable code: it
is a package of instructions an assistant loads, rules, skills, a reviewer
definition, plus the registration that points the assistant at PromptGuard's
hosted MCP server.

The single most important distinction in this repo is that it **configures** a
security capability rather than **providing** one. Everything executable lives
elsewhere: the hosted MCP server in the platform, the optional local server in
the CLI.

## Language

### Who is being talked about

**Host**:
The AI coding assistant that loads this plugin, Cursor, Claude Code, Codex,
Copilot, Gemini CLI, Windsurf, VS Code.
_Avoid_: agent, editor, IDE, client. "Agent" is the word this repo has used for
this, and it is the worst available: it also names the reviewer below and the
customer's own software, so a sentence with "agent" in it usually needs
rereading to work out which of the three is meant.

**Reviewer**:
The specialised persona in `agents/`, which a host can delegate a security
review to.
_Avoid_: agent, subagent, persona, bot

**Protected application**:
The customer's software, whose LLM calls the plugin's advice is meant to
secure. It may itself be agentic, which is the third thing "agent" has meant
here.
_Avoid_: agent, app, target, user code

### What the plugin is made of

**Rule**:
Guidance in `rules/*.mdc` (Cursor's rule format) that the host attaches to
context by itself: when a matching file is in context, or when the host judges
the rule's description relevant. A person can also @-mention one.
_Avoid_: instruction, prompt, guideline, policy (a policy is a PromptGuard
guardrail, not a rule)

**Skill**:
A playbook the host follows when a request matches it, and the place a
decision between approaches is owned.
_Avoid_: workflow, guide, recipe

**Command**:
A skill meant to be invoked by name (`promptguard-scan`, `promptguard-secure`),
which does the recommended thing without asking the person to choose. Since
1.5.0 these are skills in `skills/`; there is no `commands/` directory.
_Avoid_: slash command (the leading slash is one host's spelling), action,
shortcut

**Plugin manifest**:
The per-host file declaring what this plugin is and which parts of it that host
should load. There is one per supported host and they carry the same version.
_Avoid_: config, plugin.json, package manifest

**MCP server registration**:
The file (`mcp.json`, `.mcp.json`) naming where a host gets PromptGuard's MCP
tools: the hosted server's URL. It registers a server; it does not contain one.
_Avoid_: MCP server (this repo has none), MCP config, mcp.json

**MCP tool**:
One callable the registered server exposes to the host. They are implemented by
the hosted server (or, for the optional local server, the CLI) and only listed
here.
_Avoid_: function, endpoint, API

### Terms that belong to other repos and must not be respelled here

**Auto-instrumentation**:
Adopting PromptGuard by calling `init()`, so an already-installed provider SDK
has its calls scanned without changing how they are made.

**Proxy mode**:
Adopting PromptGuard by using its drop-in client, so PromptGuard is in the
request path and forwards to the provider.
_Avoid_: HTTP proxy, proxy integration, the SDKs call this proxy mode, and a
second name for it in agent-facing prose is a second thing to keep true.

**Guard API**:
The endpoint that classifies content and returns a decision. Adopting
PromptGuard *through* it means calling the Guard client directly, which is a
third integration method, but the API and the method are not the same noun and
should not share one.
_Avoid_: scan API, security API

**Threat type**:
The classification carried by a blocking decision. The authoritative list is
the platform's `ThreatType` enum; any list written here is a copy that nothing
checks.
_Avoid_: threat category, attack type, vulnerability class
