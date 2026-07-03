# cloudflare-d1-backup

[![Docker Image CI](https://github.com/schack/cloudflare-d1-backup/actions/workflows/docker-image.yml/badge.svg)](https://github.com/schack/cloudflare-d1-backup/actions/workflows/docker-image.yml)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/schack/cloudflare-d1-backup/badge)](https://scorecard.dev/viewer/?uri=github.com/schack/cloudflare-d1-backup)

### Simple backup tool for Cloudflare D1 databases.


Usage:

```
docker run --rm \
  -e CLOUDFLARE_API_TOKEN="<Cloudflare API token with D1 permissions>" \
  -e CLOUDFLARE_ACCOUNT_ID="<Cloudflare account Id>" \
  -e DATABASE_ID="<Database UUID>" \
  -e DATABASE_NAME="<database name>" \
  -e FILE_PREFIX="<filename prefix for backup files>" \
  -v <path to backup file storage>:/tmp/backup \
  ghcr.io/schack/cloudflare-d1-backup
```

The container runs as the non-root `node` user (uid 1000), so the host
directory mounted at `/tmp/backup` must be writable by uid 1000:

```
chown 1000:1000 <path to backup file storage>
```

### Environment variables

| Variable | Required | Description |
|---|---|---|
| `CLOUDFLARE_API_TOKEN` | yes | API token with D1 read permission. |
| `CLOUDFLARE_ACCOUNT_ID` | yes | Cloudflare account ID. |
| `DATABASE_ID` | yes | D1 database UUID. |
| `DATABASE_NAME` | yes | D1 database name. |
| `FILE_PREFIX` | no | Backup filename prefix. Defaults to `d1-database`. |
| `TABLES` | no | Space-separated list of tables to export. When unset, all tables are exported. |

### When to use `TABLES`

`wrangler d1 export` doesn't handle SQLite virtual tables cleanly (FTS5,
R-Tree, etc.) — it tries to dump their internal shadow tables as regular
tables and fails. Set `TABLES` to the list of *real* user tables you want
backed up; everything else is skipped:

```
-e TABLES="users posts comments"
```

Virtual table indexes are derived data — they regenerate automatically when
you re-apply your schema migrations and re-import the row data, so excluding
them from the backup is safe.

### Verifying the image

Every published image is multi-arch (`linux/amd64` + `linux/arm64`), signed with
Sigstore cosign (keyless), and ships SBOM + SLSA provenance attestations.

Verify the signature (https://docs.sigstore.dev/cosign/verifying/verify/):

```
cosign verify ghcr.io/schack/cloudflare-d1-backup:latest \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github.com/schack/cloudflare-d1-backup/\.github/workflows/docker-image\.yml@.*'
```

Inspect the attached attestations and platforms:

```
docker buildx imagetools inspect ghcr.io/schack/cloudflare-d1-backup:latest
cosign download sbom ghcr.io/schack/cloudflare-d1-backup:latest
```

### Image tags and pinning

| Tag | Mutability | Use it for |
|---|---|---|
| `latest` | rolling | always the newest build |
| `<wrangler-version>` (e.g. `4.94.0`) | rolling | the newest build bundling that wrangler version — it keeps receiving base-image and dependency security rebuilds within the same version line |
| `sha-<commit>` | immutable | a specific build |

Each push to `main` builds and publishes an image. The `<wrangler-version>` tag
matches the bundled wrangler release and **moves forward** as non-wrangler
changes (base image, dependency, or workflow updates) are merged, so it is not a
fixed point. A GitHub Release `v<wrangler-version>` is cut once, marking when
that version line started.

**For reproducible deployments, pin by digest** (or by an immutable
`sha-<commit>` tag), not by `latest` or `<wrangler-version>`:

```
docker run ... ghcr.io/schack/cloudflare-d1-backup@sha256:<digest>
```

Resolve the current digest with `docker buildx imagetools inspect`.

### Image size (why some wrangler binaries are stubbed)

`wrangler` hard-depends on several large native binaries that only matter for
local development (`wrangler dev` / `deploy`): the `workerd` Workers runtime
(~120 MB), the `esbuild` bundler (~10 MB), and `libvips` for `sharp` image
processing (~15 MB). A remote export (`d1 export --remote`) is pure Cloudflare
REST API traffic and never spawns any of them.

wrangler resolves these binaries' *paths* at startup but only *executes* them
for local emulation/bundling, so the Dockerfile build stage truncates the files
to 0 bytes (it does **not** delete them — `require.resolve` must still find
them). This cuts the image roughly in half (~500 MB → ~290 MB) with no effect on
the backup.

If a future wrangler version starts needing one of these on the export path, the
export will fail loudly with a clear "could not be found" error — so don't
"fix" a broken export by removing the prune step in the Dockerfile without first
checking whether wrangler's export code path changed.

### Security

See SECURITY.md for the vulnerability disclosure policy.
