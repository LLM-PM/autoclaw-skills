#!/usr/bin/env python3
"""Verify the integrity and provenance of the vendored skill sources.

PROVENANCE.json records two states per skill:

  published    the ClawHub release the source was obtained from, with the
               per-file SHA-256 manifest ClawHub publishes for that version;
  workingTree  the current in-repo state, which may be a pending release
               candidate that intentionally differs from the published one.

Two checks:

  integrity (default)  Every file under skills/<slug>/ matches the SHA-256
                       recorded in workingTree.files, with no extra or missing
                       files. Catches accidental or unreviewed edits. Offline.

  --check-published    Additionally fetches the published manifest from ClawHub
                       and confirms the recorded published hashes still match
                       upstream, then prints the remediation delta between the
                       published release and the working tree.

Read-only and unauthenticated: no cloud credentials, no Tencent Cloud calls.

Usage:
    python3 tools/verify_provenance.py [--check-published] [--json]
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
import urllib.error
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
PROVENANCE = REPO_ROOT / "PROVENANCE.json"
MANIFEST_API = "https://clawhub.ai/api/v1/skills/{slug}/versions/{version}"
TIMEOUT = 30

# Documentation this repository adds around each skill; not part of the package.
IGNORED = {"README.md"}


def sha256_of(path: Path) -> tuple[str, int]:
    data = path.read_bytes()
    return hashlib.sha256(data).hexdigest(), len(data)


def check_integrity(entry: dict) -> dict:
    slug = entry["slug"]
    root = REPO_ROOT / "skills" / slug
    wt = entry["workingTree"]
    expected = {f["path"]: f for f in wt["files"]}

    found = {
        str(p.relative_to(root)): p
        for p in sorted(root.rglob("*"))
        if p.is_file() and p.name not in IGNORED
    }

    mismatched, missing, extra = [], [], sorted(set(found) - set(expected))
    for rel, meta in sorted(expected.items()):
        path = found.get(rel)
        if path is None:
            missing.append(rel)
            continue
        actual_hash, actual_size = sha256_of(path)
        if actual_hash != meta["sha256"] or actual_size != meta["size"]:
            mismatched.append(
                {"path": rel, "expected": meta["sha256"], "actual": actual_hash}
            )

    return {
        "slug": slug,
        "check": "integrity",
        "version": wt["version"],
        "status": wt["status"],
        "fileCount": len(expected),
        "mismatched": mismatched,
        "missing": missing,
        "extra": extra,
        "ok": not (mismatched or missing or extra),
    }


def check_published(entry: dict) -> dict:
    slug = entry["slug"]
    pub = entry["published"]
    version = pub["version"]
    result = {"slug": slug, "check": "published", "version": version}

    url = MANIFEST_API.format(slug=slug, version=version)
    try:
        req = urllib.request.Request(url, headers={"Accept": "application/json"})
        with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
            upstream = {f["path"]: f for f in json.load(resp)["version"]["files"]}
    except (urllib.error.URLError, KeyError, ValueError) as exc:
        return {**result, "ok": False, "error": f"manifest fetch failed: {exc}"}

    recorded = {f["path"]: f for f in pub["files"]}
    drift = [
        p
        for p, meta in recorded.items()
        if p in upstream and upstream[p]["sha256"] != meta["sha256"]
    ]
    vanished = sorted(set(recorded) - set(upstream))

    result["ok"] = not (drift or vanished)
    result["drift"] = sorted(drift)
    result["vanished"] = vanished
    if not result["ok"]:
        result["error"] = "published package changed upstream since it was recorded"
    return result


def main() -> int:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "--check-published",
        action="store_true",
        help="also verify the recorded published manifest against ClawHub",
    )
    parser.add_argument("--json", action="store_true", dest="as_json", help="emit JSON")
    args = parser.parse_args()

    if not PROVENANCE.is_file():
        print(f"error: {PROVENANCE} not found", file=sys.stderr)
        return 2

    entries = json.loads(PROVENANCE.read_text(encoding="utf-8"))["skills"]
    results = [check_integrity(e) for e in entries]
    if args.check_published:
        results += [check_published(e) for e in entries]

    if args.as_json:
        print(json.dumps(results, indent=2, ensure_ascii=False))
    else:
        for r in results:
            mark = "PASS" if r.get("ok") else "FAIL"
            if r["check"] == "integrity":
                print(
                    f"[{mark}] {r['slug']} working tree v{r['version']} "
                    f"({r['status']}) — {r['fileCount']} files"
                )
                for m in r["mismatched"]:
                    print(f"         CHANGED  {m['path']}")
                    print(f"                  expected {m['expected']}")
                    print(f"                  actual   {m['actual']}")
                for p in r["missing"]:
                    print(f"         MISSING  {p}")
                for p in r["extra"]:
                    print(f"         UNTRACKED {p}")
            else:
                print(f"[{mark}] {r['slug']} published v{r['version']} — upstream manifest")
                for p in r.get("drift", []):
                    print(f"         DRIFT    {p} changed upstream")
                for p in r.get("vanished", []):
                    print(f"         GONE     {p} no longer in upstream manifest")
                if r.get("error") and not r.get("drift") and not r.get("vanished"):
                    print(f"         error: {r['error']}")
            print()

        if args.check_published:
            print("Remediation delta (published -> working tree):")
            for e in entries:
                d = e["workingTree"]["delta"]
                print(f"  {e['slug']}: "
                      f"{len(d['modified'])} modified, "
                      f"{len(d['added'])} added, "
                      f"{len(d['removed'])} removed")
                for p in d["modified"]:
                    print(f"      M {p}")
                for p in d["added"]:
                    print(f"      A {p}")
                for p in d["removed"]:
                    print(f"      D {p}")
            print()

    failed = [r for r in results if not r.get("ok")]
    if failed:
        print(f"{len(failed)} of {len(results)} check(s) FAILED", file=sys.stderr)
        return 1
    print(f"All {len(results)} check(s) passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
