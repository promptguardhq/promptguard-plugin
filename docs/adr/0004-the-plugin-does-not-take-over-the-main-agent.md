# The plugin does not take over Claude Code's main agent

Until 1.4.2 the plugin shipped a root `settings.json` with
`"agent": "llm-security-reviewer"`. Claude Code applies a plugin's `agent`
setting to the main thread, so every session in which the plugin was enabled
ran as the LLM Security Reviewer: its system prompt governed the whole
conversation, whatever the developer had opened Claude Code to do. 1.4.2
documented that as a caveat; it removes it instead.

A security plugin installs alongside everything else a developer uses. One that
silently changes how every session behaves is the kind a developer uninstalls
the first time it gets in the way, and the kind a marketplace reviewer is
right to question. The reviewer is still there as the
`promptguard:llm-security-reviewer` subagent, which Claude Code delegates to for
a security review or the user picks from `/agents`; the skills and the MCP
server carry the rest.

## Consequences

Do not add a `settings.json` with `agent`, or a `settings.agent` key in
`.claude-plugin/plugin.json`. A developer who wants the reviewer as their main
agent sets `"agent": "promptguard:llm-security-reviewer"` in their own
`~/.claude/settings.json`.
