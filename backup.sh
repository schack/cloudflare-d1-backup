#!/bin/sh

# Check all required environment vars are set.
for var in CLOUDFLARE_API_TOKEN CLOUDFLARE_ACCOUNT_ID DATABASE_NAME DATABASE_ID; do
  eval "value=\${$var:-}"
  if [ -z "$value" ]; then
    echo "Error: $var is not set." >&2
    exit 1
  fi
done

# Use default filename prefix if not set.
: "${FILE_PREFIX:=d1-database}"

# Create configuration for wrangler.
cat << EOF > /tmp/wrangler.toml
name = "cloudflare_d1_backup"
[[d1_databases]]
binding = "DB"
database_name = "${DATABASE_NAME}"
database_id = "${DATABASE_ID}"
EOF

# Optional TABLES env var (space-separated). When set, expands to
# `--table X --table Y ...` so the export skips everything else — needed for
# databases containing FTS5 virtual tables, which wrangler can't dump cleanly.
TABLE_FLAGS=""
for t in ${TABLES:-}; do
  TABLE_FLAGS="$TABLE_FLAGS --table $t"
done

FILENAME="/tmp/backup/${FILE_PREFIX}-$(date +'%Y-%m-%d-%H-%M').sql"
# TABLE_FLAGS must word-split into separate --table arguments; keep it unquoted.
# shellcheck disable=SC2086
node_modules/wrangler/bin/wrangler.js -c /tmp/wrangler.toml d1 export --remote "${DATABASE_NAME}" ${TABLE_FLAGS} --output "$FILENAME"
gzip "$FILENAME"
