#!/bin/bash

# MONGO_LOG_FILEPATH: (string) straight path to log file
# MONGO_LOG_DIR: (string) path to log directory
# MONGO_LOG_FILENAME: (string) if none, timestamp will be used
# MONGO_LOG_APPEND: (1|0) default is 1
# MONGO_SMALL_FILES: (1|0) default is 1
# MONGO_DAEMON: (1|0) default is 0
# MONGO_IMPORT: (string) list of params to pass to mongoimport, ex "--type json --file /data/import.json"

ARGS=
LOGPATH=
PID_FILEPATH=/tmp/pid
PID=
PID_SLEEP_CHECK=5

# if MONGO_LOG_FILEPATH exists, MONGO_LOG_DIR and MONGO_LOG_FILENAME will be ignored
if [ -z $MONGO_LOG_FILEPATH ]; then
    if [ ! -z $MONGO_LOG_DIR ]; then
        if [ -z $MONGO_LOG_FILENAME ]; then
            MONGO_LOG_FILENAME=`date +%s`
        fi
        LOGPATH="$MONGO_LOG_DIR/$MONGO_LOG_FILENAME"
    fi
else
    LOGPATH="$MONGO_LOG_FILEPATH"
fi

# Can not (or more lke should really not regarding of the standard usage of mongoimport) use mongoimport if
# mongo is not run as a daemon. MONGO_DAEMON=1 required
if [ ! -z "$MONGO_IMPORT" ] && [ $MONGO_DAEMON != 1 ]; then
    echo "[WARN] Trying to run 'mongoimport' without running 'mongod' as a daemon."
    echo "[WARN] This will cause the 'mongoimport' to be run only after 'mongod' stops or is killed."
    echo "[WARN] ENV var 'MONGO_DAEMON=1' is required."
    if [ ! -z $LOGPATH ]; then
        echo "[WARN][DOCKER-CONTAINER] Something went WRONG with 'mongoimport'. Restart container without detached mode and check output." >> $LOGPATH
    fi
    exit 1
fi

if [ ! -z $LOGPATH ]; then
    ARGS="$ARGS --logpath=$LOGPATH"
fi

if [ -z $MONGO_LOG_APPEND ] || [ [ ! -z $MONGO_LOG_APPEND ] && [ $MONGO_LOG_APPEND ] ]; then
    ARGS="$ARGS --logappend"
fi

if [ -z $MONGO_SMALL_FILES ] || [ $MONGO_SMALL_FILES != 0 ]; then
    ARGS="$ARGS --smallfiles"
fi

if [ $MONGO_DAEMON == 1 ]; then
    ARGS="$ARGS --fork --pidfilepath=$PID_FILEPATH"
fi

echo "[INFO] Will now launch 'mongod' using these arguments: \"$ARGS\"."

mongod --bind_ip 0.0.0.0 $ARGS

if [ ! -z "$MONGO_IMPORT" ]; then
    echo "[INFO] Will now launch 'mongoimport' using the file \"$MONGO_IMPORT\"." 
    mongoimport --file $MONGO_IMPORT
fi

if [ -z $MONGO_DAEMON ] || [ $MONGO_DAEMON != 0 ]; then
    if [ -f $PID_FILEPATH ]; then
        PID=`cat $PID_FILEPATH`
    fi
    while [ "`ps -p $PID | grep mongod`" ]; do
        sleep $PID_SLEEP_CHECK
    done
fi
