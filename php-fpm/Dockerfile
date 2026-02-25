ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-fpm-alpine

ARG PHP_VERSION

LABEL maintainer="tavib47"
LABEL description="Production PHP-FPM image with common extensions"
LABEL php.version="${PHP_VERSION}"

WORKDIR /var/www/html

# Install system dependencies
RUN apk add --no-cache \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libavif-dev \
    oniguruma-dev \
    libxml2-dev \
    curl-dev \
    libzip-dev \
    icu-dev \
    sqlite-dev \
    readline-dev \
    postgresql-dev \
    fcgi \
    curl

# Configure GD extension with WebP and AVIF support (AVIF requires PHP 8.1+)
RUN GD_ARGS="--with-freetype --with-jpeg --with-webp" && \
    if php -r 'exit(PHP_VERSION_ID >= 80100 ? 0 : 1);'; then \
        GD_ARGS="$GD_ARGS --with-avif"; \
    fi && \
    docker-php-ext-configure gd $GD_ARGS

# Install PHP extensions
# Note: curl, mbstring, opcache, pdo_sqlite, readline, sqlite3, xml are already in the base image
RUN docker-php-ext-install \
    pdo_mysql \
    pdo_pgsql \
    mysqli \
    gd \
    zip \
    bcmath \
    intl \
    exif

# Install PECL extensions (requires build tools)
RUN apk add --no-cache --virtual .build-deps \
    autoconf \
    g++ \
    make \
    && pecl install apcu redis \
    && docker-php-ext-enable apcu redis \
    && apk del .build-deps

# Use production PHP configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Opcache recommended settings for Drupal/production
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=60'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini

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
