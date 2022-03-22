# mongodb_backup
Script for make backup of mongodb server, by listing dbnames or all in one file.

```
mongo_backup.sh -h=<host> --path=<base path without last backslash> --db=<comma separated list of dbs
        -h|--host default=localhost
        -p|--port default=27017
        --path default=/var/local/mongo_backups
        --db default=ALL
        -u|--user default=
        --password default=
        --help show this help info
```
