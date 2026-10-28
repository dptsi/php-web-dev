FROM php:5.6-apache

# Debian stretch sudah EOL, repo-nya dipindah ke archive.debian.org
RUN sed -i -e 's|deb.debian.org|archive.debian.org|g' \
        -e 's|security.debian.org|archive.debian.org|g' \
        -e '/stretch-updates/d' /etc/apt/sources.list && \
    for k in archive-key-10 archive-key-10-security archive-key-11; do \
        curl -fsSL https://ftp-master.debian.org/keys/$k.asc -o /etc/apt/trusted.gpg.d/debian-$k.asc; \
    done

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
		librdkafka-dev \
		git \
		zlib1g-dev \
		libzip-dev \
		zip unzip \
        libcurl4-openssl-dev \
        libedit-dev \
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

RUN apt-get update && \
    apt-get install -y libmcrypt-dev
	
RUN docker-php-ext-configure mcrypt
RUN docker-php-ext-install mcrypt

RUN pecl install zip
RUN docker-php-ext-install zip
RUN docker-php-ext-configure zip
	
RUN curl -sSk https://getcomposer.org/installer | php -- --disable-tls && \
       mv composer.phar /usr/local/bin/composer

RUN apt-get install nano -y && \
    apt-get install openssl -y && \
    apt-get install libssl-dev -y && \
    apt-get install wget -y 
	
RUN cd /tmp && wget https://pecl.php.net/get/rdkafka-3.1.1.tgz && \
    tar zxvf rdkafka-3.1.1.tgz && \
    cd rdkafka-3.1.1   && \
    phpize  && \
    ./configure && \
    make && make install

RUN touch /usr/local/etc/php/conf.d/rdkafka.ini && \
    echo 'extension=rdkafka.so' > /usr/local/etc/php/conf.d/rdkafka.ini
