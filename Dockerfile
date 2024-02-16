FROM alpine:3.19.1 as build

ARG DATOMIC_VERSION
## Validations for mandatory build arg
RUN [ ! -z "${DATOMIC_VERSION}" ]

RUN apk add ca-certificates && update-ca-certificates
RUN apk add --no-cache --update \
        curl \
        unzip
RUN curl -fsSL -o datomic-pro.zip https://datomic-pro-downloads.s3.amazonaws.com/${DATOMIC_VERSION}/datomic-pro-${DATOMIC_VERSION}.zip
RUN unzip -qq ./datomic-pro.zip -d / && true
RUN mv "/datomic-pro-${DATOMIC_VERSION}" /datomic-pro && true
RUN curl -fsSL -o /datomic-pro/lib/logstash-logback-encoder-7.3.jar https://repo1.maven.org/maven2/net/logstash/logback/logstash-logback-encoder/7.3/logstash-logback-encoder-7.3.jar
COPY ./artifacts/logback.xml /datomic-pro/bin/logback.xml
RUN rm -rf ./datomic-pro.zip

FROM eclipse-temurin:21.0.2_13-jdk-jammy

COPY --from=build /datomic-pro /datomic-pro
COPY configure_and_start.sh /datomic-pro/configure_and_start.sh

ENV RUN_MODE "TRANSACTOR"
ENV RUN_ENV "PROD"
ENV TRANSACTOR_HOST "0.0.0.0"
ENV TRANSACTOR_ALT_HOST "127.0.0.1"
ENV TRANSACTOR_PORT "4334"
ENV TRANSACTOR_HEALTHCHECK_PORT "9999"
ENV TRANSACTOR_HEALTHCHECK_CONCURRENCY "6"
ENV TRANSACTOR_HEARTBEAT_INTERVAL_IN_MS "5000"
ENV TRANSACTOR_ENCRYPT_CHANNEL "true"
ENV TRANSACTOR_WRITE_CONCURRENCY "4"
ENV TRANSACTOR_READ_CONCURRENCY "8"
ENV MEMORY_INDEX_THRESHOLD "32m"
ENV MEMORY_INDEX_MAX "512m"
ENV OBJECT_CACHE_MAX "1g"
ENV XMS "4g"
ENV XMX "4g"
ENV LOG_LEVEL "INFO"
ENV MEMCACHED_HOST ""
ENV MEMCACHED_PORT "11211"
ENV MEMCACHED_CONFIG_TIMEOUT_IN_MS "100"
ENV MEMCACHED_AUTO_DISCOVERY ""
ENV MEMCACHED_USERNAME ""
ENV MEMCACHED_PASSWORD ""
ENV VALCACHE_PATH ""
ENV VALCACHE_MAX_GB ""
ENV PG_PORT "5432"
ENV PG_HOST ""
ENV PG_DATABASE ""
ENV PG_USER ""
ENV PG_PASSWORD ""

ENV PEER_HOST "0.0.0.0"
ENV PEER_PORT "8998"
ENV PEER_ACCESSKEY "myaccesskey"
ENV PEER_SECRET "mysecret"
ENV DATOMIC_DB_NAME ""
ENV PEER_TX_TIMEOUT_IN_MS "10000"
ENV PEER_READ_CONCURRENCY "8"

ENV BACKUP_S3_BUCKET_URI ""
ENV DATOMIC_DB_URI ""
ENV VERIFY_ALL_SEGMENTS "true"
ENV BACKUP_TIME_IN_LONG ""


WORKDIR /datomic-pro
RUN chmod a+x configure_and_start.sh
ENTRYPOINT ./configure_and_start.sh
