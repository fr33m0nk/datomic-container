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

datomic_uri() {
  echo "datomic:sql://${DATOMIC_DB_NAME}?jdbc:postgresql://${PG_HOST}:${PG_PORT}/${PG_DATABASE}?user=${PG_USER}&password=${PG_PASSWORD}"
}

if [[ "${RUN_MODE}" =~ ^(TRANSACTOR|PEER|BACKUP|RESTORE)$ ]]; then
  echo "Invalid RUN_MODE supplied.\nTRANSACTOR and PEER are the only supported values."
  exit 1
fi

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
          -d "${DATOMIC_DB_NAME}",$(datomic_uri)
fi

if [[ "${RUN_MODE}" = "BACKUP_DB" ]]; then
  validate_env_vars "${BACKUP_S3_BUCKET_URI}" "BACKUP_S3_BUCKET_URI"
  validate_env_vars "${DATOMIC_DB_NAME}" "DATOMIC_DB_NAME"

  bin/datomic -Xmx"$XMX" -Xms"$XMS" backup-db $(datomic_uri) "$BACKUP_S3_BUCKET_URI"
fi

if [[ "${RUN_MODE}" = "LIST_BACKUPS" ]]; then
  validate_env_vars "${BACKUP_S3_BUCKET_URI}" "BACKUP_S3_BUCKET_URI"

  bin/datomic -Xmx"$XMX" -Xms"$XMS" list-backups "$BACKUP_S3_BUCKET_URI"
fi

if [[ "${RUN_MODE}" = "VERIFY_BACKUP" ]]; then
  validate_env_vars "${BACKUP_S3_BUCKET_URI}" "BACKUP_S3_BUCKET_URI"
  validate_env_vars "${BACKUP_TIME_IN_LONG}" "BACKUP_TIME_IN_LONG"

  if [[ -z "${VERIFY_ALL_SEGMENTS}" ]]; then
    bin/datomic -Xmx"$XMX" -Xms"$XMS" verify-backup "${BACKUP_S3_BUCKET_URI}" "false" "${BACKUP_TIME_IN_LONG}"
  else
    bin/datomic -Xmx"$XMX" -Xms"$XMS" verify-backup "${BACKUP_S3_BUCKET_URI}" "true" "${BACKUP_TIME_IN_LONG}"
  fi
fi

if [[ "${RUN_MODE}" = "RESTORE_DB" ]]; then
  validate_env_vars "${BACKUP_S3_BUCKET_URI}" "BACKUP_S3_BUCKET_URI"
  validate_env_vars "${DATOMIC_DB_NAME}" "DATOMIC_DB_NAME"

  if [[ -z "${RESTORE_TIME_IN_LONG}" ]]; then
    bin/datomic -Xmx"$XMX" -Xms"$XMS" restore-db "${BACKUP_S3_BUCKET_URI}" $(datomic_uri)
  else
    bin/datomic -Xmx"$XMX" -Xms"$XMS" restore-db "${BACKUP_S3_BUCKET_URI}" $(datomic_uri)
  fi
fi
