FROM dptsi/php7.0-fpm-alpine

# Install packages and remove default server definition
RUN apk --no-cache add gnupg autoconf make g++ nginx supervisor zlib-dev libpng-dev icu-dev icu-libs librdkafka-dev git libzip-dev shadow nodejs nodejs-npm && \
    rm /etc/nginx/conf.d/default.conf

# Install PHP extensions
RUN docker-php-ext-install bcmath gd exif pcntl intl zip mysqli pdo pdo_mysql && docker-php-ext-enable pdo_mysql

# Get latest Composer
COPY --from=composer:1.10.6 /usr/bin/composer /usr/bin/composer

# Install unixodbc-dev required for pecl
RUN apk add --allow-untrusted unixodbc-dev

# Install SQL Server Drivers
RUN pecl channel-update pecl.php.net
RUN pecl install rdkafka    
RUN docker-php-ext-enable rdkafka

# Install Xdebug
RUN pecl install xdebug-2.9.0
RUN docker-php-ext-enable --ini-name 30-xdebug.ini xdebug

# Install redis
RUN echo '' | pecl install -o -f redis-5.3.7 &&  rm -rf /tmp/pear &&  docker-php-ext-enable redis

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY config/php.ini /usr/local/etc/php/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www/html

# Add application
WORKDIR /var/www/html

# Add a volume so that the external source code can be hooked
VOLUME [ "/var/www/html" ]

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
