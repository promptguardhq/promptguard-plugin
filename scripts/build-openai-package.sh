#!/usr/bin/env bash
# Build the ZIP that the OpenAI Platform's Plugins dashboard takes, for
# ChatGPT's directory and Codex.
#
#   scripts/build-openai-package.sh <demo-recording-url> [out.zip]
#
# The package is the portable Agent Plugins layout (plugin.json, mcp.json,
# skills/, assets/ at the root) with OpenAI's listing and review metadata under
# extensions.com.openai. Its sources are openai/plugin.json and openai/mcp.json;
# skills and the logo come from this repo so they never drift from what the
# other marketplaces ship. Reviewer credentials never go in the ZIP: OpenAI
# rejects them there, and they are entered in the dashboard's Review details.
set -euo pipefail

demo_url="${1:-}"
out="${2:-dist/promptguard-openai-plugin.zip}"
root="$(cd "$(dirname "$0")/.." && pwd)"

case "$demo_url" in
  https://*) ;;
  *)
    echo "usage: $0 <https demo-recording-url> [out.zip]" >&2
    echo "OpenAI requires a reviewer-accessible demo recording URL for MCP review." >&2
    exit 2
    ;;
esac

stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT

python3 - "$root/openai/plugin.json" "$stage/plugin.json" "$demo_url" <<'EOF'
import json, sys
src, dst, demo = sys.argv[1:4]
manifest = json.load(open(src))
manifest["extensions"]["com.openai"]["review"]["demo_recording_url"] = demo
version = json.load(open(src.replace("openai/plugin.json", ".claude-plugin/plugin.json")))["version"]
manifest["version"] = version
json.dump(manifest, open(dst, "w"), indent=2)
EOF
cp "$root/openai/mcp.json" "$stage/mcp.json"
cp -R "$root/skills" "$stage/skills"
mkdir -p "$stage/assets"
cp "$root/assets/logo.svg" "$stage/assets/logo.svg"

mkdir -p "$(dirname "$out")"
rm -f "$out"
(cd "$stage" && zip -qr - plugin.json mcp.json skills assets) > "$out"
echo "built $out ($(wc -c < "$out" | tr -d ' ') bytes, version $(python3 -c "import json;print(json.load(open('$stage/plugin.json'))['version'])"))"
