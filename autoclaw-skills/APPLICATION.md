# Codex for Open Source — application notes

Working notes for the OpenAI Codex for Open Source application. Every figure here is verifiable from a public endpoint; nothing is projected or rounded up.

| | |
| --- | --- |
| Repository | https://github.com/LLM-PM/autoclaw-skills |
| GitHub username | `LLM-PM` |
| ClawHub publisher | `llm-pm` (AutoClaw) |
| Role | Primary maintainer |

## Why this repository qualifies

I maintain an open-source AI agent skills project distributed through ClawHub, the package registry for the OpenClaw agent ecosystem. Its two published skills — **AndonQ** (`tencent-andon`) and **Cloud Migration CMG** (`cmg`) — have **1,045 cumulative downloads**, demonstrating real downstream usage beyond GitHub stars.

I maintain the skill definitions, compatibility, documentation, release history, provenance records, and security posture as the agent ecosystem evolves.

## Adoption (verifiable)

| Skill | Slug | Downloads | Installs |
| --- | --- | ---: | ---: |
| AndonQ | `tencent-andon` | 477 | 12 |
| Cloud Migration CMG | `cmg` | 568 | 15 |
| **Total** | | **1,045** | **27** |

Cumulative figures as of 2026-08-12, from the public ClawHub API:

```bash
curl -s https://clawhub.ai/api/v1/skills/tencent-andon | python3 -m json.tool | grep -A5 '"stats"'
curl -s https://clawhub.ai/api/v1/skills/cmg          | python3 -m json.tool | grep -A5 '"stats"'
```

> These are **cumulative** downloads since first publication (2026-03-27), **not** monthly downloads. Do not restate them as a monthly rate — the underlying data does not support that claim.

## What the skills do

**AndonQ** — Tencent Cloud ticket and support assistant. Nine actions covering ticket lists and details, organization tickets, requirement records, and operation history, plus a credential-free streaming Q&A endpoint. Ticket actions authenticate with TC3-HMAC-SHA256.

**Cloud Migration CMG** — Pre-migration assessment for the Tencent Cloud migration platform: scan source-cloud resources across Alibaba Cloud, AWS, Huawei Cloud and GCP, map them to Tencent Cloud specifications, produce TCO comparisons, and route each resource type to the right migration tool. Its defining constraint is that all pricing must come from a live provider API or official calculator — the agent is explicitly forbidden from estimating prices, because the output feeds commercial quotations.

## Interested in

- Codex Security
- API credits for my project

## How I will use API credits

Concretely, against work this repository already needs:

1. **Security remediation follow-through** — the eight findings from the published ClawHub audits are fixed in the 1.1.0 candidate (see [SECURITY.md](SECURITY.md)), including removing a default plaintext-HTTP MCP endpoint and restoring TLS verification in CMG. Credits would go to keeping this standard: re-auditing each release, expanding the regression suite, and reviewing fixes as the skills evolve.
2. **Automated regression testing** — build a test suite for skill definitions: action coverage, trigger-phrase collisions, response-format conformance, and reference-path integrity.
3. **Compatibility checks** — validate skill behavior across agent runtime versions as the OpenClaw ecosystem changes, and catch breaking frontmatter or dispatch changes before release.
4. **Issue reproduction** — reproduce user-reported failures without touching production cloud accounts.
5. **Documentation maintenance** — keep bilingual (Chinese/English) documentation synchronized with published behavior.
6. **Release validation** — extend `tools/verify_provenance.py` into a full pre-publish gate covering manifests, hashes, version consistency, and changelog completeness.
7. **PR review automation** — automated first-pass review enforcing the security and provenance checklist as outside contributions arrive.

## Maintenance evidence in this repository

- **Verifiable provenance** — the complete source of both packages was imported from the ClawHub API and verified file-by-file against the signed release manifests. `PROVENANCE.json` tracks the published release and the pending candidate separately, so the remediation delta is explicit. See [PROVENANCE.md](PROVENANCE.md).
- **Executable validation** — `tools/verify_provenance.py`, `tools/scan_secrets.sh`, and `tools/test_remediation.sh` (16 security regression assertions) all run in CI on every push and pull request, plus a weekly scheduled run to catch upstream drift. All are offline and credential-free.
- **Demonstrated security response** — the automated ClawHub findings are disclosed in full in [SECURITY.md](SECURITY.md), each mapped to the specific fix, with two additional broken-artifact defects found and documented during remediation. The scanner was regression-tested against the original vulnerable endpoint.
- **Release history** — [CHANGELOG.md](CHANGELOG.md) separates repository changes from published skill releases and records the real publication dates from the registry.
- **Contribution process** — [CONTRIBUTING.md](CONTRIBUTING.md), issue templates, and a pull request template enforcing security and provenance checks.
- **Clear scope boundary** — source comes only from the official ClawHub API, never a third-party mirror, and every import is hash-checked before use.

## Honest limitations

Worth stating plainly, since a reviewer will find them anyway:

- **Small GitHub footprint.** Adoption is real but lives on ClawHub, not GitHub — 1,045 downloads, 0 stars, no external contributors yet. This repository was established as the public maintenance home after the skills were already published.
- **One release each.** Both skills are at v1.0.0. Release history is short.
- **Security findings fixed but not yet published.** Both v1.0.0 packages carried CRITICAL static-analyzer findings (malware scans clean). All eight are now fixed in this repository with regression tests, but ClawHub still serves v1.0.0, so its audit pages show the old verdict until 1.1.0 is published and re-scanned.

The case rests on measured downstream adoption, verifiable provenance, and a documented security process — not on GitHub popularity.

## Distribution links

- AndonQ: https://clawhub.ai/llm-pm/skills/tencent-andon
- Cloud Migration CMG: https://clawhub.ai/llm-pm/skills/cmg
- Publisher profile: https://clawhub.ai/llm-pm

## Before submitting

- [x] Repository-wide license added (MIT-0, matching both published releases)
- [x] Authoritative `SKILL.md` vendored with verified provenance
- [x] Security posture documented
- [x] CI validation in place
- [ ] Keep the repository public
- [ ] Use the ChatGPT-account email on the application form
- [ ] Obtain the OpenAI Organization ID from the OpenAI Platform account
- [ ] Re-check download figures immediately before submitting — they grow over time
