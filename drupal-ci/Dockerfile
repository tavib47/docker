ARG PHP_VERSION=8.3
ARG PHP_CI_IMAGE=tavib47/php-ci:${PHP_VERSION}
FROM ${PHP_CI_IMAGE}

ARG PHP_VERSION

LABEL maintainer="tavib47"
LABEL description="Drupal CI image with all necessary PHP extensions and tools"
LABEL php.version="${PHP_VERSION}"

WORKDIR /opt

# Install Drupal-required PHP extension dependencies
RUN apk add --no-cache \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    oniguruma-dev \
    libxml2-dev \
    curl-dev

# Configure GD extension
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install PHP extensions required by Drupal
# Note: curl, mbstring, opcache, pdo, xml are already in the base image
RUN docker-php-ext-install \
    mysqli \
    pdo_mysql \
    bcmath \
    gd

# Install Robo task runner
RUN wget https://robo.li/robo.phar \
    && chmod +x robo.phar \
    && mv robo.phar /usr/bin/robo

# Install Drush launcher (optional but useful for Drupal)
RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar \
    && chmod +x drush.phar \
    && mv drush.phar /usr/bin/drush

# Verify installations
RUN php --version && robo --version && drush --version || true

WORKDIR /drupal
