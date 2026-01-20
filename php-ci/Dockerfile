ARG PHP_VERSION=8.4
ARG NODE_VERSION=20
FROM node:${NODE_VERSION}-alpine AS node
FROM php:${PHP_VERSION}-fpm-alpine

ARG PHP_VERSION
ARG NODE_VERSION

LABEL maintainer="tavib47"
LABEL description="PHP CI base image with Composer, Git, and Node.js"
LABEL php.version="${PHP_VERSION}"
LABEL node.version="${NODE_VERSION}"

WORKDIR /opt

# Install base dependencies
RUN apk add --no-cache \
    curl \
    wget \
    git \
    zip \
    unzip \
    libzip-dev \
    bash

# Copy Node.js from official image
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Install zip PHP extension (commonly needed for composer)
RUN docker-php-ext-install zip

# Install Composer
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# Verify installations
RUN php --version && composer --version && git --version && node --version && npm --version

WORKDIR /app
