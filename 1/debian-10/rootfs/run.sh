#!/bin/bash

. /opt/bitnami/base/functions
. /opt/bitnami/base/helpers

USER=airflow
DAEMON=airflow
EXEC=$(which $DAEMON)
START_COMMAND="${EXEC} scheduler | tee /opt/bitnami/airflow/logs/airflow-scheduler.log"

echo "Waiting for db..."
counter=0;
res=1000;
while [[ $res != 0 && $counter -lt 30 ]];
do
    echo " Trying to connect to $AIRFLOW_DATABASE_HOST $AIRFLOW_DATABASE_USERNAME $AIRFLOW_DATABASE_NAME $AIRFLOW_DATABASE_PORT_NUMBER"
    if PGPASSWORD=$AIRFLOW_DATABASE_PASSWORD psql -h "$AIRFLOW_DATABASE_HOST" -U "$AIRFLOW_DATABASE_USERNAME" -d "$AIRFLOW_DATABASE_NAME" -c "" -p "$AIRFLOW_DATABASE_PORT_NUMBER" > /dev/null ; then
        echo "Database is ready";
        res=0
    else
        echo "Can't connect to database...retrying in 1 second";
    fi
    counter=$((counter + 1))
    sleep 1
done

info "Starting ${DAEMON}..."
# If container is started as `root` user
if [ $EUID -eq 0 ]; then
    exec gosu ${USER} bash -c "${START_COMMAND}"
else
    exec bash -c "${START_COMMAND}"
fi
