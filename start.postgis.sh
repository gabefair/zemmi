#!/bin/bash

DATADIR="/var/lib/postgresql/9.6/main"
CONF="/etc/postgresql/9.6/main/postgresql.conf"
POSTGRES="/usr/lib/postgresql/9.6/bin/postgres"

su postgres sh -c "$POSTGRES -D $DATADIR -c config_file=$CONF" &
until nc -z localhost 5432;
do
    echo ...
    sleep 5
done
sleep 5 # just for sure
su - postgres -c "psql -c \"CREATE EXTENSION IF NOT EXISTS postgis\""
echo database up and running

wait $!
