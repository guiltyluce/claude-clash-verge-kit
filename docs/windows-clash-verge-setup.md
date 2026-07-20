# Windows Clash Verge Setup

This guide is for moving the routing pattern to a Windows desktop or remote
Windows machine.

## What can move

Portable:

- Mihomo rules and policy groups.
- Sanitized merge template shape.
- Your private node overlay, kept outside this repository.
- Claude, Grok, AI, and domestic routing intent.
- Local proxy contract such as `http://127.0.0.1:7897`.

Not portable as-is:

- macOS `launchctl` state.
- macOS network service proxy settings.
- macOS TUN helper authorization.
- Browser login sessions, OAuth state, and local keychain state.
- Generated Clash Verge runtime files copied blindly from another OS.

## Recommended Windows shape

```text
Claude Code / browser / AI tools
  -> Windows system proxy, app proxy, or TUN
  -> Clash Verge Rev / Mihomo on 127.0.0.1:7897
  -> CLAUDE / GROK / AI / CN-DIRECT groups
  -> VPS or home-broadband egress
```

Keep the same local listener unless you have a reason to change it:

```text
http://127.0.0.1:7897
```

## Install Clash Verge Rev

1. Install the Windows build of Clash Verge Rev.
2. Enable or install the service mode if TUN requires it.
3. Import your own private node profile.
4. Add the merge template from `templates/mihomo.merge.example.yaml`.
5. Replace all `REPLACE_WITH_*` placeholders in your private copy.
6. Reload the profile.

Do not paste private node links into this public repository.

## TUN notes on Windows

TUN on Windows usually needs an installed service or administrator approval.
After enabling TUN, verify:

- The local mixed port still listens on `127.0.0.1:7897`.
- Claude domains match the `CLAUDE` group.
- Feishu/Tencent/domestic domains match `CN-DIRECT`.
- Node server IPs match `DIRECT` to avoid proxy self-loop.
- DNS fake-ip behavior does not break daily-work applications.

If TUN causes broad breakage, first switch to system proxy mode, prove the
policy groups, then re-enable TUN.

## Environment variables for CLI tools

Windows GUI proxy settings do not automatically cover every CLI tool. Set user
environment variables for shells, Claude Code, Codex, and development tools:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/set-windows-proxy-env.ps1
```

Open a new PowerShell window after setting user environment variables.

To use a different local port:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/set-windows-proxy-env.ps1 -ProxyUrl "http://127.0.0.1:7897"
```

The helper sets both uppercase and lowercase proxy variables because Windows
toolchains differ in what they read.

## WinHTTP

Some Windows components use WinHTTP instead of user environment variables or
browser proxy settings.

Check:

```powershell
netsh winhttp show proxy
```

Only set WinHTTP explicitly if you know a target tool needs it:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/set-windows-proxy-env.ps1 -ApplyWinHttp
```

WinHTTP changes may require an administrator shell.

## Validate

Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-network.ps1
```

Expected signs:

- Exit IP is returned through `http://127.0.0.1:7897`.
- `api.anthropic.com` returns a reachable HTTP code through the proxy.
- Windows user proxy environment points at `127.0.0.1:7897`.
- WinHTTP state is known, even if it is intentionally direct.

Then open Clash Verge's connection view and confirm live policy matches.

## Migration checklist

1. Install Clash Verge Rev on Windows.
2. Import private nodes.
3. Apply private merge profile based on `templates/mihomo.merge.example.yaml`.
4. Enable rule mode.
5. Enable TUN only after system proxy mode works.
6. Run `scripts/set-windows-proxy-env.ps1`.
7. Open a new terminal.
8. Run `scripts/check-network.ps1`.
9. Run Claude Guard precheck if used.
10. Verify real Claude/Grok endpoints in the browser or CLI.

