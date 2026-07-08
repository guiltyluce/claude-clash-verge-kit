# Architecture

The kit is built around one rule: keep routing intent explicit.

## Layers

```text
Application
  -> local proxy environment or TUN
  -> Clash Verge Rev / Mihomo
  -> policy group
  -> selected egress
```

## Policy groups

`CN-DIRECT`

Domestic and daily-work traffic should go direct by default. This keeps Feishu,
Tencent, and other China-local services from being pulled into AI exits where
latency, DNS, or fraud controls may behave poorly.

`CLAUDE`

Claude should use a narrow list of known-good exits. Do not include `DIRECT`
unless your local network can legitimately and consistently access Claude.
Do not point Claude at a broad `PROXY` group if that group contains unstable or
unknown exits.

`GROK`

Grok/X login and app endpoints are reputation-sensitive. Keep them separate
from generic proxy traffic so one bad fallback does not silently change the
front-door path.

`AI`

General AI applications can have a wider fallback set than Claude and Grok, but
the highest-quality egress should still be first.

`PROXY`, `AUTO`, and `MANUAL`

These are general-purpose groups. They are useful for ordinary browsing, but
they should not be the only control surface for Claude.

## TUN versus web proxy

System proxy mode catches proxy-aware applications. TUN mode catches more
traffic, including applications that ignore HTTP proxy settings.

That extra coverage is useful, but it also means routing mistakes have a larger
blast radius. TUN mode needs:

- Direct rules for node server IPs to avoid proxy self-loop.
- Fake-ip filters for sites that are sensitive to synthetic DNS answers.
- A reliable way to inspect live connections and policy matches.

## Success criteria

A working setup should prove these behaviors:

- `api.anthropic.com` goes through the `CLAUDE` group.
- Domestic Feishu and Tencent domains go through `CN-DIRECT`.
- Node server IPs go `DIRECT`.
- IPv6 is either intentionally supported or clearly disabled.
- Fake-ip mapped addresses are not mistaken for real public IPv6 reachability.
- Claude Code startup checks use the same local proxy endpoint as Clash Verge.

