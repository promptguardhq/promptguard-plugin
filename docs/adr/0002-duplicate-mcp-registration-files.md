# Two identical MCP registration files, kept identical by CI

`mcp.json` and `.mcp.json` have the same contents and both are committed. Host
ecosystems disagree about which name to look for, and the plugin has to satisfy
all of them, so the file exists under both names and CI runs
`diff -u mcp.json .mcp.json` to fail the build if they ever stop matching.

A symlink is the obvious way to avoid duplicating a file, and it was not used.
Symlinks do not survive every path a plugin takes to a user's machine, archive
extraction, Windows checkouts without developer mode, and tooling that copies
rather than clones all turn a link into either a broken entry or a text file
containing a path. A duplicate is inert everywhere, and the cost of duplication
is only that it can drift, which is the one failure a one-line CI check catches
completely.

## Consequences

This looks like exactly the kind of redundancy a tidying pass removes, so the
CI check is as much documentation as gate: deleting either file, or editing one
alone, fails immediately with a diff showing why.
