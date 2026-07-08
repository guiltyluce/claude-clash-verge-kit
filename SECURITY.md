# Security Policy

This project is designed to be public and sanitized.

## Sensitive material

Do not publish:

- Proxy share links or subscription URLs.
- UUIDs, private keys, access tokens, OAuth state, cookies, or account secrets.
- Real node IPs or domains unless they are intentionally public.
- Home-broadband IPs unless you explicitly want them public.
- Generated Clash Verge runtime state from your own machine.

## Reporting issues

If you find a leaked secret in this repository:

1. Open a private security advisory if available.
2. If not available, contact the repository owner directly.
3. Rotate the exposed secret immediately.

Do not include the full secret value in public issues.

## Design boundary

The kit focuses on user-controlled routing reliability and preflight checks.
It does not intercept TLS, extract tokens, modify Claude requests, or provide
instructions for account abuse.

