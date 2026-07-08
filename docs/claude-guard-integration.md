# Claude Guard Integration

This kit is the network layer. Claude Guard is the startup gate.

Use them together:

```text
claude-guard
  -> http://127.0.0.1:7897
  -> Clash Verge / Mihomo
  -> CLAUDE group
  -> selected clean egress
```

## Example config

Copy:

```bash
cp templates/claude-guard.example.json ~/.safe-claude-official.json
```

Edit:

- `command`: absolute path to the original Claude CLI.
- `allowed_ips`: your expected egress IPs.
- `allowed_cidrs`: your expected egress CIDRs, if stable.
- `proxy`: usually `http://127.0.0.1:7897`.

## Environment

```bash
export CLAUDE_GUARD_CONFIG=~/.safe-claude-official.json
export CLAUDE_GUARD_PROXY=http://127.0.0.1:7897
```

Precheck:

```bash
claude-guard --precheck-only
```

Launch:

```bash
claude-guard
```

## IPv6 and fake-ip

In Mihomo fake-ip mode, a failed or surprising IPv6 check may show an
IPv4-mapped fake-ip shape such as:

```text
::ffff:198.18.x.x
```

That shape is not proof of real public IPv6 reachability. A correct guard should
classify the returned address before blocking startup.

## Keep profiles separate

Use a clean official Claude profile for Claude Code and keep any legacy proxy or
third-party provider profile separate. Do not rewrite a working shared profile
when a dedicated `CLAUDE_CONFIG_DIR` or guard config can isolate the official
path.

