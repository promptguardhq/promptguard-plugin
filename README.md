# PromptGuard plugin for Claude

LLM security for AI coding agents: protect applications from prompt injection,
PII leakage and data exfiltration.

The plugin adds four skills (`promptguard-scan`, `promptguard-secure`,
`promptguard-api` and `secure-llm-integration`), the
`promptguard:llm-security-reviewer` subagent, and PromptGuard's hosted MCP
server at `https://api.promptguard.co/mcp`. The tools that need an account ask
you to sign in to PromptGuard the first time you use them.

Install it in Claude Code:

```
/plugin install promptguard --marketplace promptguardhq/promptguard-plugin
```

Source, the Cursor and Codex packaging, and the changelog:
[github.com/promptguardhq/promptguard-plugin](https://github.com/promptguardhq/promptguard-plugin).
Privacy: [promptguard.co/privacy](https://promptguard.co/privacy). Support:
[promptguard.co/contact](https://promptguard.co/contact).
