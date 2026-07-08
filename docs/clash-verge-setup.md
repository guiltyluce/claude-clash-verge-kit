# Clash Verge Setup

This guide assumes macOS and Clash Verge Rev with a Mihomo core.

## Baseline

Recommended local listener:

```text
http://127.0.0.1:7897
```

Recommended mode:

```text
mode: rule
ipv6: false
TUN: enabled
DNS enhanced mode: fake-ip
```

These defaults mirror the intended local contract. You can change them, but
then update every wrapper, shell profile, GUI launch environment, and check
script that depends on the local proxy URL.

## Import nodes

Import your own nodes through Clash Verge. Keep the raw node material out of
this repository. The public template only shows the shape of the final config.

If you generate nodes from x-ui or another panel, use a private converter or
manual import flow and then sanitize the exported config before sharing it.

## Apply merge template

1. Open Clash Verge Rev.
2. Go to Profiles or Settings, depending on your version.
3. Add the contents of `templates/mihomo.merge.example.yaml` as a merge profile.
4. Replace all placeholders.
5. Reload the profile.
6. Confirm that the final runtime config contains `CLAUDE`, `GROK`, `AI`, and `CN-DIRECT`.

## Align terminal environment

For shell-launched tools:

```bash
export HTTP_PROXY=http://127.0.0.1:7897
export HTTPS_PROXY=http://127.0.0.1:7897
export ALL_PROXY=socks5://127.0.0.1:7897
export NO_PROXY=127.0.0.1,localhost,::1,.local
```

Some tools prefer HTTP CONNECT and may not accept a SOCKS value. When in doubt,
use explicit tool-specific HTTP proxy variables.

## Align GUI applications

Finder, Dock, VS Code, and other GUI-launched applications may inherit proxy
state from `launchctl`, not from your current terminal.

Check:

```bash
launchctl getenv HTTP_PROXY
launchctl getenv HTTPS_PROXY
launchctl getenv ALL_PROXY
```

Set only after you are sure Clash Verge is stable:

```bash
launchctl setenv HTTP_PROXY http://127.0.0.1:7897
launchctl setenv HTTPS_PROXY http://127.0.0.1:7897
launchctl setenv NO_PROXY 127.0.0.1,localhost,::1,.local
```

Restart GUI applications after changing `launchctl` values.

## Validate

Run:

```bash
RUN_NETWORK_CHECK=1 scripts/check.sh
```

Then inspect Clash Verge logs or connections for:

- Claude domains matching `CLAUDE`.
- Feishu/Tencent domains matching `CN-DIRECT`.
- Node server IPs matching `DIRECT`.

