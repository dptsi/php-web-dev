FROM php:8.1-fpm-alpine3.22

# Install packages and remove default server definition
RUN apk --no-cache add gnupg autoconf make g++ linux-headers nginx supervisor zlib-dev libpng-dev icu-dev icu-libs librdkafka-dev git libzip-dev && \
    rm -f /etc/nginx/http.d/default.conf

# Install PHP extensions
RUN docker-php-ext-install bcmath gd exif pcntl intl zip calendar mysqli pdo pdo_mysql && docker-php-ext-enable pdo_mysql

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install rdkafka
RUN pecl channel-update pecl.php.net
RUN pecl install rdkafka
RUN docker-php-ext-enable rdkafka

# Install Xdebug
# RUN pecl install xdebug
# RUN docker-php-ext-enable --ini-name 30-xdebug.ini xdebug

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
