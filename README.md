# cloudflare-d1-backup
### Simple backup tool for Cloudflare D1 databases.



Usage:

```
docker run \
  -e CLOUDFLARE_API_TOKEN="<Cloudflare API token with D1 permiossions>" \
  -e CLOUDFLARE_ACCOUNT_ID="<Cloudflare account Id>" \
  -e DATABASE_ID="<Database UUID>" \
  -e DATABASE_NAME="<database name>" \
  -e FILE_PREFIX="<filename prefix for backup files>" \
  -v <path to backup file storage>:/tmp/backup \
  ghcr.io/schack/cloudflare-d1-backup

```

