FROM alpine:3.19.1 as build

ARG DATOMIC_VERSION

RUN curl -fsSL -o datomic-pro.zip https://datomic-pro-downloads.s3.amazonaws.com/${DATOMIC_VERSION}/datomic-pro-${DATOMIC_VERSION}.zip -O
RUN unzip -qq ./datomic-pro.zip && true
RUN rm -rf ./datomic-pro.zip
COPY /artifacts/logback.xml /datomic-pro/bin/logback.xml
RUN curl -fsSL -o /datomic-pro/lib/logstash-logback-encoder-7.4.jar https://repo1.maven.org/maven2/net/logstash/logback/logstash-logback-encoder/7.4/logstash-logback-encoder-7.4.jar

FROM eclipse-temurin:21.0.2_13-jdk-jammy

COPY --from=build /datomic-pro /datomic-pro
COPY configure_and_start.sh /datomic-pro/configure_and_start.sh

ENV RUN_MODE "TRANSACTOR"
ENV RUN_ENV "PROD"
ENV DATOMIC_HOST "localhost"
ENV DATOMIC_PORT "4334"
ENV PG_HOST ""
ENV PG_PORT "5432"
ENV PG_USER "datomic"
ENV PG_DATABASE "datomic"
ENV PG_PASSWORD "datomic"
ENV XMS "4g"
ENV XMX "4g"
ENV LOG_LEVEL "INFO"

WORKDIR /datomic-pro
RUN chmod a+x configure_and_start.sh
ENTRYPOINT ./configure_and_start.sh
