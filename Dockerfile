FROM php:8.2-fpm

WORKDIR /opt

RUN apt-get update \
    && apt-get install -y \
    libfreetype-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    libcurl4-openssl-dev \
    && apt-get clean -y

RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install zip
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install curl
RUN docker-php-ext-install gd
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install opcache
RUN docker-php-ext-install xml

RUN docker-php-ext-enable mysqli
RUN docker-php-ext-enable pdo
RUN docker-php-ext-enable pdo_mysql
RUN docker-php-ext-enable zip
RUN docker-php-ext-enable bcmath
RUN docker-php-ext-enable curl
RUN docker-php-ext-enable gd
RUN docker-php-ext-enable mbstring
RUN docker-php-ext-enable opcache
RUN docker-php-ext-enable xml

RUN apt-get install git -y

RUN apt-get install wget -y
RUN wget https://robo.li/robo.phar
run chmod +x robo.phar && mv robo.phar /usr/bin/robo

COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

WORKDIR /drupal

