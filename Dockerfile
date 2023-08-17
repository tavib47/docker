FROM php:8.2-cli

WORKDIR /opt

RUN apt update
RUN rm /etc/apt/preferences.d/no-debian-php
RUN apt install php8.2-cli \
    php8.2-common \
    php8.2-curl \
    php8.2-gd \
    php8.2-zip \
    php8.2-mbstring \
    php8.2-mysql \
    php8.2-opcache \
    php8.2-readline \
    php8.2-sqlite3 \
    php8.2-xml  \
    php8.2-apcu -y \

RUN apt install wget -y
RUN wget https://robo.li/robo.phar
run chmod +x robo.phar && mv robo.phar /usr/bin/robo

COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

WORKDIR /drupal

