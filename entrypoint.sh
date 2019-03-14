#!/bin/sh

set -euo pipefail

PGBADGER_PREFIX="${PGBADGER_PREFIX:-' '}"

if [ "$1" != "pgbadger" ]; then
  set -- pgbadger "$@"   
fi

# if [ ! -z "$PGBADGER_PREFIX" -a "$PGBADGER_PREFIX" != " " ]; then
#       # PGBADGER_PREFIX=" $PGBADGER_PREFIX"
#       # "${@/pgbadger/$PGBADGER_PREFIX}"
#       # set -- "pgbadger " "$@" 
    
# fi

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY
export AWS_DEFAULT_REGION=$AWS_S3_REGION

export nproc=4

mkdir -p "$PGBADGER_DATA"

upload_s3 () {
  aws s3 cp --recursive $1/ s3://$2/ --include "*.html" --include "*.json" --exclude "*.bin" --exclude "*.DS_Store" --exclude "*LAST_PARSED"
  return 0
}

run_pgbadger () {


  $@ --prefix "$PGBADGER_PREFIX" --jobs $nproc --outdir "$PGBADGER_DATA" --disable-temporary --incremental --start-monday --outfile "index.html"
  # DATE=`date +%Y/%m/%d`
  # mkdir -p "$PGBADGER_DATA/${DATE}"
  # $@ --prefix "$PGBADGER_PREFIX" --jobs $nproc --disable-temporary  --start-monday --outfile "$PGBADGER_DATA/${DATE}/index.json" --extension json --prettify-json

  return 0
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
