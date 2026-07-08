#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

failures=0

scan() {
  local label="$1"
  local pattern="$2"
  local output status

  set +e
  output="$(rg -n --hidden --glob '!.git/**' --glob '!scripts/check-secrets.sh' "$pattern" "$root" 2>&1)"
  status=$?
  set -e

  if [[ "$status" -gt 1 ]]; then
    printf 'secret-scan internal error while checking %s:\n%s\n' "$label" "$output" >&2
    exit 2
  fi

  if [[ -n "$output" ]]; then
    printf 'secret-scan failure: %s\n%s\n' "$label" "$output" >&2
    failures=$((failures + 1))
  fi
}

scan "raw proxy share links" "(vless|vmess|trojan|ss)://"
scan "UUID-like values" "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
scan "subscription URLs" "(token|subscribe|subscription|sub)[_=][^[:space:]\"']{16,}"
scan "known private node IPs from local history" "(192\\.220\\.54\\.6|43\\.153\\.212\\.159|43\\.167\\.203\\.124|43\\.173\\.90\\.147|43\\.133\\.62\\.203|43\\.133\\.23\\.77|103\\.27\\.81\\.131)"
scan "common private key labels" "(private-key|private_key|client-key|client_key):[[:space:]]*[^[:space:]]+"

if [[ "$failures" -gt 0 ]]; then
  exit 1
fi

printf 'ok: secret scan passed\n'
