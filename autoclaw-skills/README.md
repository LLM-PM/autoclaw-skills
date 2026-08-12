# AutoClaw Skills

**Open-source AI agent skills maintained by [@LLM-PM](https://github.com/LLM-PM) and distributed through [ClawHub](https://clawhub.ai/llm-pm).**

Two published skills for the [OpenClaw](https://openclaw.ai) agent ecosystem, both targeting Tencent Cloud operations workflows. This repository is the public maintenance home: skill definitions, provenance records, security posture, and release history.

| Skill | ClawHub slug | Version | License | Cumulative downloads |
| --- | --- | --- | --- | ---: |
| **AndonQ** — Tencent Cloud ticketing & support Q&A | [`tencent-andon`](https://clawhub.ai/llm-pm/skills/tencent-andon) | 1.0.0 | MIT-0 | **477** |
| **Cloud Migration CMG** (云迁移CMG) — multi-cloud migration assessment | [`cmg`](https://clawhub.ai/llm-pm/skills/cmg) | 1.0.0 | MIT-0 | **568** |
| **Total** | | | | **1,045** |

> These are **cumulative** downloads reported by the ClawHub API as of 2026-08-12 — not monthly downloads.
> Verify at any time: `curl https://clawhub.ai/api/v1/skills/tencent-andon` (see `stats.downloads`).

## Install

Both skills install through the OpenClaw CLI:

```bash
openclaw skills install @llm-pm/tencent-andon
openclaw skills install @llm-pm/cmg
```

ClawHub is the distribution channel. This repository is **not** an installable package — it is the source-of-record and documentation home.

## The skills

### AndonQ (`tencent-andon`)

Tencent Cloud ticket and intelligent-support assistant. Nine actions covering ticket lists and details, organization tickets, requirement records, ticket operation history, and a credential-free streaming Q&A endpoint (SmartQA) for Tencent Cloud product questions.

- Ticket actions authenticate with Tencent Cloud AK/SK via TC3-HMAC-SHA256, read from `TENCENTCLOUD_SECRET_ID` / `TENCENTCLOUD_SECRET_KEY`.
- SmartQA requires no credentials.
- Network scope is limited to `tandon.tencentcloudapi.com`, `cloud.tencent.com`, and `andon.cloud.tencent.com`.

→ [`skills/tencent-andon/`](skills/tencent-andon/)

### Cloud Migration CMG (`cmg`)

Pre-migration assessment workflow for the Tencent Cloud migration platform (CMG/MSP): scan source-cloud resources (Alibaba Cloud / AWS / Huawei Cloud / GCP), map them to Tencent Cloud specifications, produce TCO comparisons, and route each resource type to the right migration tool.

Its defining constraint: **all pricing must come from a live cloud-provider API or official price calculator.** The skill explicitly forbids the agent from estimating, recalling, or inferring prices, because the output feeds commercial quotations.

→ [`skills/cmg/`](skills/cmg/)

## Security status

Both published v1.0.0 packages carry open findings from ClawHub's automated security review — most seriously, CMG shipped a default MCP endpoint reached over **plaintext HTTP at a hardcoded IP**, and disabled TLS verification in its pricing client.

**All eight findings are fixed in this repository** (version 1.1.0, pending publication) and covered by 16 regression assertions:

```bash
bash tools/test_remediation.sh
```

ClawHub still serves v1.0.0, so its audit pages reflect v1.0.0 until 1.1.0 is published and re-scanned. Full disclosure, the fix for each finding, and the remaining limitations are in [SECURITY.md](SECURITY.md).

This repository contains **no** credentials, tokens, private endpoints, customer or employee data, or internal-only documentation. Credential *names* (`TENCENTCLOUD_SECRET_ID`, `TENCENTCLOUD_SECRET_KEY`) appear with placeholder values only, enforced by `bash tools/scan_secrets.sh` in CI.

## Provenance

The complete source of both packages was downloaded from the ClawHub API and verified file-by-file against the signed release manifests before any change was made. Every file the manifest attests to matched byte-for-byte.

`PROVENANCE.json` tracks two states per skill: the **published** ClawHub release with its full per-file manifest, and the **working tree**, which is currently a pending 1.1.0 release candidate that intentionally differs from it.

```bash
python3 tools/verify_provenance.py                    # working-tree integrity (offline)
python3 tools/verify_provenance.py --check-published   # + upstream check and remediation delta
```

No credentials required; read-only, calls no cloud API. Details in [PROVENANCE.md](PROVENANCE.md).

## Maintenance

- Versions track the published ClawHub release; see [CHANGELOG.md](CHANGELOG.md).
- Provenance is machine-verifiable and enforced in CI on every push and pull request.
- Contribution process and review expectations: [CONTRIBUTING.md](CONTRIBUTING.md).
- Vulnerability reporting and sensitive-content policy: [SECURITY.md](SECURITY.md).

## License

[MIT No Attribution (MIT-0)](LICENSE) — matching the license declared on both published ClawHub releases.
