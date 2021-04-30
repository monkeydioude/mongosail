#### Image running mongodb in standard or daemon mode and allows to use mongoimport to import sets of data at init. __Must be run as a daemon for mongoimport to work__.

HEALTHCHECK --interval=20s --timeout=30s --start-period=20s --retries=3

List of customizable ENV Vars:
- __MONGO_LOG_FILEPATH__: (string) straight path to log file, overrides __MONGO_LOG_DIR__ and __MONGO_LOG_FILENAME__
- __MONGO_LOG_DIR__: (string) path to log directory
- __MONGO_LOG_FILENAME__: (string) if none, timestamp will be used
- __MONGO_LOG_APPEND__: (1|0) default is 1
- __MONGO_SMALL_FILES__: (1|0) default is 1
- __MONGO_DAEMON__: (1|0) default is 0
- __MONGO_AUTH__: (1|0) default is 0
- __MONGO_IMPORT__: (string) list of params to pass to mongoimport, ex "--type json --file /data/import.json", __MONGO_DAEMON=1__ is most likely required

Check docker-compose.yml in [example](/example).

__Docker repo name: [drannoc/mongosail](https://hub.docker.com/r/drannoc/mongosail/)__
