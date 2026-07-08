#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
template="$root/templates/mihomo.merge.example.yaml"

require_in_file() {
  local pattern="$1"
  local file="$2"

  if ! rg -q "$pattern" "$file"; then
    printf 'missing pattern in %s: %s\n' "$file" "$pattern" >&2
    exit 1
  fi
}

require_in_file '^mixed-port: 7897$' "$template"
require_in_file '^ipv6: false$' "$template"
require_in_file '^  - name: CLAUDE$' "$template"
require_in_file '^  - name: GROK$' "$template"
require_in_file '^  - name: AI$' "$template"
require_in_file '^  - name: CN-DIRECT$' "$template"
require_in_file 'DOMAIN-SUFFIX,anthropic.com,CLAUDE' "$template"
require_in_file 'DOMAIN-SUFFIX,feishu.cn,CN-DIRECT' "$template"
require_in_file 'IP-CIDR,198.51.100.20/32,DIRECT,no-resolve' "$template"
require_in_file 'REPLACE_WITH_' "$template"

if rg -n 'DIRECT' "$template" | rg 'name: CLAUDE|name: GROK' >/dev/null 2>&1; then
  printf 'CLAUDE/GROK groups should not include DIRECT in the example template\n' >&2
  exit 1
fi

printf 'ok: static template checks passed\n'

