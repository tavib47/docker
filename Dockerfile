FROM php:8.2

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
    && apt-get clean -y

RUN docker-php-ext-install gd
RUN docker-php-ext-install zip
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN docker-php-ext-install opcache
RUN docker-php-ext-install xml

RUN docker-php-ext-enable gd
RUN docker-php-ext-enable zip
RUN docker-php-ext-enable mbstring
RUN docker-php-ext-enable mysqli pdo pdo_mysql
RUN docker-php-ext-enable opcache
RUN docker-php-ext-enable xml

RUN apt install wget -y
RUN wget https://robo.li/robo.phar
run chmod +x robo.phar && mv robo.phar /usr/bin/robo

COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

WORKDIR /drupal

