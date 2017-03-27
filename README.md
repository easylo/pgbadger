# pgbadger

A fast PostgreSQL log analyzer with S3 upload

# setup

edit docker-compose.yml

```bash
...
    environment:
      PGBADGER_DATA: "/data"
      AWS_ACCESS_KEY: "MY_AWS_ACCESS_KEY"
      AWS_SECRET_KEY: "MY_AWS_SECRET_KEY"
      AWS_S3_REGION: "eu-west-1"
      AWS_S3_BUCKET: "pgbadger/www"
    volumes:
      - "./pg_log:/var/log/postgresql"
      - "./data:/data"

```

# RUN

```bash
docker-compose up 
```