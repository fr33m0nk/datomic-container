#!/bin/bash

add_config() {
  echo "$1=$2" | tee -a sql-transactor.properties
}

if [[ ! -z "$PG_HOST" ]]; then

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
  bin/transactor -Xmx"$XMX" -Xms"$XMS" sql-transactor.properties

else
  echo "PG_HOST cannot be empty. Terminating process"
fi
