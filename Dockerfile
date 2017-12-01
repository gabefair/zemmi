FROM ubuntu:17.04
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt update
RUN apt install -y wget less systemd
RUN touch /etc/apt/sources.list.d/pgdg.list
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ zesty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt install wget ca-certificates
RUN apt update
RUN apt -y install postgresql-10 gdal-bin netcat build-essential libxml2 libxml2-dev libgeos-3.5.1 libgdal-dev gdal-bin libgdal20 libgeos-dev libprotobuf-c1 libprotobuf-c-dev libprotobuf-dev protobuf-compiler protobuf-c-compiler postgis postgresql-10-postgis-scripts --allow-unauthenticated

RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/10/main/pg_hba.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/10/main/postgresql.conf && \
    echo "listen_addresses='*'" >> /var/lib/postgresql/10/main/postgresql.conf && \
    printf "host all  all    0.0.0.0/0  trust\nhost all all trust" >> /var/lib/postgresql/10/main/pg_hba.conf && \
    echo "map-name root postgres" >> /var/lib/postgresql/10/main/pg_ident.conf
EXPOSE 5432

USER postgres
RUN /usr/lib/postgresql/10/bin/pg_ctl -D /var/lib/postgresql/10/main -l /tmp/logfile start && \
    psql -c "\set ON_ERROR_STOP on; CREATE EXTENSION postgis;"

USER root
RUN createdb -E UTF-8 -T template0 epri

USER postgres
#This 123 password will be removed after code moves from dev
#RUN service postgresql start && psql -d -c "CREATE EXTENSION postgis; CREATE EXTENSION hstore; CREATE EXTENSION adminpack; CREATE USER root SUPERUSER PASSWORD '123'; grant all privileges on database epri to root;"
RUN service postgresql start && psql -d -c "CREATE EXTENSION postgis; CREATE EXTENSION hstore; CREATE EXTENSION adminpack;"

USER root
COPY start.postgis.sh /start.postgis.sh
RUN chmod 0755 /start.postgis.sh

RUN echo 'debconf debconf/frontend select Dialog' | debconf-set-selections
CMD ["/start.postgis.sh"]
