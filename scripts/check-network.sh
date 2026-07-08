#!/usr/bin/env bash
set -euo pipefail

proxy_url="${CLASH_PROXY_URL:-http://127.0.0.1:7897}"
anthropic_url="${ANTHROPIC_CHECK_URL:-https://api.anthropic.com/}"
ip_url="${IP_CHECK_URL:-https://api.ipify.org}"

ok() {
  printf 'ok: %s\n' "$*"
}

warn() {
  printf 'warn: %s\n' "$*" >&2
}

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

http_code_via_proxy() {
  local url="$1"
  curl -4 -sS -o /dev/null \
    --connect-timeout 8 \
    --max-time 15 \
    --proxy "$proxy_url" \
    -w '%{http_code}' \
    "$url"
}

check_proxy_ip() {
  local ip
  ip="$(curl -4 -sS --connect-timeout 8 --max-time 15 --proxy "$proxy_url" "$ip_url" || true)"
  if [[ -z "$ip" ]]; then
    fail "could not fetch exit IP through $proxy_url"
  fi
  ok "exit IP through $proxy_url: $ip"
}

check_anthropic() {
  local code
  code="$(http_code_via_proxy "$anthropic_url" || true)"
  case "$code" in
    200|301|302|400|401|403|404)
      ok "Anthropic endpoint reachable through $proxy_url with HTTP $code"
      ;;
    *)
      fail "Anthropic endpoint check returned HTTP ${code:-none} through $proxy_url"
      ;;
  esac
}

check_scutil() {
  if ! command -v scutil >/dev/null 2>&1; then
    warn "scutil not found; skipping macOS system proxy snapshot"
    return 0
  fi

  ok "macOS proxy snapshot:"
  scutil --proxy | sed 's/^/  /'
}

check_launchctl() {
  if ! command -v launchctl >/dev/null 2>&1; then
    warn "launchctl not found; skipping GUI proxy snapshot"
    return 0
  fi

  ok "launchctl GUI proxy environment:"
  printf '  HTTP_PROXY=%s\n' "$(launchctl getenv HTTP_PROXY || true)"
  printf '  HTTPS_PROXY=%s\n' "$(launchctl getenv HTTPS_PROXY || true)"
  printf '  ALL_PROXY=%s\n' "$(launchctl getenv ALL_PROXY || true)"
  printf '  NO_PROXY=%s\n' "$(launchctl getenv NO_PROXY || true)"
}

check_ipv6_shape() {
  local result remote_ip
  result="$(curl -6 -sS -o /dev/null --noproxy '*' --connect-timeout 5 --max-time 8 -w 'remote_ip=%{remote_ip} http=%{http_code}' "$anthropic_url" 2>/dev/null || true)"
  if [[ -z "$result" ]]; then
    ok "direct IPv6 probe failed or is unavailable"
    return 0
  fi

  remote_ip="${result#remote_ip=}"
  remote_ip="${remote_ip%% *}"

  if [[ "$remote_ip" == ::ffff:198.18.* || "$remote_ip" == ::ffff:198.19.* ]]; then
    ok "direct IPv6 probe only returned Mihomo fake-ip mapping: $result"
    return 0
  fi

  warn "direct IPv6 probe returned: $result"
  warn "If this is a public IPv6 path, Claude Guard should block or you should disable/route IPv6 intentionally."
}

main() {
  ok "using proxy: $proxy_url"
  check_proxy_ip
  check_anthropic
  check_ipv6_shape
  check_scutil
  check_launchctl
}

main "$@"
