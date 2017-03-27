# pgbadger


# setup

edit docker-compose.yml

’’’
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

’’’

# RUN

’’’
docker-compose up 
’’’