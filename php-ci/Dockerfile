ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-fpm

LABEL maintainer="tavib47"
LABEL description="PHP CI base image with Composer, Git, and NVM/Node.js"
LABEL php.version="${PHP_VERSION}"

# Set environment variables for NVM
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=20

WORKDIR /opt

# Install base dependencies
RUN apt-get update \
    && apt-get install -y \
    curl \
    wget \
    git \
    zip \
    unzip \
    libzip-dev \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install zip PHP extension (commonly needed for composer)
RUN docker-php-ext-install zip

# Install Composer
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# Install NVM and Node.js
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && ln -s "$(which node)" /usr/local/bin/node \
    && ln -s "$(which npm)" /usr/local/bin/npm

# Verify installations
RUN php --version && composer --version && git --version && node --version && npm --version

WORKDIR /app
