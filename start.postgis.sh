#!/bin/bash

DATADIR="/var/lib/postgresql/10/main"
CONF="/etc/postgresql/10/main/postgresql.conf"
POSTGRES="/usr/lib/postgresql/10/bin/postgres"

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
