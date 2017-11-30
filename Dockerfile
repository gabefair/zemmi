FROM ubuntu:17.04
RUN apt update
RUN apt install -y wget less systemd
RUN touch /etc/apt/sources.list.d/pgdg.list
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ zesty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt update
RUN apt -y install postgresql-9.6 postgresql-server-dev-9.6

USER postgres
RUN /usr/lib/postgresql/9.6/bin/pg_ctl -D /var/lib/postgresql/9.6/main -l /tmp/logfile start

USER root
RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.6/main/pg_hba.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/9.6/main/postgresql.conf


EXPOSE 5432
RUN apt install -y netcat build-essential libxml2 libxml2-dev libgeos-3.5.1 libgdal-dev gdal-bin libgdal20 libgeos-dev libprotobuf-c1 libprotobuf-c-dev libprotobuf-dev protobuf-compiler protobuf-c-compiler
RUN wget http://download.osgeo.org/postgis/source/postgis-2.4.0.tar.gz
RUN tar -xvzf postgis-2.4.0.tar.gz
RUN cd postgis-2.4.0 && ./configure && make && make install

USER postgres
RUN service postgresql start && psql -c "CREATE EXTENSION postgis"

USER root
COPY start.postgis.sh /start.postgis.sh
RUN chmod 0755 /start.postgis.sh

CMD ["/start.postgis.sh"]
