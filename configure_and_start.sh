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

if [[ "${RUN_MODE}" != @(TRANSACTOR|PEER|BACKUP_DB|LIST_BACKUPS|VERIFY_BACKUP|RESTORE_DB) ]]; then
  echo "Invalid RUN_MODE: ${RUN_MODE} supplied.\nTRANSACTOR, PEER, BACKUP_DB, LIST_BACKUPS, VERIFY_BACKUP, RESTORE_DB are the only supported values."
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
  add_config "sql-driver-class" "org.postgresql.Driver"
  add_config "pid-file" "transactor.pid"
  add_config "host" "${TRANSACTOR_HOST}"
  add_config "alt-host" "${TRANSACTOR_ALT_HOST}"
  add_config "ping-host" "${TRANSACTOR_HOST}"
  add_config "ping-port" "${TRANSACTOR_HEALTHCHECK_PORT}"
  add_config "ping-concurrency" "${TRANSACTOR_HEALTHCHECK_CONCURRENCY}"
  add_config "heartbeat-interval-msec" "${TRANSACTOR_HEARTBEAT_INTERVAL_IN_MS}"
  add_config "encrypt-channel" "${TRANSACTOR_ENCRYPT_CHANNEL}"
  add_config "write-concurrency" "${TRANSACTOR_WRITE_CONCURRENCY}"
  add_config "read-concurrency" "${TRANSACTOR_READ_CONCURRENCY}"

  add_config "port" "${TRANSACTOR_PORT}"
  add_config "sql-url" "jdbc:postgresql://${PG_HOST}:${PG_PORT}/${PG_DATABASE}"
  add_config "sql-user" "${PG_USER}"
  add_config "sql-password" "${PG_PASSWORD}"
  add_config "memory-index-threshold" "${MEMORY_INDEX_THRESHOLD}"
  add_config "memory-index-max" "${MEMORY_INDEX_MAX}"
  add_config "object-cache-max" "${OBJECT_CACHE_MAX}"

  if [[ ! -z "${MEMCACHED_HOST}" ]]; then
    add_config "memcached" "${MEMCACHED_HOST}:${MEMCACHED_PORT}"
    add_config "memcached-config-timeout-msec" "${MEMCACHED_CONFIG_TIMEOUT_IN_MS}"

    if [[ ! -z "${MEMCACHED_USERNAME}" ]]; then
      add_config "memcached-username" "${MEMCACHED_USERNAME}"
    fi

    if [[ ! -z "${MEMCACHED_PASSWORD}" ]]; then
      add_config "memcached-password" "${MEMCACHED_PASSWORD}"
    fi

    if [[ "${MEMCACHED_AUTO_DISCOVERY}" = @(true|false) ]]; then
          add_config "memcached-auto-discovery" "${MEMCACHED_AUTO_DISCOVERY}"
    fi
  fi

  if [[ ! -z "${VALCACHE_PATH}" ]]; then
    add_config "valcache-path" "${VALCACHE_PATH}"

    if [[ ! -z "${VALCACHE_MAX_GB}" ]]; then
      add_config "valcache-max-gb" "${VALCACHE_MAX_GB}"
    fi
  fi

  ## Start up Datomic Transactor
  bin/transactor -Xmx"$XMX" -Xms"$XMS" ./sql-transactor.properties
fi

if [[ "${RUN_MODE}" = "PEER" ]]; then
  validate_env_vars "${DATOMIC_DB_NAME}" "DATOMIC_DB_NAME"

  extended_peer_options = "-Ddatomic.txTimeoutMsec=${PEER_TX_TIMEOUT_IN_MS} -Ddatomic.readConcurrency=${PEER_READ_CONCURRENCY}"
  if [[ ! -z "${MEMCACHED_HOST}" ]]; then
    extended_peer_options = "${extended_peer_options} -Ddatomic.memcachedServers=${MEMCACHED_HOST}:${MEMCACHED_PORT}"
    extended_peer_options = "${extended_peer_options} -Ddatomic.memcachedConfigTimeoutMsec=${MEMCACHED_CONFIG_TIMEOUT_IN_MS}"
    if [[ ! -z "${MEMCACHED_USERNAME}" ]]; then
      extended_peer_options = "${extended_peer_options} -Ddatomic.memcachedUsername=${MEMCACHED_USERNAME}"
    fi

    if [[ ! -z "${MEMCACHED_PASSWORD}" ]]; then
      extended_peer_options = "${extended_peer_options} -Ddatomic.memcachedPassword=${MEMCACHED_PASSWORD}"
    fi

    if [[ "${MEMCACHED_AUTO_DISCOVERY}" = @(true|false) ]]; then
          extended_peer_options = "${extended_peer_options} -Ddatomic.memcachedAutoDiscovery=${MEMCACHED_AUTO_DISCOVERY}"
    fi
  fi

  if [[ ! -z "${VALCACHE_PATH}" ]]; then
    extended_peer_options = "${extended_peer_options} -Ddatomic.valcachePath=${VALCACHE_PATH}"
    if [[ ! -z "${VALCACHE_MAX_GB}" ]]; then
      extended_peer_options = "${extended_peer_options} -Ddatomic.valcacheMaxGb=${VALCACHE_MAX_GB}"
    fi
  fi

  bin/run -Xmx"$XMX" -Xms"$XMS" "${extended_peer_options}" \
          -m datomic.peer-server \
          -h "${PEER_HOST}" \
          -p "${PEER_PORT}" \
          -a "${PEER_ACCESSKEY}","${PEER_SECRET}" \
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
