#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

failures=0

search_pattern_to_file() {
  local pattern="$1"
  local output_file="$2"
  local error_file="$3"
  local search_status=1

  if command -v rg >/dev/null 2>&1; then
    rg -n --hidden --glob '!.git/**' --glob '!scripts/check-secrets.sh' "$pattern" "$root" >"$output_file" 2>"$error_file"
    return $?
  fi

  while IFS= read -r -d '' file; do
    if grep -nE "$pattern" "$file" >>"$output_file" 2>>"$error_file"; then
      search_status=0
    else
      local grep_status=$?
      if [[ "$grep_status" -gt 1 ]]; then
        return "$grep_status"
      fi
    fi
  done < <(find "$root" \
    -type f \
    ! -path '*/.git/*' \
    ! -path '*/scripts/check-secrets.sh' \
    -print0)

  return "$search_status"
}

scan() {
  local label="$1"
  local pattern="$2"
  local output_file error_file search_status

  output_file="$(mktemp)"
  error_file="$(mktemp)"

  set +e
  search_pattern_to_file "$pattern" "$output_file" "$error_file"
  search_status=$?
  set -e

  if [[ "$search_status" -gt 1 ]]; then
    printf 'secret-scan internal error while checking %s:\n' "$label" >&2
    cat "$error_file" >&2
    rm -f "$output_file" "$error_file"
    exit 2
  fi

  if [[ -s "$output_file" ]]; then
    printf 'secret-scan failure: %s\n' "$label" >&2
    cat "$output_file" >&2
    failures=$((failures + 1))
  fi

  rm -f "$output_file" "$error_file"
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
