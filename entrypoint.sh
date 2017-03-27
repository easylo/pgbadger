#!/bin/sh

set -euo pipefail

if [ "$1" != "pgbadger" ]; then
  set -- pgbadger "$@"
fi

DATE=`date +%Y-%m-%d`

mkdir -p "$PGBADGER_DATA"

$@ --jobs $(nproc) --outdir "$PGBADGER_DATA" --incremental --start-monday --outfile "index.html"
$@ --jobs $(nproc) --outdir "$PGBADGER_DATA" --outfile "index_$DATE.json" --extension json

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY
export AWS_DEFAULT_REGION=$AWS_S3_REGION

aws s3 cp --recursive $PGBADGER_DATA/ s3://$AWS_S3_BUCKET/ --include "*.html" --include "*.json" --exclude "*.bin" --exclude "*.DS_Store" --exclude "*LAST_PARSED"
