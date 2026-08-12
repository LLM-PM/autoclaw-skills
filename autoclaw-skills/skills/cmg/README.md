# Cloud Migration CMG (`cmg`)

Pre-migration assessment workflow for the Tencent Cloud migration platform (CMG/MSP).

| | |
| --- | --- |
| ClawHub | https://clawhub.ai/llm-pm/skills/cmg |
| Install | `openclaw skills install @llm-pm/cmg` |
| Version | 1.0.0 (published 2026-03-27) |
| License | MIT-0 |
| Downloads | 568 cumulative (as of 2026-08-12) |
| Display name | 云迁移CMG |
| Frontmatter name | `tencent-cloud-migration` |
| Frontmatter version | `1.1.0` (was `1.2.0` against a published `1.0.0`) |

## What it does

Four capabilities covering the full pre-migration assessment path:

| Capability | Trigger | Output |
| --- | --- | --- |
| **Resource scan** (`cmg-scan`) | Inventory Alibaba Cloud / AWS / Huawei Cloud / GCP resources | `*_scan_*.xlsx` inventory |
| **Recommendation** (`cmg-recommend`) | Map scanned resources to Tencent Cloud specifications | `cmg_recommend_result.json` |
| **Cost analysis** (`cmg-tco`) | TCO comparison from live pricing | `pricing_data.json` + Excel/HTML report |
| **Migration guidance** (`cmg-migrate`) | Route each resource type to the right tool | guidance |

Typical flow: scan → recommend → TCO → migrate. Migration routing: hosts → Host Migration; object storage → MSP Object Storage Migration; databases → DTS; file storage → File Storage Migration.

## The pricing constraint

The skill's defining rule: **every price must come from a live cloud-provider API or an official price calculator.** The agent is explicitly forbidden from estimating, approximating, or recalling prices from training data.

The rationale is stated in the skill itself — this output feeds commercial quotations, so fabricated pricing causes real financial and reputational damage. When pricing cannot be retrieved, the skill requires the agent to report the failure rather than substitute an estimate. Each price record must carry a `price_source` field naming its origin (e.g. `阿里云 DescribePrice API`, `腾讯云 InquiryPriceRunInstances API`).

This is a good example of a skill encoding a hard correctness boundary rather than trusting model judgment.

## Credentials

Resource scanning and pricing require source-cloud credentials (Alibaba Cloud / AWS / Huawei Cloud / GCP). Use **read-only, least-privilege, short-lived** credentials. Do not use main or root account keys.

No credential values appear in this repository.

## Contents

Complete source, imported from the ClawHub package and hash-verified against the signed manifest:

- [`SKILL.md`](SKILL.md) — router that dispatches to the reference docs per capability
- [`references/`](references/) — `scan.md`, `recommend.md`, `tco.md`, `migrate.md`, `products.md`, plus `CHECKSUMS.md`
- [`scripts/`](scripts/) — `setup.sh`, `fetch_scanner.sh`, `tco_pricing.py`, `tco_report.py`, `dependency.py`, `summarize.py`
- `skill-card.md` — ClawHub listing card

`{baseDir}/...` paths inside `SKILL.md` resolve within an installed skill, not this repository.

## Security

Release 1.0.0 had the most serious findings in either skill: a **default MCP endpoint reached over plaintext HTTP at a hardcoded IP**, disabled TLS verification in the Alibaba Cloud pricing client, an automatic `setup.sh` the agent was told to run without asking, and unverified binary downloads. Malware scans were clean.

**All are fixed here in 1.1.0** (pending publication):

- no built-in endpoint; `--server-url` is required and must be `https://` (loopback may use `http://`)
- TLS certificate and hostname verification restored
- `setup.sh` states what it will change and requires confirmation; `--check-only` is strictly read-only
- `fetch_scanner.sh` verifies SHA-256 against [`references/CHECKSUMS.md`](references/CHECKSUMS.md) and discards mismatches

Verify: `bash tools/test_remediation.sh`. Full detail: [SECURITY.md](../../SECURITY.md).

## Broken upstream artifacts

Two Windows downloads documented in `scan.md` do not work and are marked unavailable:

| File | Problem |
| --- | --- |
| `aws-scanner-win-amd64-1.0.0.zip` | HTTP 404 — never published |
| `aliyun-scanner-win-amd64-1.0.0.zip` | 1,955 bytes; contains only `ReadMe.txt` and `config.yaml`, no executable |

Windows users should use the Huawei Cloud / AWS China artifacts, or scan from Linux or macOS.

## Verify provenance

```bash
python3 tools/verify_provenance.py
```
