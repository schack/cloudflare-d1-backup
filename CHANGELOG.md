# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Release versions track
the bundled Cloudflare wrangler release (the image tag); each wrangler bump is
auto-released as `v<wrangler-version>`. Changes to this tool's own code ship
under the wrangler version current at the time and are noted here.

## [Unreleased]

## [4.94.0] - 2026-06-22

First versioned release, focused on supply-chain trustworthiness (ships with
wrangler 4.94.0).

### Added
- Keyless cosign signatures on every published image (Sigstore + GitHub OIDC).
- SBOM and SLSA provenance attestations attached to the image (buildx).
- Multi-architecture images: `linux/amd64` and `linux/arm64`.
- Immutable `sha-<commit>` image tags for traceability (alongside `latest` and
  the wrangler-version tag).
- GitHub Releases cut from `v*` git tags.
- CI lint gate: hadolint (Dockerfile) and shellcheck (`backup.sh`).
- Trivy image vulnerability scanning (report-only; results in the Security tab).
- OpenSSF Scorecard workflow and `SECURITY.md` disclosure policy.

### Changed
- The image is now pushed using the ephemeral `GITHUB_TOKEN` instead of a
  long-lived personal access token.
- Base image and all GitHub Actions are pinned by digest / commit SHA.
- Workflow runs with least-privilege, per-job `permissions`.

### Security
- **Breaking:** the container now runs as the non-root `node` user (uid 1000).
  The host directory mounted at `/tmp/backup` must be writable by uid 1000, e.g.
  `chown 1000:1000 <host-backup-dir>` (or `chmod 0777`) before running.
