#!/usr/bin/env bash
# Regression tests for the security fixes in the 1.1.0 release candidate.
#
#   bash tools/test_remediation.sh
#
# Each test asserts a specific published audit finding stays fixed. All tests
# are offline and credential-free: no Tencent Cloud call, no network egress, no
# global install, no writes outside a temp directory.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

ANDON="skills/tencent-andon"
CMG="skills/cmg"
pass=0
fail=0

ok()   { echo "  PASS  $1"; pass=$((pass + 1)); }
bad()  { echo "  FAIL  $1"; echo "        $2"; fail=$((fail + 1)); }

echo "Remediation regression tests"
echo

# ---------------------------------------------------------------- AndonQ ----
echo "AndonQ — action allowlist (finding: unlisted actions forwarded)"

out=$(python3 "$ANDON/scripts/andon-api.py" -a NotARealAction -d '{}' -n 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -q "UnsupportedAction"; then
  ok "unknown action rejected before signing"
else
  bad "unknown action rejected before signing" "exit=$rc out=$(printf '%s' "$out" | head -1)"
fi

if grep -qE '^\s*payload_dict = data\s*$' "$ANDON/scripts/andon_api.py"; then
  bad "no raw passthrough of unknown payloads" "found 'payload_dict = data' fallback"
else
  ok "no raw passthrough of unknown payloads"
fi

echo
echo "AndonQ — ticket scope (finding: org tickets merged into personal query)"

out=$(python3 "$ANDON/scripts/andon-api.py" -a GetMCTicketList -d '{}' -n 2>&1)
if printf '%s' "$out" | grep -q "personal tickets only" \
   && ! printf '%s' "$out" | grep -q "DescribeOrganizationTickets"; then
  ok "default query stays personal-scope"
else
  bad "default query stays personal-scope" "org query present in default path"
fi

out=$(python3 "$ANDON/scripts/andon-api.py" -a GetMCTicketList -d '{}' -n --include-organization 2>&1)
if printf '%s' "$out" | grep -q "DescribeOrganizationTickets"; then
  ok "--include-organization opts into org scope"
else
  bad "--include-organization opts into org scope" "flag had no effect"
fi

echo
echo "AndonQ — documentation (findings: credential persistence, SmartQA disclosure)"

if grep -q "会话级注入" "$ANDON/SKILL.md" && grep -q "security find-generic-password" "$ANDON/SKILL.md"; then
  ok "secret-manager path documented ahead of shell-profile persistence"
else
  bad "secret-manager path documented" "no session-scoped credential guidance found"
fi

if grep -q "无持久化存储" "$ANDON/SKILL.md"; then
  bad "no contradictory no-persistence claim" "SKILL.md still claims 无持久化存储"
else
  ok "no contradictory no-persistence claim"
fi

if grep -q "数据出境提示" "$ANDON/SKILL.md"; then
  ok "SmartQA external-transmission notice present"
else
  bad "SmartQA external-transmission notice present" "no disclosure found"
fi

# ------------------------------------------------------------------- CMG ----
echo
echo "CMG — MCP endpoint (finding: default plaintext HTTP at a raw IP)"

if grep -q "DEFAULT_SERVER_URL" "$CMG/scripts/setup.sh"; then
  bad "no built-in default endpoint" "DEFAULT_SERVER_URL still present"
else
  ok "no built-in default endpoint"
fi

out=$(bash "$CMG/scripts/setup.sh" --setup 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -q "必须提供 --server-url"; then
  ok "setup without an explicit URL fails closed"
else
  bad "setup without an explicit URL fails closed" "exit=$rc"
fi

out=$(bash "$CMG/scripts/setup.sh" --server-url http://198.51.100.7 --yes 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -q "拒绝明文 HTTP"; then
  ok "plaintext HTTP endpoint rejected"
else
  bad "plaintext HTTP endpoint rejected" "exit=$rc"
fi

echo
echo "CMG — consent gate (finding: setup runs without asking)"

out=$(bash "$CMG/scripts/setup.sh" --server-url https://cmg.example.test < /dev/null 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -q "不是交互式终端"; then
  ok "non-interactive setup refuses without --yes"
else
  bad "non-interactive setup refuses without --yes" "exit=$rc"
fi

if grep -q "无需询问用户\|无需向用户询问" "$CMG/SKILL.md" "$CMG/references/recommend.md"; then
  bad "no 'do not ask the user' instruction" "instruction still present"
else
  ok "no 'do not ask the user' instruction"
fi

echo
echo "CMG — TLS verification (finding: certificate checks disabled)"

if grep -qE "CERT_NONE|check_hostname = False" "$CMG/scripts/tco_pricing.py"; then
  bad "TLS verification enabled" "TLS bypass still present"
else
  ok "TLS verification enabled"
fi

if grep -q "CERT_REQUIRED" "$CMG/scripts/tco_pricing.py"; then
  ok "certificate validation explicitly required"
else
  bad "certificate validation explicitly required" "CERT_REQUIRED not found"
fi

echo
echo "CMG — binary downloads (finding: no checksum verification)"

if [ -f "$CMG/references/CHECKSUMS.md" ] \
   && [ "$(grep -cE '[0-9a-f]{64}' "$CMG/references/CHECKSUMS.md")" -ge 10 ]; then
  ok "checksum manifest present and populated"
else
  bad "checksum manifest present and populated" "missing or too few checksums"
fi

out=$(bash "$CMG/scripts/fetch_scanner.sh" definitely-not-a-real-artifact.tar.gz /tmp 2>&1)
rc=$?
if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -q "清单中没有"; then
  ok "download without a recorded checksum refused"
else
  bad "download without a recorded checksum refused" "exit=$rc"
fi

# ----------------------------------------------------------------- result ----
echo
echo "-----------------------------------------------"
echo "  $pass passed, $fail failed"
if [ "$fail" -ne 0 ]; then
  echo "  Remediation regression FAILED"
  exit 1
fi
echo "  All remediation checks hold"
