# Changelog

Notable changes to AutoClaw Skills.

This file tracks two distinct things: **repository** changes (documentation, provenance, tooling) and **published skill releases** on ClawHub. Skill releases follow the version recorded in the ClawHub package manifest, which is authoritative.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.1.0] — unreleased — security remediation

Fixes every open finding from the ClawHub security audits of both v1.0.0 releases. **Not yet published**; ClawHub still serves v1.0.0 until this is pushed and re-scanned.

Full source for both packages was obtained from the ClawHub download API and SHA-256 verified against the published manifests before any change was made, so these are fixes to the authoritative bytes.

### Security — Cloud Migration CMG

- **Removed the built-in default MCP endpoint.** `setup.sh` shipped `DEFAULT_SERVER_URL="http://<raw-ip>"` and `SKILL.md` told the agent to run setup "without asking the user", so cloud resource inventories were sent unencrypted to a hardcoded third-party address. `--server-url` is now required and validated; only `https://` is accepted (loopback may use `http://` for local debugging); there is no fallback.
- **Restored TLS verification** in the Alibaba Cloud pricing client, which set `check_hostname = False` and `verify_mode = CERT_NONE` while sending signed requests carrying an `AccessKeyId`.
- **Added a consent gate.** `setup.sh` now states what it will change and requires confirmation before the global npm install and before writing `~/.mcporter/mcporter.json`. Non-interactive runs refuse unless `--yes` is passed. `--check-only` is strictly read-only.
- **Added checksum verification for scanner binaries.** New `scripts/fetch_scanner.sh` downloads over HTTPS, compares SHA-256 against `references/CHECKSUMS.md`, and discards the file on mismatch or when no checksum is recorded.
- Replaced `require()` with a JSON parse when reading `mcporter.json`, so a config file is never executed as code.

### Security — AndonQ

- **Added an action allowlist.** Unrecognized actions previously fell through to `payload_dict = data` and were signed and sent, exposing the whole authenticated API surface. They now fail with `UnsupportedAction` before any request is signed.
- **Made organization scope opt-in.** `GetMCTicketList` silently also queried `DescribeOrganizationTickets`, widening a personal-ticket query to organization-wide results. Organization scope now requires `--include-organization`.
- **Corrected the credential guidance.** Session-scoped injection from a secret manager is documented first; shell-profile persistence is a labelled fallback with its risks stated. §7.3 no longer claims "no persistence" while §1.1 instructs users to persist keys.
- **Disclosed SmartQA transmission.** Added an explicit notice that questions and multi-turn context leave the local environment, plus a new §7.4 covering data scope, sensitive response fields, and the risk of `-v` / `-n` output in shared terminals.

### Fixed

- Marked two release artifacts unavailable after finding them broken: `aws-scanner-win-amd64-1.0.0.zip` returns HTTP 404, and `aliyun-scanner-win-amd64-1.0.0.zip` is 1,955 bytes containing only `ReadMe.txt` and `config.yaml` with no executable.
- Reconciled CMG's frontmatter version, which declared `1.2.0` against a published `1.0.0`.
- Removed `_skillhub_meta.json` from both packages — local install artifacts (`installedAt`, `source`) that were packaged by accident, and which recorded a third conflicting version (`1.0.2`).

### Added

- `tools/test_remediation.sh` — 16 regression assertions, one or more per finding. Offline, credential-free, no global installs.

---

## [Unreleased] — repository

### Added
- Vendored the **complete** source of both published packages, obtained from the ClawHub download API and verified file-by-file against the signed release manifests (30 of 31 files exact; the sole difference is `_meta.json`, injected by the download endpoint and absent from the published manifest).
- `PROVENANCE.md` and `PROVENANCE.json` — publisher identity evidence, authoritative-source record, and the full published package manifests with per-file hashes.
- `tools/verify_provenance.py` — verifies working-tree integrity against recorded hashes, and with `--check-published` confirms the recorded published manifest still matches ClawHub. Read-only, unauthenticated, no cloud credentials.
- CI workflow running provenance verification, the secret scan, and the remediation regression suite on every push and pull request.
- `LICENSE` (MIT-0), matching the license declared on both published releases.
- `.gitignore` covering credential files and skill working artifacts that may contain customer infrastructure inventories.
- Issue and pull request templates.

### Changed
- README rewritten to lead with what the project is, who maintains it, where it is distributed, and measured adoption.
- `SECURITY.md` expanded with the pre-commit scan result and full disclosure of open ClawHub security findings for both v1.0.0 releases, with a remediation plan.
- Per-skill READMEs expanded with capability tables, credential requirements, network scope, and security status.

### Fixed
- Corrected the recorded publication date for both skills. Earlier revisions of this changelog dated the 1.0.0 releases to 2026-08; the ClawHub API reports both were published **2026-03-27**.

### Security
- Scanned all vendored files for secret patterns, raw IP endpoints, plaintext `http://` URLs, and internal-domain markers before commit. No matches after remediation.
- Confirmed every referenced network destination is a public, publicly resolving Tencent Cloud domain.
- Vendored `scripts/` and `references/` only after obtaining their authoritative bytes from the ClawHub download API and hash-verifying them, and only in remediated form — the vulnerable v1.0.0 bytes (plaintext HTTP MCP endpoint, disabled TLS verification) were never committed to this repository's history.

---

## Published skill releases

Both skills are at v1.0.0 with one published version each. Verify current state at `https://clawhub.ai/api/v1/skills/<slug>`.

### AndonQ (`tencent-andon`) — [1.0.0] — 2026-03-27

Skill record last updated 2026-05-11. Published under MIT-0. Release notes as recorded on ClawHub:

- Removed general cloud-resource management and ticket-creation content built on `tccli`, narrowing the skill to ticket queries and intelligent Q&A.
- Condensed and merged the documentation structure, removing selected detail and internal interface descriptions.
- Deleted `references/tccli-api-discovery.md` and `references/tccli-install.md`, along with related `tccli` instructions.
- Updated the feature overview and action list, reducing the supported surface to 9 actions.
- Retained all existing primary capabilities (ticket query/detail, intelligent Q&A, organization tickets and requirement records) unchanged.
- Introduced a unified JSON response structure and error-code documentation across all actions.

### Cloud Migration CMG (`cmg`) — [1.0.0] — 2026-03-27

Skill record last updated 2026-05-18. Published under MIT-0. Release notes as recorded on ClawHub:

- Initial release of the cloud migration skill, providing full-process migration capability for Tencent Cloud.
- Resource scan (`cmg-scan`) for Alibaba Cloud, AWS, Huawei Cloud and GCP, with Excel export.
- Product recommendation (`cmg-recommend`), mapping scanned resources to Tencent Cloud equivalents.
- TCO/cost analysis (`cmg-tco`) with a strict requirement to use only live pricing from official APIs or calculators — price estimation is prohibited.
- Migration tool guidance per resource type (`cmg-migrate`).
- Workflow and documentation references for each migration stage.

> The published `cmg/SKILL.md` declared `version: 1.2.0` in its frontmatter against a release of `1.0.0`. Corrected to `1.1.0` in the pending release; see [PROVENANCE.md](PROVENANCE.md#version-discrepancies-found-and-resolved).

### Planned — next release

Security remediation for both skills, tracked in [SECURITY.md](SECURITY.md#what-was-changed). Highest priority: replace CMG's plaintext HTTP MCP endpoint and restore TLS verification.
