# Drupal Nginx Image

[![Docker Hub](https://img.shields.io/docker/pulls/tavib47/drupal-nginx?label=pulls&logo=docker)](https://hub.docker.com/r/tavib47/drupal-nginx)
[![Image Size](https://img.shields.io/docker/image-size/tavib47/drupal-nginx/latest?logo=docker)](https://hub.docker.com/r/tavib47/drupal-nginx)

A base Nginx image for Drupal production environments with Drupal-optimized configuration and a pre-configured `drupal` user. Designed to pair with [drupal-php](https://hub.docker.com/r/tavib47/drupal-php).

## Features

- Nginx running as `drupal` user with configurable UID/GID
- Drupal-optimized server configuration with security rules
- Environment variable templating for PHP-FPM connection
- Gzip compression enabled
- Static asset caching headers

## Supported Tags

- `latest`

## Quick Start

```bash
docker pull tavib47/drupal-nginx
```

## Usage in Project Dockerfile

This image is designed to be extended in your project:

```dockerfile
FROM tavib47/drupal-nginx

# Copy static assets
COPY --chown=drupal:drupal web/ /var/www/html/web/

# Optionally override the nginx config template
# COPY docker/nginx/default.conf.template /etc/nginx/templates/default.conf.template

ENV ROBOTS_FILE=robots.txt
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_FPM_HOST` | `php` | PHP-FPM container hostname |
| `PHP_FPM_PORT` | `9000` | PHP-FPM port |
| `ROBOTS_FILE` | `robots.txt` | Robots file path (for multi-site setups) |

## Build Arguments

| ARG | Default | Description |
|-----|---------|-------------|
| `DRUPAL_UID` | 41821 | UID for the drupal user |
| `DRUPAL_GID` | 41821 | GID for the drupal group |

## Docker Compose Example

```yaml
services:
  php:
    image: tavib47/drupal-php:8.4
    volumes:
      - .:/var/www/html
    expose:
      - "9000"

  nginx:
    build:
      context: .
      dockerfile: docker/nginx/Dockerfile
      args:
        - DRUPAL_UID=${DRUPAL_UID:-41821}
        - DRUPAL_GID=${DRUPAL_GID:-41821}
    ports:
      - "80:80"
    volumes:
      - ./web:/var/www/html/web:ro
    environment:
      - PHP_FPM_HOST=php
      - PHP_FPM_PORT=9000
    depends_on:
      - php
```

## Included Security Rules

The default configuration includes Drupal security best practices:

- Blocks access to `.txt` and `.log` files
- Blocks PHP execution in `sites/*/files/`
- Blocks access to `private/` directories
- Blocks access to hidden files (except `.well-known/`)
- Blocks access to `vendor/` PHP files
- Blocks sensitive file extensions (`.engine`, `.inc`, `.install`, `.module`, etc.)

## Customizing Nginx Configuration

To override the default server configuration, copy your template:

```dockerfile
FROM tavib47/drupal-nginx
COPY my-default.conf.template /etc/nginx/templates/default.conf.template
```

The template supports environment variable substitution via nginx's `envsubst`.

## Related Images

- [tavib47/drupal-php](https://hub.docker.com/r/tavib47/drupal-php) — PHP-FPM image configured for Drupal (pairs with this image)
- [tavib47/php-fpm](https://hub.docker.com/r/tavib47/php-fpm) — Base production PHP-FPM image
- [tavib47/drupal-ci](https://hub.docker.com/r/tavib47/drupal-ci) — CI/CD image with Drush and Robo

## Source

[GitHub Repository](https://github.com/tavib47/docker)
