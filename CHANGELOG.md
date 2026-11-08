# Changelog

Product updates for every PromptGuard product, written for customers, are at [docs.promptguard.co/changelog](https://docs.promptguard.co/changelog); how long each version is supported is at [Versioning & support](https://docs.promptguard.co/versioning-and-support).

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

`Unreleased` holds work that is merged but not yet published. Move entries into
a dated version section when a release goes out, an `Unreleased` block that
survives three releases is a changelog nobody is maintaining.

## [Unreleased]

### Added

- **A package for ChatGPT and Codex.** `scripts/build-openai-package.sh`
  builds the ZIP the OpenAI Platform's Plugins dashboard takes: the hosted
  server, the skills, the logo, the listing text and the review cases, from
  `openai/plugin.json` and `openai/mcp.json`. The Codex manifest also names a
  support link and the logo.

### Fixed

- **The logo shows on dark backgrounds.** It was a black shield on a
  transparent ground, so directories in a dark theme (Claude's settings, for
  one) showed an almost empty tile. It now sits on a white rounded tile and
  reads the same on light and dark.

## [1.5.0] - 2026-11-05

### Added

- **Install from a marketplace in one line.** The repository is now its own
  Claude Code marketplace (`.claude-plugin/marketplace.json`), so
  `/plugin install promptguard --marketplace promptguardhq/promptguard-plugin`
  replaces `claude --plugin-dir /path/to/promptguard-plugin`. The Claude Code
  manifest carries the directory listing fields (icon, documentation, support,
  privacy and terms links) a submission to Anthropic's directory reads.
  `claude plugin validate . --strict` passes, and the pre-push hook runs it.
- **The skills install on their own** with `npx skills add
  promptguardhq/promptguard-plugin`, into any agent that CLI supports.

- **The README says what the plugin sends where**: which tools send text or
  code to `api.promptguard.co`, that sign-in goes through Auth0, that skills,
  rules and the reviewer send nothing themselves, and what the optional local
  server sends.

### Changed

- **The plugin's MCP server is PromptGuard's hosted server, so the plugin no
  longer needs the PromptGuard CLI.** `mcp.json` and `.mcp.json` register
  `https://api.promptguard.co/mcp` (`"type": "http"`) instead of
  `promptguard mcp -t stdio`. It signs you in to PromptGuard with OAuth when a
  tool needs an account, so there is no API key to configure. Its tools are
  `promptguard_scan_text`, `promptguard_redact` and `promptguard_status`
  (sign-in) and `promptguard_scan_code` (no sign-in). The CLI's local server,
  which alone has `promptguard_scan_project`, `promptguard_auth` and
  `promptguard_logout`, is now an optional second server the README shows how
  to add as `promptguard-local`. A local server whose command is a binary on
  `PATH` is held in Anthropic's directory review and ignored by claude.ai Chat,
  and Codex's public directory asks for a remote endpoint; ADR 0001 is amended
  with the reasoning. The plugin's version is 1.5.0, the same in all three
  manifests. Codex reads the same `.mcp.json` through its manifest's
  `mcpServers`, and Cursor reads `mcp.json`; both accept `"type": "http"`.
- **`promptguard-scan` and `promptguard-secure` are skills now, not
  commands** (`skills/promptguard-scan/`, `skills/promptguard-secure/`), as
  Claude Code recommends for new plugins; `commands/` is gone. In Claude Code
  they run as `/promptguard:promptguard-scan` and
  `/promptguard:promptguard-secure`, as before, and they can now also start
  on their own when a request matches. Cursor plugins load `skills/` too, so
  Cursor keeps both, and `npx skills add` now installs four skills.
  `promptguard-scan` says which MCP tools can help and that
  `promptguard_scan_project` needs the local server.
- **The Cursor rules no longer load everywhere.** `secure-llm-usage` was
  always on, in every chat; it now attaches when a Python or
  JavaScript/TypeScript source file is in context. `llm-security-review`
  said "invoke manually" but matched every file (`globs: "**/*"`); it is now
  applied when the agent judges a review relevant, or when you @-mention it.
- The Claude Code manifest drops `"skills": "./skills/"` and
  `"mcpServers": "./.mcp.json"`, which only repeated what Claude Code loads by
  default; the installed plugin's skills, reviewer and MCP server are
  unchanged.
- **The plugin no longer replaces Claude Code's main agent.** The root
  `settings.json` that made `llm-security-reviewer` the main agent of every
  session is gone; the reviewer is the `promptguard:llm-security-reviewer`
  subagent (`docs/adr/0004-the-plugin-does-not-take-over-the-main-agent.md`).
- The README no longer tells Cursor users to search for a plugin listing that
  does not exist yet, and says how to install the plugin locally until it does.

## [1.4.2] - 2026-11-03

### Added

- **Every published release is announced in Slack `#releases`.** A new
  workflow, `.github/workflows/release.yml`, runs when a GitHub Release is
  published and posts its tag and notes link through
  `scripts/post-release.sh`, a copy of the platform repo's script. It reads
  the `SLACK_RELEASES_WEBHOOK_URL` secret, and an unset secret or a Slack
  failure is a warning, never a failed release. Releases are still cut by
  hand.

### Changed

- **The README says that, in Claude Code, the plugin makes
  `llm-security-reviewer` the main agent of every session while it is
  enabled**, and gives the two ways out: an MCP-only install, or a user-level
  agent setting, which outranks plugin defaults. Plugin behaviour is
  unchanged (#9).
- README setup fixes (#9): the sample `.promptguard.json` no longer fails the
  CLI and no longer suggests `project_id` (requests are attributed to the
  key's project); Codex MCP servers are configured in `~/.codex/config.toml`
  or with `codex mcp add`, not a `.codex/mcp.json`; the Cursor deeplink
  installs the MCP server only.
- The README has a Versioning and support section.
- The three manifests' `repository` points at
  `github.com/promptguardhq/promptguard-plugin`, where the repository now lives.

## [1.4.1] - 2026-10-23

### Changed

- The README's CLI install steps no longer offer a Homebrew tap or a
  crates.io crate, neither of which exists. They give the install script, the
  release binaries, and a link to the CLI's own installation table.
- `SECURITY.md` links to the published disclosure policy
  (https://promptguard.co/security#reporting-a-vulnerability) instead of
  keeping its own copy of the response times.

## [1.4.0] - 2026-09-06

The plugin ships instructions, so a wrong reference is a defect in the product
rather than in its documentation, an agent reading these files acts on them.

### Fixed

- **The API reference stated rate limits that were wrong**, and repeated a
  stale claim that `pii_types` does nothing. Both were being read as fact by
  any agent following this skill.
- **The threat-type list was incomplete and described as exact.** All 37 are
  now listed, and the list no longer claims to be exhaustive in a way that
  invites an agent to reject a value the API legitimately returns. This
  continues the correction started in 1.3.1, which removed four threat types
  that do not exist.

### Added

- A domain glossary, and the first two ADRs: why the plugin registers the CLI's
  MCP server rather than shipping one of its own, and why the duplicate MCP
  registration files exist.

### Changed

- Secrets are scanned in CI rather than only by a local hook, the pre-push gate
  is tracked in the repository instead of living on one machine, and the last
  unpinned GitHub Action is pinned.

## [1.3.1] - 2026-08-11

### Fixed

- **The API reference documented threat-type values that do not exist.** It
  listed `injection`, `jailbreak`, `pii` and `exfiltration`; the API returns
  `prompt_injection`, `pii_leak` and `data_exfiltration`. Anyone who followed
  this reference and matched on those strings was matching on nothing, and the
  branch never fired. The values are now the API's own, with a note that they
  are `snake_case` and several read differently from the plain-English name of
  the attack.


No user-facing changes yet since this changelog was introduced.

