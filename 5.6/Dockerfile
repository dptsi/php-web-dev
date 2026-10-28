FROM php:5.6-apache

# Debian stretch sudah EOL, repo-nya dipindah ke archive.debian.org
RUN sed -i -e 's|deb.debian.org|archive.debian.org|g' \
        -e 's|security.debian.org|archive.debian.org|g' \
        -e '/stretch-updates/d' /etc/apt/sources.list && \
    for k in archive-key-10 archive-key-10-security archive-key-11; do \
        curl -fsSL https://ftp-master.debian.org/keys/$k.asc -o /etc/apt/trusted.gpg.d/debian-$k.asc; \
    done


RUN apt-get update && apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libedit-dev \
        git \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        zlib1g-dev \
        freetds-dev \
        freetds-bin \
        freetds-common \
        libdbd-freetds \
        libsybdb5 \
        libqt4-sql-tds \
        libqt5sql5-tds \
        libqxmlrpc-dev \
      && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/libsybdb.so \
      && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a /usr/lib/libsybdb.a \
      && docker-php-ext-install   mssql \
      && docker-php-ext-configure mssql \
      && chmod 755 /var/www/html -R \
      && chown www-data:www-data /var/www/html
# Get latest Composer
COPY --from=composer:2.2.0 /usr/bin/composer /usr/bin/composer

COPY config/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY config/php.ini /usr/local/etc/php/
COPY conf.d/ /usr/local/etc/php/conf.d/
COPY freetds/ /etc/freetds/

COPY no-debug-non-zts-20131226/ /usr/local/lib/php/extensions/no-debug-non-zts-20131226/
RUN chmod 711 -R /usr/local/lib/php/extensions/no-debug-non-zts-20131226/
RUN chown -R www-data:www-data /var/www && a2enmod rewrite