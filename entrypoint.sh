#!/bin/sh

set -euo pipefail

env

if [ "$1" != "pgbadger" ]; then
  set -- pgbadger "$@"
fi

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY
export AWS_DEFAULT_REGION=$AWS_S3_REGION

mkdir -p "$PGBADGER_DATA"

upload_s3 () {
  aws s3 cp --recursive $1/ s3://$2/ --include "*.html" --include "*.json" --exclude "*.bin" --exclude "*.DS_Store" --exclude "*LAST_PARSED"
  return 1
}

run_pgbadger () {

  DATE=`date +%Y-%m-%d`

  $1 --jobs $(nproc) --outdir "$PGBADGER_DATA" --incremental --start-monday --outfile "index.html"
  $1 --jobs $(nproc) --outdir "$PGBADGER_DATA" --outfile "index_$DATE.json" --extension json
  return 1
}

if [[ 1 == "${CRON}" ]]; then

  echo "run every"
  CRON_PATTERN=${CRON_PATTERN:-'0 3 * * *'}
  echo "run $CRON_PATTERN"
  echo "$CRON_PATTERN /entrypoint.sh $@" > /etc/crontabs/root
  export CRON=0
  crond -f
  
else
  echo "run one time"
  run_pgbadger $@
  upload_s3 $PGBADGER_DATA $AWS_S3_BUCKET
fi
