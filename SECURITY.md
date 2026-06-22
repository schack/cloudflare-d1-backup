# Security Policy

## Supported versions

This project ships a single rolling container image. Security fixes are applied
to the latest release only; always run the most recent `:latest` (or a pinned
digest of it). Older tags are not patched.

## Reporting a vulnerability

Please report security issues privately — do **not** open a public issue.

- Preferred: GitHub private vulnerability reporting via the **Security** tab →
  **Report a vulnerability** (https://github.com/schack/cloudflare-d1-backup/security/advisories/new).
- Alternatively, email henrik@schack.dk.

Please include reproduction steps and affected version/digest. You can expect an
acknowledgement within a few days. Once a fix is available, a new image is
published and the advisory disclosed.

## Handling of credentials

This tool requires a Cloudflare API token (`CLOUDFLARE_API_TOKEN`). Scope it to
**D1 read** only and pass it as an environment variable / secret at runtime — it
is never written to the image or to backup files. The container runs as a
non-root user (uid 1000).

## Verifying releases

Release images are signed with Sigstore cosign (keyless) and ship SBOM and SLSA
provenance attestations. See the "Verifying the image" section of the README for
the exact verification commands.
