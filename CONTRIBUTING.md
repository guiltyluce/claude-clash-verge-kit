# Contributing

Thanks for helping make this kit safer and easier to reproduce.

Before opening a pull request:

1. Do not include real proxy links, UUIDs, tokens, subscription URLs, cookies, or private IP inventory.
2. Keep examples sanitized with `REPLACE_WITH_*` placeholders and RFC documentation IP ranges.
3. Run:

```bash
scripts/check.sh
```

4. If your change affects live network checks, also run:

```bash
RUN_NETWORK_CHECK=1 scripts/check.sh
```

## Scope

Good contributions:

- Safer Mihomo templates.
- Better diagnostics for TUN, fake-ip, DNS, and policy groups.
- Platform notes for macOS and Clash Verge Rev.
- Clear troubleshooting steps with reproducible checks.

Out of scope:

- Publishing private nodes or subscriptions.
- Account sharing or credential handling.
- Claims that any route can bypass service-side enforcement.
- MITM, TLS interception, token extraction, or request rewriting.

