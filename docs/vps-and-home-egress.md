# VPS and Home Egress

This kit works best when the egress roles are separated.

## VPS role

A VPS is useful for:

- General proxy fallback.
- Node management.
- Static routing experiments.
- Backing up the home egress when the home line is down.

A VPS is usually not the best default for every AI login page. Some front doors
are sensitive to data-center ASN reputation, shared proxy behavior, or previous
traffic history.

## Home-broadband role

A home-broadband or residential egress is useful for:

- Claude front-door and API path stability.
- Grok/X login and app endpoints.
- Reducing surprise changes caused by generic proxy fallback.

Use only egress you control or are authorized to use.

## Connection formats

Common ways to bring a home egress into Clash Verge:

- SOCKS5 listener exposed by a home router or relay.
- WireGuard to a home router or small home server.
- A self-hosted proxy service reachable through a stable endpoint.

The public template uses a SOCKS5 placeholder because it is easy to understand.
You can replace it with WireGuard, VLESS, Trojan, or another Mihomo-supported
proxy type if that is what your environment provides.

## Prevent self-loop

If a node server IP is itself reached through Clash Verge, TUN can accidentally
route the connection back into the proxy. This creates proxy-over-proxy loops
and strange timeouts.

Always add direct rules for node server IPs:

```yaml
rules:
  - IP-CIDR,203.0.113.10/32,DIRECT,no-resolve
  - IP-CIDR,198.51.100.20/32,DIRECT,no-resolve
```

Replace those documentation addresses with your own node server IPs.

## What to publish

Publish:

- The routing pattern.
- Sanitized templates.
- Check scripts.
- Troubleshooting steps.

Do not publish:

- Raw node links.
- Subscription URLs.
- UUIDs, keys, tokens, or cookies.
- Real private inventory unless intentionally public.

