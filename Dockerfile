FROM alpine:3.6
MAINTAINER Joe Groocock <frebib@gmail.com>

# Set this argument to 'latest' to build the latest version
ARG CACTI_VER=1.1.13

ENV MYSQL_DATABASE=cacti \
    MYSQL_HOST=mysql \
    MYSQL_PORT=3306 \
    MYSQL_USER=cacti \
    MYSQL_PASSWORD=cacti \
    ALLOWED_CLIENTS='127.0.0.1' \
    CACTI_HOME=/usr/share/cacti \
    # Remember the trailing slash!
    URL_PATH=/ \
    UID=900 GID=900

WORKDIR $CACTI_HOME

RUN apk --no-cache add --virtual=build-deps curl tar && \
    apk --no-cache add tini su-exec net-snmp-tools mariadb-client rrdtool \
            php7 php7-session php7-fpm php7-snmp php7-ldap php7-posix \
            php7-sockets php7-pdo_mysql php7-xml php7-simplexml php7-json \
            php7-gd php7-zlib php7-gmp php7-mbstring && \
    \
    curl -L http://www.cacti.net/downloads/cacti-$CACTI_VER.tar.gz \
        | tar xz --strip-components=1 && \
    \
    sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php7/php.ini && \
    sed -i 's|\($database_default  =\).*|\1 getenv("MYSQL_DATABASE");|; \
            s|\($database_hostname =\).*|\1 getenv("MYSQL_HOST");|; \
            s|\($database_username =\).*|\1 getenv("MYSQL_USER");|; \
            s|\($database_password =\).*|\1 getenv("MYSQL_PASSWORD");|; \
            s|\($database_port     =\).*|\1 getenv("MYSQL_PORT");|; \
            s|\($url_path =\).*|\1 getenv("URL_PATH");|' $CACTI_HOME/include/config.php && \
    \
    apk --no-cache del build-deps && \
    rm -f /etc/php7/php-fpm.d/*.conf

EXPOSE 9000/tcp

COPY cacti.conf /etc/php7/php-fpm.d/
COPY entrypoint /usr/local/bin/
RUN  chmod +x /usr/local/bin/entrypoint

VOLUME [ "/usr/share/cacti" ]

ENTRYPOINT [ "/sbin/tini", "--", "entrypoint" ]
CMD [ "php-fpm7" ]
