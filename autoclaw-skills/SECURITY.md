# Security Policy

## Reporting a vulnerability

Please do not disclose exploitable security issues, credentials, tokens, private endpoints, or customer data in a public issue.

For issues that can be described safely without exposing sensitive details, open a GitHub issue using the security template. For anything requiring confidential disclosure, contact the maintainer privately through the channel listed on the [@LLM-PM](https://github.com/LLM-PM) GitHub profile.

Please allow up to 7 days for an initial response.

## Sensitive-content policy

This repository must not contain:

- API keys, access tokens, passwords, cookies, session identifiers, or secrets of any kind;
- internal-only endpoints, raw IP endpoints, or non-public infrastructure details;
- customer or employee personal data;
- proprietary documentation or code published without permission;
- confidential operational workflows or non-public company data.

Credential **names** (`TENCENTCLOUD_SECRET_ID`, `TENCENTCLOUD_SECRET_KEY`) are documented deliberately — they are part of the public interface. Credential **values** must never appear, including in examples, tests, or fixtures. Documentation uses placeholders such as `your-secret-id`.

Contributors are responsible for confirming that submitted material is authorized for public release.

### Repository scan status

The vendored `SKILL.md` files were scanned before commit for secret patterns (`SecretId`/`SecretKey` literals, `AKID*`/`AKIA*` keys, bearer tokens, authorization headers, passwords, cookies, private keys, `skey`/`uin` values), raw IPv4 endpoints, plaintext `http://` URLs, and internal-domain markers. **No matches.**

Every network destination referenced is a public, publicly resolving Tencent Cloud domain:

| Domain | Purpose |
| --- | --- |
| `tandon.tencentcloudapi.com` | Ticket API (list, detail) |
| `cloud.tencent.com` | SmartQA session creation; human-support link |
| `console.cloud.tencent.com` | Credential management console (documentation link) |
| `andon.cloud.tencent.com` | SmartQA chat (SSE stream) |

## Status: remediated in 1.1.0, pending publication

Every finding below is **fixed in the working tree** and covered by regression tests (`bash tools/test_remediation.sh`, 16 assertions). The fixes are **not yet published** — ClawHub still serves v1.0.0, so the audit pages still show the v1.0.0 verdict until 1.1.0 is published and re-scanned.

| | v1.0.0 (published) | 1.1.0 (this repository) |
| --- | --- | --- |
| Default MCP endpoint over plaintext HTTP at a raw IP | present | removed — no default; HTTPS enforced |
| TLS verification disabled (Alibaba Cloud pricing client) | present | fixed — `CERT_REQUIRED` + hostname check |
| `setup.sh` runs without user consent | present | fixed — explicit confirmation required |
| Binary downloads unverified | present | fixed — checksum manifest, fail-closed fetch |
| Unlisted actions forwarded to authenticated API | present | fixed — action allowlist |
| Organization tickets merged into personal query | present | fixed — opt-in `--include-organization` |
| Credential-persistence contradiction | present | fixed — secret-manager guidance, claim corrected |
| SmartQA external transmission undisclosed | present | fixed — explicit notice |

## Known security findings in published releases

ClawHub runs automated security review on every published version. Both v1.0.0 releases carry **open findings**, disclosed here rather than omitted. Full reports:

- [AndonQ audit](https://clawhub.ai/llm-pm/skills/tencent-andon/security-audit)
- [CMG audit](https://clawhub.ai/llm-pm/skills/cmg/security-audit)

| | AndonQ v1.0.0 | CMG v1.0.0 |
| --- | --- | --- |
| ClawHub moderation verdict | clean | clean |
| Malware scan (VirusTotal) | clean | clean |
| Static analyzer (skillspector) | suspicious — CRITICAL, 13 issues | suspicious — CRITICAL, 16 issues |
| LLM review | suspicious (high confidence) | suspicious (high confidence) |

No malware was detected in either package. The findings concern **credential handling, scope, and consent design** — genuine issues that affect users, and the maintainer's priority for the next release.

### AndonQ

1. **Credential persistence contradicts the stated policy.** `SKILL.md` instructs users to write long-lived AK/SK values into `~/.zshrc` / `~/.bashrc` or user-level environment variables, while §7.3 of the same document claims the skill does not persist data. The guidance and the claim are inconsistent.
2. **Ticket-list scope is wider than requested.** A `GetMCTicketList` call also issues `DescribeOrganizationTickets`, returning organization-wide tickets in response to what reads as a personal-ticket query.
3. **Unlisted actions are forwarded.** The CLI accepts action names outside the documented nine and sends them to the authenticated API, widening the reachable surface.
4. **Broad trigger phrases.** Generic phrases can route ambiguous requests into sensitive ticket or organization workflows.
5. **Undisclosed external transmission.** SmartQA sends user questions and multi-turn context to Tencent Cloud without an explicit privacy notice; verbose and dry-run modes can print payloads and signed-header metadata.

### CMG

1. **Unconsented setup.** `SKILL.md` directs the agent to run `scripts/setup.sh --setup` automatically "without asking the user". The script installs `mcporter` globally via npm and writes persistent configuration to `~/.mcporter/mcporter.json`.
2. **Default MCP endpoint over plaintext HTTP.** Setup persists a default MCP server at a raw HTTP IP address. Unencrypted, unauthenticated in transit, and not user-chosen — infrastructure inventories sent through it are exposed. **This is the highest-severity finding.**
3. **TLS verification disabled.** The Alibaba Cloud API client in the pricing path disables certificate verification.
4. **Unverified binary download.** The scan workflow downloads precompiled scanner binaries from remote storage with no checksum or signature check.
5. **Over-privileged credential guidance.** Documentation includes plaintext credential config examples and suggests AWS main-account scanning where read-only least-privilege credentials would suffice.

### What was changed

| Finding | Fix | Where |
| --- | --- | --- |
| CMG plaintext HTTP MCP endpoint | Built-in default removed entirely. `--server-url` is now required and validated: only `https://` is accepted (loopback may use `http://` for local debugging). No fallback on failure. | `skills/cmg/scripts/setup.sh` |
| CMG disabled TLS verification | `check_hostname = True`, `verify_mode = CERT_REQUIRED`. The request carries a signed `AccessKeyId`, so an unverified channel exposed credentials. | `skills/cmg/scripts/tco_pricing.py` |
| CMG unconsented `setup.sh` | Prints exactly what it will change, then requires confirmation before the global npm install and before writing `~/.mcporter/mcporter.json`. Non-interactive runs refuse unless `--yes` is passed. `--check-only` is strictly read-only. | `skills/cmg/scripts/setup.sh` |
| CMG unverified binary download | `fetch_scanner.sh` downloads over HTTPS, computes SHA-256, compares against a recorded manifest, and discards the file on mismatch or when no checksum is recorded. | `skills/cmg/scripts/fetch_scanner.sh`, `references/CHECKSUMS.md` |
| AndonQ unlisted action forwarding | `SUPPORTED_ACTIONS` allowlist; unknown actions return `UnsupportedAction` and exit non-zero **before** a request is signed. The `payload_dict = data` fallback is gone. | `skills/tencent-andon/scripts/andon_api.py` |
| AndonQ organization-ticket merge | `GetMCTicketList` returns only the caller's own tickets by default. Organization scope requires `--include-organization`. | `skills/tencent-andon/scripts/andon_api.py` |
| AndonQ credential persistence | Session-scoped injection from a secret manager is now the documented default; shell-profile persistence is a clearly-labelled fallback with its risks stated. The contradictory "no persistence" claim is corrected. | `skills/tencent-andon/SKILL.md` |
| AndonQ SmartQA disclosure | Explicit notice that questions and multi-turn context leave the local environment, plus guidance not to include secrets. New §7.4 documents data scope, sensitive fields, and the risk of `-v` / `-n` output. | `skills/tencent-andon/SKILL.md` |

### Additional defects found during remediation

Not in the audit, found while verifying the fixes:

- **`aws-scanner-win-amd64-1.0.0.zip` returns HTTP 404.** Documented as a download but never published.
- **`aliyun-scanner-win-amd64-1.0.0.zip` is 1,955 bytes** and contains only `ReadMe.txt` and `config.yaml` — no scanner executable.

Both are now marked unavailable in `references/scan.md` and `references/CHECKSUMS.md`, with Windows users directed to working alternatives.

### Verification

```bash
bash tools/test_remediation.sh   # 16 assertions, one per finding
bash tools/scan_secrets.sh       # credential / endpoint scan
python3 tools/verify_provenance.py --check-published
```

All three run in CI on every push and pull request. The secret scanner was regression-tested against the original vulnerable endpoint and still flags it.

### Remaining limitation

The checksums in `references/CHECKSUMS.md` were computed by the maintainer by downloading each artifact on 2026-08-12. They detect later tampering, corruption, or substitution, but do **not** establish original authenticity — upstream publishes no signatures or official checksum manifest. This is stated in the file itself rather than presented as stronger than it is.

## Guidance for users

While ClawHub still serves v1.0.0:

- Use least-privilege, short-lived credentials; never main-account or root keys.
- Prefer a secret manager over shell profile files for AK/SK.
- Review `setup.sh` before running it, and never accept a plaintext HTTP MCP endpoint.
- Treat ticket details, organization lists, attachment URLs, and resource inventories as confidential.
- Avoid verbose (`-v`) and dry-run (`-n`) output in shared terminals or logs.
