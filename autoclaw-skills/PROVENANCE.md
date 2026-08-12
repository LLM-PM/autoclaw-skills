# Provenance

How the source in this repository was obtained, verified, and how it now relates to what ClawHub serves.

Machine-readable equivalent: [PROVENANCE.json](PROVENANCE.json).
Automated check: `python3 tools/verify_provenance.py --check-published`.

## Publisher identity

| | |
| --- | --- |
| ClawHub handle | `llm-pm` (display name **AutoClaw**) |
| GitHub account | [`LLM-PM`](https://github.com/LLM-PM), user id `145959662` |

The ClawHub publisher profile serves its avatar from `https://avatars.githubusercontent.com/u/145959662`. The GitHub API resolves user id `145959662` to `github.com/LLM-PM`. The two accounts are the same party, which is what authorizes republishing this material here.

## Authoritative source

Source was taken from the **ClawHub public REST API** — the official distribution channel. No third-party GitHub mirror was used, consulted, or copied.

| Purpose | Endpoint |
| --- | --- |
| Package download (ZIP) | `https://clawhub.ai/api/v1/download?slug=<slug>&ownerHandle=llm-pm&version=1.0.0` |
| Signed version manifest (per-file hashes) | `https://clawhub.ai/api/v1/skills/<slug>/versions/1.0.0` |
| Skill record (stats, raw `SKILL.md`) | `https://clawhub.ai/api/v1/skills/<slug>` |

Each package was downloaded, unpacked, and every file hashed against the published manifest before any change was made.

### Verification result

| Skill | Manifest files | Verified exact | Notes |
| --- | ---: | ---: | --- |
| `tencent-andon` | 18 | 17 | `_meta.json` differs — injected by the download endpoint at fetch time |
| `cmg` | 13 | 13 | download also included an extra `_meta.json` absent from the manifest |

Every file that the published manifest attests to matched byte-for-byte. Provenance status: **confirmed**.

`_meta.json` is generated per-download (it carries install-time metadata), is not part of the published manifest, and is not vendored.

## Two states: published vs working tree

[PROVENANCE.json](PROVENANCE.json) records both per skill.

**`published`** — ClawHub release **1.0.0** for both skills (published 2026-03-27, MIT-0), with the full per-file manifest and the recorded security verdict. This is the historical record of what the source was when imported.

**`workingTree`** — the current in-repo state, version **1.1.0**, status **`pending-publish`**. These files **intentionally differ** from the published package: they are the security remediation described in [SECURITY.md](SECURITY.md) and [CHANGELOG.md](CHANGELOG.md).

Until 1.1.0 is published, ClawHub serves 1.0.0 and its audit pages reflect 1.0.0.

### Remediation delta

| Skill | Modified | Added | Removed |
| --- | --- | --- | --- |
| `tencent-andon` | `SKILL.md`, `scripts/andon_api.py` | — | `_meta.json`, `_skillhub_meta.json` |
| `cmg` | `SKILL.md`, `references/recommend.md`, `references/scan.md`, `scripts/setup.sh`, `scripts/tco_pricing.py` | `references/CHECKSUMS.md`, `scripts/fetch_scanner.sh` | `_skillhub_meta.json` |

`_skillhub_meta.json` was a local install artifact (`installedAt`, `source`) packaged by accident; it is not source and is not republished.

## Published release metadata

| | AndonQ | Cloud Migration CMG |
| --- | --- | --- |
| Slug | `tencent-andon` | `cmg` |
| Frontmatter `name` | `AndonQ` | `tencent-cloud-migration` |
| ClawHub version | 1.0.0 | 1.0.0 |
| License (declared at publish) | MIT-0 | MIT-0 |
| Version published | 2026-03-27 | 2026-03-27 |
| Skill record last updated | 2026-05-11 | 2026-05-18 |
| Versions published | 1 | 1 |
| Downloads | 477 | 568 |
| Installs | 12 | 15 |
| Package files | 18 | 13 |
| ClawHub moderation verdict | clean | clean |

Statistics captured 2026-08-12 from `https://clawhub.ai/api/v1/skills/<slug>` (`stats` object).

### Version discrepancies found and resolved

The published packages carried three conflicting version values:

| Location | Value | Resolution |
| --- | --- | --- |
| ClawHub release (authoritative) | `1.0.0` | kept as the published baseline |
| `cmg/SKILL.md` frontmatter | `1.2.0` | corrected to `1.1.0` for this release |
| `tencent-andon/_skillhub_meta.json` | `1.0.2` | file removed — a local install artifact |

## Re-verifying

```bash
# Working-tree integrity: every file matches its recorded hash (offline)
python3 tools/verify_provenance.py

# Also confirm the recorded published manifest still matches ClawHub,
# and print the remediation delta
python3 tools/verify_provenance.py --check-published

# Machine-readable
python3 tools/verify_provenance.py --json
```

Read-only, unauthenticated, no Tencent Cloud calls. Runs in CI on every push and pull request, plus weekly to catch upstream drift.

## After 1.1.0 is published

Once the release is live, refresh the record so `published` tracks 1.1.0 and `workingTree` matches it again:

```bash
SLUG=cmg VERSION=1.1.0
curl -s "https://clawhub.ai/api/v1/skills/$SLUG/versions/$VERSION" | python3 -m json.tool
```

Update the skill's `published` block (version, date, manifest, security verdict) and set `workingTree.status` to `published`. See [CONTRIBUTING.md](CONTRIBUTING.md).
