# AndonQ (`tencent-andon`)

Tencent Cloud ticket and intelligent-support assistant for OpenClaw agents.

| | |
| --- | --- |
| ClawHub | https://clawhub.ai/llm-pm/skills/tencent-andon |
| Install | `openclaw skills install @llm-pm/tencent-andon` |
| Version | 1.0.0 (published 2026-03-27) |
| License | MIT-0 |
| Downloads | 477 cumulative (as of 2026-08-12) |

## What it does

Query Tencent Cloud support tickets and ask product questions without leaving the agent session. Nine actions:

| Action | Auth | Purpose |
| --- | --- | --- |
| `GetCurrentTime` | none | Current time plus 7/30/90/180/365-day range presets for building query parameters |
| `GetMCTicketList` | AK/SK | Ticket list, newest first, deduplicated by `TicketId` |
| `GetMCTicketById` | AK/SK | Ticket detail including conversation history |
| `SmartQA` | none | Multi-turn Tencent Cloud product Q&A over an SSE stream |
| `DescribeOrganizationTickets` | AK/SK | Organization member ticket list |
| `DescribeTicket` | AK/SK | Organization ticket detail |
| `DescribeTicketOperation` | AK/SK | Ticket operation history |
| `DescribeOrganizationStories` | AK/SK | Organization requirement-record list |
| `DescribeOrganizationStory` | AK/SK | Requirement-record detail |

The ticketing module and SmartQA are fully independent and share a unified JSON response format. SmartQA needs no credentials.

## Credentials

Ticket actions sign requests with Tencent Cloud AK/SK using TC3-HMAC-SHA256, read from the environment:

| Variable | Required for | Description |
| --- | --- | --- |
| `TENCENTCLOUD_SECRET_ID` | ticket actions | Tencent Cloud SecretId |
| `TENCENTCLOUD_SECRET_KEY` | ticket actions | Tencent Cloud SecretKey |

Obtain keys at https://console.cloud.tencent.com/cam/capi. Use least-privilege, short-lived credentials — never main-account keys.

> **Note:** `SKILL.md` recommends persisting these into `~/.zshrc` / `~/.bashrc`. A secret manager is preferable where available. This is a known open finding — see [SECURITY.md](../../SECURITY.md).

## Network scope

`tandon.tencentcloudapi.com` (ticket API), `cloud.tencent.com` (SmartQA session creation, human-support link), `andon.cloud.tencent.com` (SmartQA SSE stream). All public Tencent Cloud domains.

SmartQA transmits questions and multi-turn context to Tencent Cloud.

## Contents

Complete source, imported from the ClawHub package and hash-verified against the signed manifest:

- [`SKILL.md`](SKILL.md) — the agent-facing skill definition
- [`scripts/`](scripts/) — `andon_api.py` (signing + all ticket actions), `smartqa_api.py` (SSE client), and their CLI wrappers
- [`references/`](references/) — eight per-action reference documents
- `check_env.py` — environment/credential preflight
- `skill-card.md` — ClawHub listing card

`{baseDir}/...` paths inside `SKILL.md` resolve within an installed skill, not this repository.

## Security

Release 1.0.0 had open findings around credential persistence, organization-ticket scope, action allowlisting, and external-transmission disclosure. Malware scans were clean.

**All are fixed here in 1.1.0** (pending publication):

- unknown actions are rejected before a request is signed (`SUPPORTED_ACTIONS` allowlist)
- `GetMCTicketList` returns only your own tickets unless `--include-organization` is passed
- credential guidance leads with secret-manager injection; the contradictory "no persistence" claim is corrected
- SmartQA now discloses that questions and context leave the local environment

Verify: `bash tools/test_remediation.sh`. Full detail: [SECURITY.md](../../SECURITY.md).

## Verify provenance

```bash
python3 tools/verify_provenance.py
```
