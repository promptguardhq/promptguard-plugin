# Changelog

Product updates for every PromptGuard product, written for customers, are at [docs.promptguard.co/changelog](https://docs.promptguard.co/changelog); how long each version is supported is at [Versioning & support](https://docs.promptguard.co/versioning-and-support).

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

`Unreleased` holds work that is merged but not yet published. Move entries into
a dated version section when a release goes out — an `Unreleased` block that
survives three releases is a changelog nobody is maintaining.

## [Unreleased]

### Added

- **Every published release is announced in Slack `#releases`.** A new
  workflow, `.github/workflows/release.yml`, runs when a GitHub Release is
  published and posts its tag and notes link through
  `scripts/post-release.sh`, a copy of the platform repo's script. It reads
  the `SLACK_RELEASES_WEBHOOK_URL` secret, and an unset secret or a Slack
  failure is a warning, never a failed release. Releases are still cut by
  hand.

## [1.4.1] — 2026-10-23

### Changed

- The README's CLI install steps no longer offer a Homebrew tap or a
  crates.io crate, neither of which exists. They give the install script, the
  release binaries, and a link to the CLI's own installation table.
- `SECURITY.md` links to the published disclosure policy
  (https://promptguard.co/security#reporting-a-vulnerability) instead of
  keeping its own copy of the response times.

## [1.4.0] — 2026-09-06

The plugin ships instructions, so a wrong reference is a defect in the product
rather than in its documentation — an agent reading these files acts on them.

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

## [1.3.1] — 2026-08-11

### Fixed

- **The API reference documented threat-type values that do not exist.** It
  listed `injection`, `jailbreak`, `pii` and `exfiltration`; the API returns
  `prompt_injection`, `pii_leak` and `data_exfiltration`. Anyone who followed
  this reference and matched on those strings was matching on nothing, and the
  branch never fired. The values are now the API's own, with a note that they
  are `snake_case` and several read differently from the plain-English name of
  the attack.


No user-facing changes yet since this changelog was introduced.

