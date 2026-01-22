# Drupal PHP-FPM Image

[![Docker Hub](https://img.shields.io/docker/pulls/tavib47/drupal-php?label=pulls&logo=docker)](https://hub.docker.com/r/tavib47/drupal-php)
[![Image Size](https://img.shields.io/docker/image-size/tavib47/drupal-php/latest?logo=docker)](https://hub.docker.com/r/tavib47/drupal-php)

A base PHP-FPM image for Drupal production environments, extending [php-fpm](https://hub.docker.com/r/tavib47/php-fpm) with a pre-configured `drupal` user. Designed as a reusable base for your Drupal project Dockerfiles.

## Features

Everything from [php-fpm](https://hub.docker.com/r/tavib47/php-fpm), plus:

- Pre-configured `drupal` user and group with configurable UID/GID
- PHP-FPM runs as `drupal` user (not www-data)
- Ready to extend with your application code

## Supported Tags

- `8.5`, `latest`
- `8.4`
- `8.3`
- `8.2`
- `8.1`

## Quick Start

```bash
docker pull tavib47/drupal-php:8.4
```

## Usage in Project Dockerfile

This image is designed to be extended in your project:

```dockerfile
FROM tavib47/drupal-php:8.4

# Copy application code
COPY --chown=drupal:drupal . .

# Create Drupal directories
RUN mkdir -p /var/www/html/web/sites/default/files \
             /var/www/html/private \
             /var/www/html/tmp \
    && chown -R drupal:drupal /var/www/html/web/sites/default/files \
                              /var/www/html/private \
                              /var/www/html/tmp

EXPOSE 9000
```

Configure paths in `settings.php`:
```php
$settings['file_private_path'] = '/var/www/html/private';
$settings['file_temp_path'] = '/var/www/html/tmp';
```

## Build Arguments

| ARG | Default | Description |
|-----|---------|-------------|
| `PHP_VERSION` | 8.4 | PHP version to use |
| `DRUPAL_UID` | 41821 | UID for the drupal user |
| `DRUPAL_GID` | 41821 | GID for the drupal group |

### Custom UID/GID

Match the host user for local development:

```bash
docker build \
  --build-arg DRUPAL_UID=$(id -u) \
  --build-arg DRUPAL_GID=$(id -g) \
  -t my-drupal-php .
```

## Docker Compose Example

```yaml
services:
  php:
    build:
      context: .
      dockerfile: docker/php/Dockerfile
      args:
        - DRUPAL_UID=${DRUPAL_UID:-41821}
        - DRUPAL_GID=${DRUPAL_GID:-41821}
    volumes:
      - .:/var/www/html
    expose:
      - "9000"
    healthcheck:
      test: ["CMD", "php-fpm-healthcheck"]
      interval: 30s
      timeout: 3s
      retries: 3

  nginx:
    image: tavib47/drupal-nginx
    ports:
      - "80:80"
    volumes:
      - ./web:/var/www/html/web:ro
    environment:
      - PHP_FPM_HOST=php
    depends_on:
      php:
        condition: service_healthy
```

## Related Images

- [tavib47/php-fpm](https://hub.docker.com/r/tavib47/php-fpm) — Base production PHP-FPM image
- [tavib47/drupal-nginx](https://hub.docker.com/r/tavib47/drupal-nginx) — Nginx image configured for Drupal (pairs with this image)
- [tavib47/drupal-ci](https://hub.docker.com/r/tavib47/drupal-ci) — CI/CD image with Drush and Robo

## Source

[GitHub Repository](https://github.com/tavib47/docker)
