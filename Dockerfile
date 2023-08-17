FROM php:8.2-cli

WORKDIR /opt

RUN apt install wget
RUN wget https://robo.li/robo.phar
run chmod +x robo.phar && sudo mv robo.phar /usr/bin/robo
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

WORKDIR /drupal

