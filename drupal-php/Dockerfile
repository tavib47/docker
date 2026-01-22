ARG PHP_VERSION=8.4
FROM tavib47/php-fpm:${PHP_VERSION}

ARG PHP_VERSION

# UID 41821 = d(4) r(18) u(21) letter positions
ARG DRUPAL_UID=41821
ARG DRUPAL_GID=41821

LABEL maintainer="tavib47"
LABEL description="Base PHP-FPM image for Drupal with drupal user configured"
LABEL php.version="${PHP_VERSION}"

# Install mysql client for drush sql:dump
RUN apk add --no-cache mysql-client

# Create drupal user and group with configurable UID/GID
RUN addgroup -g ${DRUPAL_GID} drupal && \
    adduser -u ${DRUPAL_UID} -G drupal -D -H drupal

# Configure PHP-FPM to run as drupal user
RUN sed -i 's/user = www-data/user = drupal/g' /usr/local/etc/php-fpm.d/www.conf && \
    sed -i 's/group = www-data/group = drupal/g' /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www/html

EXPOSE 9000

CMD ["php-fpm"]
