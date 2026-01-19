ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-fpm

LABEL maintainer="tavib47"
LABEL description="Production PHP-FPM image with common extensions"
LABEL php.version="${PHP_VERSION}"

WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libfreetype-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libzip-dev \
    libicu-dev \
    libsqlite3-dev \
    libreadline-dev \
    libfcgi-bin \
    curl \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Configure GD extension
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install PHP extensions
# Note: curl, mbstring, opcache, pdo_sqlite, readline, sqlite3, xml are already in the base image
RUN docker-php-ext-install \
    pdo_mysql \
    mysqli \
    gd \
    zip \
    bcmath \
    intl \
    exif

# Install PECL extensions
RUN pecl install apcu redis \
    && docker-php-ext-enable apcu redis

# Use production PHP configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Install php-fpm-healthcheck script
RUN curl -fsSL https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
    -o /usr/local/bin/php-fpm-healthcheck \
    && chmod +x /usr/local/bin/php-fpm-healthcheck

# Enable PHP-FPM status page and ping for healthcheck
RUN echo "pm.status_path = /status" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
    && echo "ping.path = /ping" >> /usr/local/etc/php-fpm.d/zz-docker.conf

# Expose PHP-FPM port
EXPOSE 9000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD php-fpm-healthcheck || exit 1

CMD ["php-fpm"]
