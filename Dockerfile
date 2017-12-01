FROM ubuntu:17.04
RUN apt update
RUN apt install -y wget less systemd
RUN touch /etc/apt/sources.list.d/pgdg.list
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt install wget ca-certificates
RUN apt update
RUN apt -y install postgresql-10

USER postgres
RUN /usr/lib/postgresql/10/bin/pg_ctl -D /var/lib/postgresql/10/main -l /tmp/logfile start

USER root
RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/10/main/pg_hba.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/10/main/postgresql.conf

EXPOSE 5432
RUN apt install -y netcat build-essential libxml2 libxml2-dev libgeos-3.5.1 libgdal-dev gdal-bin libgdal20 libgeos-dev libprotobuf-c1 libprotobuf-c-dev libprotobuf-dev protobuf-compiler protobuf-c-compiler
RUN wget http://download.osgeo.org/postgis/source/postgis-2.4.2.tar.gz
RUN tar -xvzf postgis-2.4.2.tar.gz
RUN cd postgis-2.4.2 && ./configure && make && make install
RUN apt -y install postgresql-10-postgis-scripts --allow-unauthenticated

USER postgres
RUN psql -c "\set ON_ERROR_STOP on;"
RUN createdb -E UTF-8 -T template0 epri
RUN psql -c "CREATE EXTENSION postgis;"
RUN psql -d epri -c "CREATE EXTENSION postgis; CREATE EXTENSION hstore; CREATE EXTENSION adminpack;"
#This 123 password will be removed after code moves from dev
RUN psql -c "create user root superuser password '123';"
RUN psql -c "grant all privileges on database epri to root;"
RUN service postgresql start

USER root
RUN apt -y install gdal-bin
COPY start.postgis.sh /start.postgis.sh
RUN chmod 0755 /start.postgis.sh

CMD ["/start.postgis.sh"]
