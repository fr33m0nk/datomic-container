# Container build file for Datomic Database

## Transactor mode environment variables

| Environment variable | Default value              |
|----------------------|----------------------------|
| TRANSACTOR_HOST      | `localhost`                |
| TRANSACTOR_PORT      | `4334`                     |
| XMS                  | `4g`                       |
| XMX                  | `4g`                       |
| LOG_LEVEL            | `INFO`                     |
| PG_PORT              | `5432`                     |
| PG_HOST              | **None, provided by user** |
| PG_USER              | **None, provided by user** |
| PG_PASSWORD          | **None, provided by user** |
| PG_DATABASE          | **None, provided by user** |
