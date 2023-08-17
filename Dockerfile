FROM php:8.2-cli

WORKDIR /opt

RUN apt update
RUN apt install wget -y
RUN wget https://robo.li/robo.phar
run chmod +x robo.phar && mv robo.phar /usr/bin/robo
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

WORKDIR /drupal

