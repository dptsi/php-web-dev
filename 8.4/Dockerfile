FROM php:8.4-fpm-alpine3.24

# Install packages and remove default server definition
RUN apk --no-cache add gnupg autoconf make g++ linux-headers nginx supervisor zlib-dev libpng-dev icu-dev icu-libs librdkafka-dev git libzip-dev && \
    rm -f /etc/nginx/http.d/default.conf

# Install PHP extensions
RUN docker-php-ext-install bcmath gd exif pcntl intl zip calendar

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Download Microsoft SQL Server Prerequisites
RUN curl -O https://download.microsoft.com/download/ade174b7-8cea-4543-91a6-c33ae320c2f0/msodbcsql18_18.7.1.1-1_amd64.apk
RUN curl -O https://download.microsoft.com/download/a5dcc5e7-6124-49d3-8df4-48d738a0e784/mssql-tools18_18.7.1.1-1_amd64.apk

# Verify ODBC Signatures
RUN curl -O https://download.microsoft.com/download/ade174b7-8cea-4543-91a6-c33ae320c2f0/msodbcsql18_18.7.1.1-1_amd64.sig
RUN curl -O https://download.microsoft.com/download/a5dcc5e7-6124-49d3-8df4-48d738a0e784/mssql-tools18_18.7.1.1-1_amd64.sig
# (single RUN: newer GnuPG leaves a stale keyboxd lock between layers)
RUN curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import - && \
    gpg --verify msodbcsql18_18.7.1.1-1_amd64.sig msodbcsql18_18.7.1.1-1_amd64.apk && \
    gpg --verify mssql-tools18_18.7.1.1-1_amd64.sig mssql-tools18_18.7.1.1-1_amd64.apk

# Install the ODBC packages
RUN apk add --allow-untrusted msodbcsql18_18.7.1.1-1_amd64.apk
RUN apk add --allow-untrusted mssql-tools18_18.7.1.1-1_amd64.apk

# Set mssql-tools ENV variable to the PATH
ENV PATH="$PATH:/opt/mssql-tools18/bin"
RUN echo $PATH

# Remove the ODBC packages
RUN rm msodbcsql18_18.7.1.1-1_amd64.apk \
    mssql-tools18_18.7.1.1-1_amd64.apk \
    msodbcsql18_18.7.1.1-1_amd64.sig \
    mssql-tools18_18.7.1.1-1_amd64.sig

# Install unixodbc-dev required for pecl
RUN apk add --allow-untrusted unixodbc-dev

# Install SQL Server Drivers
RUN pecl channel-update pecl.php.net
RUN pecl install sqlsrv-5.13.3
RUN pecl install pdo_sqlsrv-5.13.3
RUN pecl install rdkafka
RUN docker-php-ext-enable --ini-name 30-sqlsrv.ini sqlsrv
RUN docker-php-ext-enable --ini-name 35-pdo_sqlsrv.ini pdo_sqlsrv
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
