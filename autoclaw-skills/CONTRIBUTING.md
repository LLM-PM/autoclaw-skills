# Contributing

Thanks for contributing to AutoClaw Skills.

## Scope

Contributions should improve skill behavior, documentation, compatibility, validation, or security posture.

Do **not** submit proprietary material, customer or employee data, private APIs, credentials, tokens, internal-only documentation, or anything you are not authorized to publish. See [SECURITY.md](SECURITY.md).

## How this repository relates to ClawHub

ClawHub is the distribution channel; this repository is the maintenance home. `skills/<slug>/SKILL.md` is a **verbatim copy** of the published ClawHub release, verified by SHA-256 against the signed package manifest.

That has a direct consequence: **a change to a vendored `SKILL.md` is only valid as part of a release.** Editing one in isolation breaks provenance verification and will fail CI. To change skill behavior:

1. Open an issue describing the change and its user-facing impact.
2. Make the change in the working skill and publish a new ClawHub version.
3. Update the vendored copy from the ClawHub API, refresh `PROVENANCE.json`, and add a `CHANGELOG.md` entry — in one pull request.

Documentation, tooling, and repository-level changes carry no such constraint.

## Updating a vendored skill after a release

```bash
SLUG=tencent-andon
VERSION=1.1.0

# Pull the published SKILL.md (skill.description is the raw file)
curl -s "https://clawhub.ai/api/v1/skills/$SLUG" \
  | python3 -c 'import json,sys; sys.stdout.write(json.load(sys.stdin)["skill"]["description"])' \
  > "skills/$SLUG/SKILL.md"

# Confirm it matches the published manifest
curl -s "https://clawhub.ai/api/v1/skills/$SLUG/versions/$VERSION" \
  | python3 -c 'import json,sys; print(next(f for f in json.load(sys.stdin)["version"]["files"] if f["path"]=="SKILL.md"))'
shasum -a 256 "skills/$SLUG/SKILL.md"
```

Update the matching entry in `PROVENANCE.json` (`version`, `vendored.sha256`, `vendored.size`, `publishedPackageManifest`, `stats`), then run the checks below.

Never take skill source from a third-party GitHub mirror. The ClawHub API is the only authoritative source.

## Before opening a pull request

```bash
bash tools/scan_secrets.sh          # credential / endpoint scan
python3 tools/verify_provenance.py  # vendored files match ClawHub
python3 -m compileall -q tools      # tooling compiles
```

Both run in CI on every push and pull request.

## Pull request expectations

Fill in the template. A pull request should state what changed, why, any compatibility implications, any security or privacy considerations, and how it was validated.

The maintainer may request changes when a contribution introduces ambiguous behavior, undocumented dependencies, security risk, unverifiable provenance, or unclear licensing.

## Publishing a release

The repository is the source of truth between releases; ClawHub is the distribution channel. To publish:

```bash
# 1. Validate
bash tools/scan_secrets.sh
bash tools/test_remediation.sh
python3 tools/verify_provenance.py

# 2. Stage exactly the recorded file set (excludes repo-only README.md,
#    re-verifies every hash, re-scans the output)
bash tools/stage_release.sh cmg
bash tools/stage_release.sh tencent-andon

# 3. Publish (prints the exact command, including the version from PROVENANCE.json)
clawhub login
clawhub whoami            # confirm the publisher handle is llm-pm
clawhub skill publish dist/<slug> --slug <slug> --owner llm-pm --version <version> --changelog "..."
```

After publishing, confirm the re-scan verdict and update the record:

```bash
curl -s "https://clawhub.ai/api/v1/skills/<slug>/versions/<version>" | python3 -m json.tool
```

Move the new release into the skill's `published` block in `PROVENANCE.json` (version, date, manifest, security verdict) and set `workingTree.status` to `published`. Then `python3 tools/verify_provenance.py --check-published` should show no delta.

## Reporting instead of patching

Security findings that cannot be described publicly should go through the private channel in [SECURITY.md](SECURITY.md), not a pull request.

## License

By contributing you agree your contribution is licensed under [MIT-0](LICENSE), matching both published releases.
