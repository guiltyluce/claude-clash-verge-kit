# claude-clash-verge-kit

A reproducible Clash Verge Rev / Mihomo setup for stable Claude Code usage.

This kit turns a working local pattern into a clean public project:

- Clash Verge Rev / Mihomo is the routing layer.
- A VPS node handles general proxy traffic and operational fallback.
- A clean home-broadband or residential egress handles reputation-sensitive AI front doors.
- Dedicated policy groups keep Claude, Grok, general AI, and domestic traffic separated.
- A local harness checks the proxy path before Claude is started.
- `claude-guard` can be used as the startup gate for Claude Code.

This is not an Anthropic, Claude, Clash Verge, or Mihomo official project.

## Who this is for

Use this kit if you already control or are authorized to use:

- A macOS or Windows machine running Clash Verge Rev.
- At least one VPS or proxy node for general traffic.
- Optionally, one clean home-broadband or residential egress for Claude/Grok login paths.
- A legal and compliant use case for the services you access.

The project does not provide proxy nodes, accounts, tokens, or bypass guarantees.

## Architecture

```text
Claude Code / browser / AI tools
  -> local system proxy or TUN
  -> Clash Verge Rev / Mihomo on 127.0.0.1:7897
  -> policy groups
       CN-DIRECT  -> DIRECT for Feishu, Tencent, and China traffic
       CLAUDE     -> selected clean egress candidates only
       GROK       -> selected clean egress candidates only
       AI         -> broader AI fallback set
       PROXY      -> general proxy fallback
  -> VPS or home-broadband egress
```

The important design choice is separation:

- Do not put domestic apps, Feishu, Tencent, and China traffic through AI exits.
- Do not let Claude randomly fall through to generic `PROXY` or `DIRECT`.
- Do protect node server IPs from proxy self-loop by routing them `DIRECT`.
- Do test the actual application endpoints, not only homepage or root-domain health.

## Quick start

1. Install Clash Verge Rev and enable a Mihomo core.
2. Import your own nodes into Clash Verge.
3. Copy `templates/mihomo.merge.example.yaml` into your Clash Verge merge profile.
4. Replace every `REPLACE_WITH_*` placeholder with your own values.
5. Keep the local mixed HTTP/SOCKS entry on `127.0.0.1:7897` unless you know why you are changing it.
6. Run the static project checks:

```bash
scripts/check.sh
```

7. Run a live network check on your machine:

```bash
RUN_NETWORK_CHECK=1 scripts/check.sh
```

On Windows PowerShell, use:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-network.ps1
```

8. Install and configure `claude-guard` if you want Claude Code startup gating:

```bash
CLAUDE_GUARD_PROXY=http://127.0.0.1:7897 claude-guard --precheck-only
```

## Recommended project layout

- `templates/mihomo.merge.example.yaml`: sanitized Clash Verge / Mihomo merge template.
- `templates/claude-guard.example.json`: sanitized Claude Guard config.
- `scripts/check-network.sh`: live local proxy and endpoint checks.
- `scripts/check-network.ps1`: Windows PowerShell live proxy and endpoint checks.
- `scripts/set-windows-proxy-env.ps1`: Windows user environment proxy helper.
- `scripts/check-secrets.sh`: blocks accidental publication of real node links and known private values.
- `docs/architecture.md`: why the groups are split this way.
- `docs/clash-verge-setup.md`: macOS Clash Verge setup notes.
- `docs/windows-clash-verge-setup.md`: Windows Clash Verge setup and migration notes.
- `docs/vps-and-home-egress.md`: how to model VPS and home-broadband egress safely.
- `docs/claude-guard-integration.md`: how to connect this kit with Claude Guard.
- `docs/troubleshooting.md`: common failure modes and checks.

## Safety rules

Never commit:

- Full proxy share links.
- Subscription URLs.
- UUIDs, private keys, tokens, cookies, or OAuth material.
- Real node hostnames if they are not meant to be public.
- Real home IPs or VPS IPs unless you intentionally publish them.
- Clash Verge generated runtime files from your own machine.

Use placeholders in public examples. Treat every node URL as sensitive.

## Relationship to claude-guard

`claude-guard` protects the Claude Code launch path. It checks things like
proxy availability, exit IP allowlists, TLS issuer sanity, and IPv6/fake-ip
classification.

This project configures the network layer that `claude-guard` depends on.
Use them together:

```text
claude-guard -> 127.0.0.1:7897 -> Clash Verge / Mihomo -> CLAUDE group
```

## License

MIT.
