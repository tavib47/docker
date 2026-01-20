# PHP-FPM Production Image

[![Docker Hub](https://img.shields.io/docker/pulls/tavib47/php-fpm?label=pulls&logo=docker)](https://hub.docker.com/r/tavib47/php-fpm)
[![Image Size](https://img.shields.io/docker/image-size/tavib47/php-fpm/latest?logo=docker)](https://hub.docker.com/r/tavib47/php-fpm)

An Alpine-based production PHP-FPM image with common extensions and built-in healthcheck. Designed to work with an external web server (nginx, Apache, Caddy).

## Features

- PHP-FPM with production configuration
- Built-in healthcheck via [php-fpm-healthcheck](https://github.com/renatomefi/php-fpm-healthcheck)
- Common PHP extensions for web applications

### PHP Extensions

| Extension | Description |
|-----------|-------------|
| `pdo_mysql`, `mysqli` | MySQL database |
| `gd` | Image processing |
| `zip` | Archive handling |
| `bcmath` | Arbitrary precision math |
| `intl` | Internationalization |
| `exif` | Image metadata |
| `apcu` | Opcode caching |
| `redis` | Redis client |

**Pre-installed in base image:** `curl`, `mbstring`, `opcache`, `pdo_sqlite`, `readline`, `sqlite3`, `xml`

## Supported Tags

- `8.5`, `latest`
- `8.4`
- `8.3`
- `8.2`
- `8.1`

## Quick Start

```bash
docker pull tavib47/php-fpm:8.4
docker run -d -p 9000:9000 -v /path/to/app:/var/www/html tavib47/php-fpm:8.4
```

Then configure your web server to proxy PHP requests to `localhost:9000`.

## Docker Compose Example

```yaml
services:
  php:
    image: tavib47/php-fpm:8.4
    volumes:
      - ./src:/var/www/html
    expose:
      - "9000"
    healthcheck:
      test: ["CMD", "php-fpm-healthcheck"]
      interval: 30s
      timeout: 3s
      retries: 3

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./src:/var/www/html
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      php:
        condition: service_healthy
```

## Nginx Configuration Example

```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/html/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

## Healthcheck

The image includes a built-in healthcheck:

```bash
# Check health manually
docker exec <container> php-fpm-healthcheck

# Available endpoints
# /status - PHP-FPM status page
# /ping   - Simple ping endpoint
```

## Extending the Image

```dockerfile
FROM tavib47/php-fpm:8.4

# Install additional extensions
RUN apk add --no-cache libpq-dev \
    && docker-php-ext-install pgsql pdo_pgsql

# Copy application code
COPY . /var/www/html
RUN chown -R www-data:www-data /var/www/html
```

## Related Images

- [tavib47/php-ci](https://hub.docker.com/r/tavib47/php-ci) — CI/CD image with Composer, Git, and Node.js
- [tavib47/drupal-ci](https://hub.docker.com/r/tavib47/drupal-ci) — Drupal CI/CD image with Drush and Robo

## Source

[GitHub Repository](https://github.com/tavib47/docker)
