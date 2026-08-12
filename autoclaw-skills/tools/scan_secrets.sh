#!/usr/bin/env bash
# Fail if credential material, raw IP endpoints, or plaintext HTTP URLs appear
# in tracked content. Run locally before committing; also runs in CI.
#
#   bash tools/scan_secrets.sh
#
# Credential *names* (TENCENTCLOUD_SECRET_ID/KEY) are public interface and are
# allowed. Credential *values* are not. Placeholders such as "your-secret-id"
# are allowed.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

# Scan tracked and new-but-unignored content files. Three files are excluded
# because they legitimately contain matching text:
#   PROVENANCE.json          published SHA-256 hashes
#   tools/scan_secrets.sh    the patterns themselves
#   tools/test_remediation.sh negative-test inputs (RFC 5737 documentation IPs,
#                            plaintext URLs) that assert the fixes reject them
FILES=$(
  git ls-files --cached --others --exclude-standard \
      -- '*.md' '*.py' '*.sh' '*.json' '*.yaml' '*.yml' \
    | grep -v -E '^(PROVENANCE\.json|tools/scan_secrets\.sh|tools/test_remediation\.sh)$'
)

if [ -z "$FILES" ]; then
  echo "no files to scan"; exit 0
fi

COUNT=$(printf '%s\n' "$FILES" | wc -l | tr -d ' ')
fail=0

# check <label> <extended-regex> [-i]
check() {
  label="$1"; pattern="$2"; flags="${3:-}"
  hits=$(printf '%s\n' "$FILES" | tr '\n' '\0' \
    | xargs -0 grep -nEI $flags -- "$pattern" 2>/dev/null \
    | grep -v -E 'your-secret-id|your-secret-key|placeholder|example\.com|<[A-Za-z_-]+>' \
    | grep -v -E '127\.0\.0\.1|\[::1\]|localhost' || true)
  if [ -n "$hits" ]; then
    echo "FAIL  $label"
    printf '%s\n' "$hits" | sed 's/^/        /'
    fail=1
  else
    echo "ok    $label"
  fi
}

echo "Scanning $COUNT tracked files"
echo

check "Tencent Cloud AKID key"      '\bAKID[A-Za-z0-9]{16,}'
check "AWS access key"              '\bAKIA[0-9A-Z]{16}\b'
check "SecretId literal value"      'SecretId["[:space:]:=]+"?[A-Za-z0-9]{18,}'
check "SecretKey literal value"     'SecretKey["[:space:]:=]+"?[A-Za-z0-9]{24,}'
check "Bearer token"                'earer[[:space:]]+[A-Za-z0-9._-]{20,}'
check "GitHub / Slack token"        '\b(ghp_|gho_|github_pat_|xox[baprs]-)[A-Za-z0-9]{10,}'
check "Private key block"           '^-----BEGIN [A-Z ]*PRIVATE KEY-----'
check "Hardcoded password"          'password["[:space:]:=]+"[^"]{4,}"' -i
check "Cookie / skey / uin value"   '(cookie|skey|uin)["[:space:]:=]+"[^"]{6,}"' -i
check "Raw IPv4 endpoint"           '(^|[^0-9.])([0-9]{1,3}\.){3}[0-9]{1,3}([^0-9.]|$)'
check "Plaintext http:// URL"       'http://[A-Za-z0-9][^[:space:]"<>)`]*'
check "Internal domain marker"      '(\.oa\.com|\.woa\.com|tencent-internal|内网|内部接口|内部文档)'

echo
if [ "$fail" -ne 0 ]; then
  echo "Secret scan FAILED — resolve the findings above before committing."
  exit 1
fi
echo "Secret scan passed."
