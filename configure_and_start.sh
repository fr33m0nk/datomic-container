#!/bin/bash

validate_env_vars() {
  if [[ -z $1 ]]; then
    echo "$2 environment variable must be supplied"
    exit 1
  fi
}

add_config() {
  echo "$1=$2" | tee -a sql-transactor.properties
}

## Validations for mandatory environment variable
validate_env_vars "${PG_HOST}" "PG_HOST"
validate_env_vars "${PG_USER}" "PG_USER"
validate_env_vars "${PG_PASSWORD}" "PG_PASSWORD"
validate_env_vars "${PG_DATABASE}" "PG_DATABASE"

if [[ "${RUN_MODE}" = "TRANSACTOR" ]]; then

  ## Prepare config file for Datomic Transactor
  add_config "protocol" "sql"
  add_config "host" "${TRANSACTOR_HOST}"
  add_config "port" "${TRANSACTOR_PORT}"
  add_config "sql-url" "jdbc:postgresql://${PG_HOST}:${PG_PORT}/${PG_DATABASE}"
  add_config "sql-user" "${PG_USER}"
  add_config "sql-password" "${PG_PASSWORD}"
  add_config "sql-driver-class" "org.postgresql.Driver"
  add_config "memory-index-threshold" "32m"
  add_config "memory-index-max" "512m"
  add_config "object-cache-max" "1g"

  ## Start up Datomic Transactor
  bin/transactor -Xmx"$XMX" -Xms"$XMS" sql-transactor.properties
fi

if [[ "${RUN_MODE}" = "PEER" ]]; then
  validate_env_vars "${DATOMIC_DB_NAME}" "DATOMIC_DB_NAME"

  bin/run -m datomic.peer-server\
          -h "${PEER_HOST}"\
          -p "${PEER_PORT}"\
          -a "${PEER_ACCESSKEY}","${PEER_SECRET}"\
          -d ${DATOMIC_DB_NAME},"datomic:sql://${DATOMIC_DB_NAME}?jdbc:postgresql://${PG_HOST}:${PG_PORT}/${PG_DATABASE}?user=${PG_USER}&password=${PG_PASSWORD}"
fi
