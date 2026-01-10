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
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Configure GD extension
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install PHP extensions
RUN docker-php-ext-install \
    pdo_mysql \
    mysqli \
    gd \
    zip \
    bcmath \
    opcache \
    mbstring \
    xml \
    curl \
    intl \
    exif \
    readline \
    pdo_sqlite \
    sqlite3

# Install PECL extensions
RUN pecl install apcu redis \
    && docker-php-ext-enable apcu redis

# Use production PHP configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Expose PHP-FPM port
EXPOSE 9000

CMD ["php-fpm"]
