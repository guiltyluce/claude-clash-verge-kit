#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

printf '== static checks ==\n'

required_files=(
  README.md
  LICENSE
  SECURITY.md
  CONTRIBUTING.md
  templates/mihomo.merge.example.yaml
  templates/claude-guard.example.json
  docs/architecture.md
  docs/clash-verge-setup.md
  docs/vps-and-home-egress.md
  docs/claude-guard-integration.md
  docs/troubleshooting.md
  scripts/check-network.sh
  scripts/check-secrets.sh
)

for file in "${required_files[@]}"; do
  test -f "$root/$file" || {
    printf 'missing required file: %s\n' "$file" >&2
    exit 1
  }
done

bash -n "$root/scripts/check-network.sh"
bash -n "$root/scripts/check-secrets.sh"

"$root/scripts/check-secrets.sh"
"$root/tests/static_checks.sh"

if [[ "${RUN_NETWORK_CHECK:-0}" == "1" ]]; then
  printf '\n== live network checks ==\n'
  "$root/scripts/check-network.sh"
else
  printf '\nset RUN_NETWORK_CHECK=1 to run live proxy checks\n'
fi

printf 'ok: all checks passed\n'

