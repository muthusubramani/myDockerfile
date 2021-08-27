FROM oraclelinux:7-slim

ARG MYSQL_SERVER_PACKAGE=mysql-community-server-minimal-5.7.34
ARG MYSQL_SHELL_PACKAGE=mysql-shell-8.0.25

# Setup repositories for minimal packages (all versions)
RUN rpm -U https://repo.mysql.com/mysql-community-minimal-release-el7.rpm \
  && rpm -U https://repo.mysql.com/mysql80-community-release-el7.rpm

# Install server and shell 8.0
RUN yum install -y $MYSQL_SHELL_PACKAGE \
  && yum install -y $MYSQL_SERVER_PACKAGE --enablerepo=mysql57-server-minimal\
  && yum clean all \
  && mkdir /docker-entrypoint-initdb.d

# Ensure mysqld logs go to stderr
RUN sed -i 's/^log-error=/#&/' /etc/my.cnf

COPY prepare-image.sh /
RUN /prepare-image.sh && rm -f /prepare-image.sh

ENV MYSQL_UNIX_PORT /var/lib/mysql/mysql.sock

COPY docker-entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh
ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK CMD /healthcheck.sh
EXPOSE 3306 33060
CMD ["mysqld"]

