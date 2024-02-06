# Container build file for Datomic Database

## Same container image can be run as a Transactor or Peer
- This is controlled by image environment variable `RUN_MODE`
- This environment variable needs to be passed when running the image
- Possible values are `TRANSACTOR` and `PEER`. Defaults to `TRANSACTOR`


## Container environment variables

| Environment variable | Applies to `RUN_MODE`                | Supported values       | Default value              |
|----------------------|:-------------------------------------|:-----------------------|----------------------------|
| RUN_MODE             | Starts Datomic as Transactor or Peer | `TRANSACTOR` or `PEER` | `TRANSACTOR`               |
| TRANSACTOR_HOST      | `TRANSACTOR`                         |                        | `localhost`                |
| TRANSACTOR_PORT      | `TRANSACTOR`                         |                        | `4334`                     |
| XMS                  | `TRANSACTOR`                         |                        | `4g`                       |
| XMX                  | `TRANSACTOR`                         |                        | `4g`                       |
| LOG_LEVEL            | `TRANSACTOR` and `PEER`              |                        | `INFO`                     |
| PG_PORT              | `TRANSACTOR` and `PEER`              |                        | `5432`                     |
| PG_HOST              | `TRANSACTOR` and `PEER`              |                        | **None, provided by user** |
| PG_USER              | `TRANSACTOR` and `PEER`              |                        | **None, provided by user** |
| PG_PASSWORD          | `TRANSACTOR` and `PEER`              |                        | **None, provided by user** |
| PG_DATABASE          | `TRANSACTOR` and `PEER`              |                        | **None, provided by user** |
| PEER_HOST            | `PEER`                               |                        | `localhost`                |
| PEER_PORT            | `PEER`                               |                        | `8998`                     |
| PEER_ACCESSKEY       | `PEER`                               |                        | `myaccesskey`              |
| PEER_SECRET          | `PEER`                               |                        | `mysecret`                 |
| DATOMIC_DB_NAME      | `PEER`                               |                        | **None, provided by user** |

### [Official Datomic deployment docs](https://docs.datomic.com/pro/operation/deployment.html)
