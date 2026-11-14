#!/usr/bin/env bash
# Publish the `directory` branch: plugins/promptguard/ as a branch of its own,
# with the plugin at its root. Claude's plugin directory reads that branch.
#
#   scripts/publish-directory-branch.sh [ref]     # default HEAD
#
# ADR 0005: the directory refuses a version that holds scripts or tooling from
# an unverified organization, and a submission's plugin path cannot change, so
# the submission tracks this branch instead of main. `git subtree split` is
# deterministic, so each run fast-forwards the branch. The release workflow
# runs this on every v* tag; run it by hand only to repair the branch.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
ref="${1:-HEAD}"
sha=$(git subtree split --prefix=plugins/promptguard "$ref")
git push origin "$sha:refs/heads/directory"
echo "directory branch is now $sha (plugins/promptguard at $ref)"
