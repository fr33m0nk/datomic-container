# Container build file for Datomic Database with PostgreSQL backend

## Image build arg:
| Build argument    | Default value                                                                    |
|-------------------|:---------------------------------------------------------------------------------|
| `DATOMIC_VERSION` | **None, provided by user**                                                       |
|                   | Check [Datomic Release](https://docs.datomic.com/pro/releases.html) for versions |

## Same container image can be run as a Transactor or Peer
- This is controlled by image environment variable `RUN_MODE`
- This environment variable needs to be passed when running the image
- Possible values are:
  - `TRANSACTOR`
  - `PEER`
  - `BACKUP_DB`
  - `LIST_BACKUPS`
  - `VERIFY_BACKUP` 
  - `RESTORE_DB` 
- Defaults to `TRANSACTOR`


## Container environment variables

| Environment variable                | Applies to `RUN_MODE`                                      | Supported values                                                                 | Default value              |
|-------------------------------------|:-----------------------------------------------------------|:---------------------------------------------------------------------------------|----------------------------|
| RUN_MODE                            | Starts Datomic as Transactor or Peer                       | `TRANSACTOR`, `PEER`, `BACKUP_DB`, `LIST_BACKUPS`, `VERIFY_BACKUP`, `RESTORE_DB` | `TRANSACTOR`               |
| TRANSACTOR_HOST                     | `TRANSACTOR`                                               |                                                                                  | `0.0.0.0`                  |
| TRANSACTOR_ALT_HOST                 | `TRANSACTOR`                                               |                                                                                  | `127.0.0.1`                |
| TRANSACTOR_PORT                     | `TRANSACTOR`                                               |                                                                                  | `4334`                     |
| TRANSACTOR_HEALTHCHECK_PORT         | `TRANSACTOR`                                               |                                                                                  | `9999`                     |
| TRANSACTOR_HEALTHCHECK_CONCURRENCY  | `TRANSACTOR`                                               |                                                                                  | `6`                        |
| TRANSACTOR_HEARTBEAT_INTERVAL_IN_MS | `TRANSACTOR`                                               |                                                                                  | `5000`                     |
| TRANSACTOR_ENCRYPT_CHANNEL          | `TRANSACTOR`                                               |                                                                                  | `true`                     |
| TRANSACTOR_WRITE_CONCURRENCY        | `TRANSACTOR`                                               |                                                                                  | `4`                        |
| TRANSACTOR_READ_CONCURRENCY         | `TRANSACTOR`                                               |                                                                                  | `8`                        |
| MEMORY_INDEX_THRESHOLD              | `TRANSACTOR`                                               |                                                                                  | `32m`                      |
| MEMORY_INDEX_MAX                    | `TRANSACTOR`                                               |                                                                                  | `512m`                     |
| OBJECT_CACHE_MAX                    | `TRANSACTOR`                                               |                                                                                  | `1g`                       |
| MEMCACHED_HOST                      | `TRANSACTOR` (optional), `PEER` (optional)                 |                                                                                  | **None, provided by user** |
| MEMCACHED_PORT                      | `TRANSACTOR` (optional), `PEER` (optional)                 |                                                                                  | `11211`                    |
| MEMCACHED_CONFIG_TIMEOUT_IN_MS      | `TRANSACTOR` (optional), `PEER` (optional)                 |                                                                                  | `100`                      |
| MEMCACHED_AUTO_DISCOVERY            | `TRANSACTOR` (optional), `PEER` (optional)                 |                                                                                  | **None, provided by user** |
| MEMCACHED_USERNAME                  | `TRANSACTOR` (optional), `PEER` (optional)                 |                                                                                  | **None, provided by user** |
| MEMCACHED_PASSWORD                  | `TRANSACTOR` (optional), `PEER` (optional)                 |                                                                                  | **None, provided by user** |
| VALCACHE_PATH                       | `TRANSACTOR` (optional), `PEER` (optional)                 |                                                                                  | **None, provided by user** |
| VALCACHE_MAX_GB                     | `TRANSACTOR` (optional), `PEER` (optional)                 |                                                                                  | **None, provided by user** |
| XMS                                 | `TRANSACTOR`, `PEER`, `BACKUP_DB`, `RESTORE_DB`            |                                                                                  | `4g`                       |
| XMX                                 | `TRANSACTOR`, `PEER`, `BACKUP_DB`, `RESTORE_DB`            |                                                                                  | `4g`                       |
| LOG_LEVEL                           | `TRANSACTOR`, `PEER`, `BACKUP_DB`, `RESTORE_DB`            |                                                                                  | `INFO`                     |
| PG_PORT                             | `TRANSACTOR`, `PEER`, `BACKUP_DB`, `RESTORE_DB`            |                                                                                  | `5432`                     |
| PG_HOST                             | `TRANSACTOR`, `PEER`, `BACKUP_DB`, `RESTORE_DB`            |                                                                                  | **None, provided by user** |
| PG_USER                             | `TRANSACTOR`, `PEER`, `BACKUP_DB`, `RESTORE_DB`            |                                                                                  | **None, provided by user** |
| PG_PASSWORD                         | `TRANSACTOR`, `PEER`, `BACKUP_DB`, `RESTORE_DB`            |                                                                                  | **None, provided by user** |
| PG_DATABASE                         | `TRANSACTOR`, `PEER`, `BACKUP_DB`, `RESTORE_DB`            |                                                                                  | **None, provided by user** |
| PEER_HOST                           | `PEER`                                                     |                                                                                  | `0.0.0.0`                  |
| PEER_PORT                           | `PEER`                                                     |                                                                                  | `8998`                     |
| PEER_ACCESSKEY                      | `PEER`                                                     |                                                                                  | `myaccesskey`              |
| PEER_SECRET                         | `PEER`                                                     |                                                                                  | `mysecret`                 |
| PEER_TX_TIMEOUT_IN_MS               | `PEER`                                                     |                                                                                  | `10000`                    |
| PEER_READ_CONCURRENCY               | `PEER`                                                     |                                                                                  | `8`                        |
| DATOMIC_DB_NAME                     | `PEER`, `BACKUP_DB`, `RESTORE_DB`                          |                                                                                  | **None, provided by user** |
| BACKUP_S3_BUCKET_URI                | `BACKUP_DB`, `LIST_BACKUPS`, `VERIFY_BACKUP`, `RESTORE_DB` |                                                                                  | **None, provided by user** |
| VERIFY_ALL_SEGMENTS                 | `VERIFY_BACKUP`                                            | `true` or `false`                                                                | `true`                     |
| BACKUP_TIME_IN_LONG                 | `VERIFY_BACKUP`, `RESTORE_DB` (optional)                   |                                                                                  | **None, provided by user** |


## See [`docker-compose.yml`](./docker-compose/README.md) for usage with docker

### [Official Datomic deployment docs](https://docs.datomic.com/pro/operation/deployment.html)
