# Troubleshooting

## Claude exits through the wrong country

Likely causes:

- The request matched `AI` or `PROXY`, not `CLAUDE`.
- The selected node inside `CLAUDE` changed.
- A browser tab kept an old connection alive.

Checks:

```bash
RUN_NETWORK_CHECK=1 scripts/check.sh
```

Then inspect Clash Verge connections and confirm `anthropic.com`, `claude.ai`,
and `claude.com` match the `CLAUDE` group.

## Direct works, proxy spins forever

Likely causes:

- The site is sensitive to fake-ip DNS.
- The site should be direct, but matched `PROXY`.
- TUN kept stale connections from the previous rule state.

Fix:

- Add the domain to `CN-DIRECT` if it is domestic or work-local traffic.
- Add it to `dns.fake-ip-filter` when synthetic DNS breaks the page.
- Quit and reopen the browser or app after changing rules.

## Work tools still use an old proxy port

Error shape:

```text
ECONNREFUSED 127.0.0.1:12334
```

Likely cause:

- The terminal or GUI app inherited stale proxy environment variables.

Checks:

```bash
env | grep -E 'HTTP_PROXY|HTTPS_PROXY|ALL_PROXY|NO_PROXY'
launchctl getenv HTTP_PROXY
launchctl getenv HTTPS_PROXY
```

Fix the stale environment to the intended local entry:

```text
http://127.0.0.1:7897
```

## Clash Verge IP checks all fail

Likely causes:

- The selected policy group has no working node.
- The external controller is not available or uses a secret.
- DNS/fake-ip is misconfigured.
- TUN routed a node server IP into the proxy itself.

Checks:

```bash
curl -I --proxy http://127.0.0.1:7897 https://api.anthropic.com/
curl --proxy http://127.0.0.1:7897 https://api.ipify.org
```

Also confirm node server IPs are routed `DIRECT`.

## Claude Guard reports IPv6 failure while Clash says IPv6 is off

Likely cause:

- The guard is treating a Mihomo fake-ip IPv4-mapped address as real IPv6.

Expected fake-ip shape:

```text
::ffff:198.18.x.x
```

Fix:

- Update the guard logic so it classifies IPv4-mapped fake-ip addresses before
  deciding that public IPv6 is reachable.

## TUN mode behaves differently from web proxy mode

System proxy mode affects proxy-aware apps. TUN mode catches more traffic and
therefore exposes more routing mistakes.

When enabling TUN:

- Add node server IP direct rules.
- Keep domestic work tools in `CN-DIRECT`.
- Watch the live connection table after changing rules.
- Restart apps with stale connections.

