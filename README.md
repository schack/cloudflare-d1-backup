# cloudflare-d1-backup
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

