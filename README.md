# AutoClaw Skills

Open-source AI agent skills maintained by [@LLM-PM](https://github.com/LLM-PM) and distributed through ClawHub.

This repository is the canonical public source for AutoClaw skill packages, documentation, maintenance history, and release notes.

## Adoption

ClawHub usage snapshot (August 2026):

| Skill | Cumulative downloads |
| --- | ---: |
| AndonQ | 477 |
| Cloud Migration CMG (云迁移CMG) | 568 |
| **Total** | **1,045** |

These figures represent cumulative downstream downloads shown by ClawHub and are not monthly-download metrics.

## Published skills

### AndonQ

A Tencent Cloud support workflow skill focused on ticket lookup and product Q&A. It is designed to reduce context switching when users need cloud-product support information.

### Cloud Migration CMG (云迁移CMG)

A cloud-migration workflow skill covering resource discovery and inventory, migration-oriented analysis, and cloud migration planning scenarios across major cloud platforms.

## Repository layout

```text
skills/
  andonq/
  cloud-migration-cmg/
```

Public skill definitions are kept separate from private systems, credentials, internal-only documentation, and proprietary implementation details. Do not commit secrets, tokens, private endpoints, customer data, or internal company material.

## Maintenance

The project is actively maintained. Changes should be traceable through Git history and release notes. Compatibility, security, documentation, and behavior changes are reviewed before publication.

See [CONTRIBUTING.md](CONTRIBUTING.md), [SECURITY.md](SECURITY.md), and [CHANGELOG.md](CHANGELOG.md).

## License

A repository license will be added after the maintainer selects the intended open-source license. Until then, no additional rights are granted beyond those provided by applicable law.
