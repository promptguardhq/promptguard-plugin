#!/usr/bin/env bash
# The whole local gate, and exactly what CI's `validate` job runs: CI calls this
# script, so the two cannot drift. Run it before you hand back a change.
#
#   bash scripts/check.sh
#
# Locally it also runs `claude plugin validate . --strict` when Claude Code is
# on PATH (CI does not install it); set PROMPTGUARD_CI=1 to skip that step.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

step() { printf '  %s\n' "$*"; }

step "GitHub holds no secrets"
python3 scripts/check_no_github_secrets.py --check

step "Agent files load and resolve; no em or en dashes"
python3 scripts/check_agent_files.py --check
python3 scripts/check_no_dashes.py --check

step "Every tracked JSON file parses"
while IFS= read -r f; do
  python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" || {
    echo "check: $f is not valid JSON" >&2
    exit 1
  }
done < <(git ls-files '*.json')

step "Required files exist"
for f in mcp.json .mcp.json .cursor-plugin/plugin.json .claude-plugin/plugin.json \
  .claude-plugin/marketplace.json .codex-plugin/plugin.json \
  rules/secure-llm-usage.mdc rules/llm-security-review.mdc \
  skills/secure-llm-integration/SKILL.md skills/promptguard-api/SKILL.md \
  skills/promptguard-scan/SKILL.md skills/promptguard-secure/SKILL.md \
  agents/llm-security-reviewer.md AGENTS.md; do
  test -f "$f" || { echo "check: required file $f is missing" >&2; exit 1; }
done

step "Plugin manifests share one version"
# Drift between manifests is a common bug: a publish that bumps one and
# forgets the others.
v_cursor=$(python3 -c "import json; print(json.load(open('.cursor-plugin/plugin.json'))['version'])")
v_claude=$(python3 -c "import json; print(json.load(open('.claude-plugin/plugin.json'))['version'])")
v_codex=$(python3 -c "import json; print(json.load(open('.codex-plugin/plugin.json'))['version'])")
if [ "$v_cursor" != "$v_claude" ] || [ "$v_cursor" != "$v_codex" ]; then
  echo "check: manifest versions differ (cursor=$v_cursor claude=$v_claude codex=$v_codex). Bump all three together." >&2
  exit 1
fi

step "mcp.json and .mcp.json are byte-identical"
# Different agent ecosystems read each; drift silently breaks one of them.
diff -u mcp.json .mcp.json

step "Hand-verified API facts are re-verified within 120 days"
# ADR-0003: these values are checked by hand against the backend, so the
# only drift signal is the date each note says it was checked. Re-verify the
# values against the backend file each note names, then move its date.
python3 - <<'PY'
import datetime as dt, re, sys
path = "skills/promptguard-api/references/api-reference.md"
text = open(path, encoding="utf-8").read()
dates = re.findall(r"[Vv]erified against[^.]*?on\s+(\d{4}-\d{2}-\d{2})", text, re.S)
if not dates:
    sys.exit(f"check: {path} has no 'verified against ... on YYYY-MM-DD' note")
today = dt.date.today()
stale = [d for d in dates if (today - dt.date.fromisoformat(d)).days > 120]
if stale:
    sys.exit(f"check: {path} has facts last verified {', '.join(sorted(set(stale)))}, over 120 days ago. "
             "Re-check each against the backend file its note names and update the date.")
PY

if [ -z "${PROMPTGUARD_CI:-}" ]; then
  # Claude Code's own validator is the authority on marketplace.json and the
  # Claude Code manifest.
  if command -v claude >/dev/null 2>&1; then
    step "claude plugin validate . --strict"
    claude plugin validate . --strict >/dev/null || {
      echo "check: 'claude plugin validate . --strict' failed; run it to see why." >&2
      exit 1
    }
  else
    step "claude not on PATH: marketplace.json was not validated"
  fi
fi

echo "check: all passed"
