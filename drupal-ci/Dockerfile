ARG PHP_VERSION=8.3
ARG PHP_CI_IMAGE=tavib47/php-ci:${PHP_VERSION}
FROM ${PHP_CI_IMAGE}

LABEL maintainer="tavib47"
LABEL description="Drupal CI image with all necessary PHP extensions and tools"
LABEL php.version="${PHP_VERSION}"

WORKDIR /opt

# Install Drupal-required PHP extension dependencies
RUN apt-get update \
    && apt-get install -y \
    libfreetype-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by Drupal
RUN docker-php-ext-install \
    mysqli \
    pdo \
    pdo_mysql \
    bcmath \
    curl \
    gd \
    mbstring \
    opcache \
    xml

# Enable PHP extensions
RUN docker-php-ext-enable \
    mysqli \
    pdo \
    pdo_mysql \
    bcmath \
    curl \
    gd \
    mbstring \
    opcache \
    xml

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
