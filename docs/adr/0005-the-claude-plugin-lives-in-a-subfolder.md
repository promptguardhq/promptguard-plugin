# The Claude Code plugin lives in a subfolder that holds only content

Claude's plugin directory scans the folder a plugin is submitted from and, for
an organization it has not verified, refuses a version that holds any file
other than Markdown, text, JSON, YAML or a PNG, JPEG, GIF, WebP or ICO image,
any file starting with `#!`, a `.claude/` folder, or anything in
`.claude-plugin/` but the manifest. It refused 1.5.0 and 1.6.0 for the check
scripts, the git hook, `.claude/settings.json` and the SVG logo at the
repository root, all of which the repository needs. Its own advice for that
case is to put the plugin in a subfolder and submit that folder.

So the Claude Code plugin is `plugins/promptguard/`: its manifest, its
`.mcp.json`, a PNG icon, and the skills and reviewer. The root
`.claude-plugin/marketplace.json` lists it with `source: ./plugins/promptguard`,
so `/plugin install promptguard --marketplace promptguardhq/promptguard-plugin`
keeps working. The Cursor and Codex manifests stay at the root, where those
hosts look, and point at the same skills and reviewer through their `skills`
and `agents` path fields, so there is one copy of each.

Removing the tooling instead was rejected: the gate (`scripts/check.sh`), the
pre-push hook and the OpenAI package builder are what keep three hosts'
manifests in step. Copying the skills into a second folder was rejected for
the reason ADR 0002 gives in reverse: a copy is only safe with a check that
it has not drifted, and pointing at one folder needs no check at all.

## Consequences

Anything executable, and any file type outside the list above, goes outside
`plugins/promptguard/`. `scripts/check.sh` fails if one lands inside it, and
runs `claude plugin validate --strict` on the folder as well as on the root.
The directory submission's source path must name `plugins/promptguard`.
`plugins/promptguard/.mcp.json` is a third byte-identical copy of the MCP
registration (ADR 0002). `assets/logo.png` there is rendered from
`assets/logo.svg`; re-render it when the logo changes.
