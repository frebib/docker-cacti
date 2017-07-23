#!/bin/sh
set -eax

# It is important that we don't bind TCP/IP
# otherwise it can interrupt and break things
mysqld --user=mysql --skip-networking &

apk --no-cache add tzdata
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql

pkill mysqld

