FROM alpine:edge

LABEL maintainer="Laurent RICHARD <easylo@gmail.com>"

RUN apk update && \
    apk add --update openssl python coreutils perl && \
    apk add -X http://dl-cdn.alpinelinux.org/alpine/edge/testing perl-json-xs gzip

WORKDIR /src

ENV PGBADGER_DATA=/data
ENV PGBADGER_VERSION=10.3

RUN mkdir -p /data /opt
RUN wget --no-check-certificate -O - https://github.com/darold/pgbadger/archive/v${PGBADGER_VERSION}.tar.gz | tar -zxvf - -C /opt
RUN mv /opt/pgbadger-${PGBADGER_VERSION}/pgbadger /usr/local/bin/pgbadger
RUN chmod +x /usr/local/bin/pgbadger

RUN apk add --update perl-text-csv perl-dev make g++ 
RUN /usr/bin/perl -MCPAN -e'install Text::CSV_XS'
RUN /usr/bin/perl -MCPAN -e'install JSON::XS'

WORKDIR /opt
# add aws cli
RUN wget --no-check-certificate "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
RUN unzip awscli-bundle.zip
RUN ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME $PGBADGER_DATA

ENTRYPOINT ["/entrypoint.sh"]

CMD ["pgbadger"]
