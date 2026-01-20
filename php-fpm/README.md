# php-fpm

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-php--fpm-blue?logo=docker)](https://hub.docker.com/r/tavib47/php-fpm)

Alpine-based production PHP-FPM image with common extensions. Designed to work with an external web server (nginx, Apache, Caddy, etc.).

## Tags

- `8.1`, `8.2`, `8.3`, `8.4`, `8.5`, `latest`

## What's Included

- PHP-FPM with production configuration (`php.ini-production`)
- Built-in healthcheck via php-fpm-healthcheck
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

### Pre-installed in base image
`curl`, `mbstring`, `opcache`, `pdo_sqlite`, `readline`, `sqlite3`, `xml`

## Quick Start

```bash
docker run -d -p 9000:9000 -v /path/to/app:/var/www/html tavib47/php-fpm:8.4
```

Then configure your web server to proxy PHP requests to `localhost:9000`.

## Healthcheck

The image includes a built-in healthcheck using [php-fpm-healthcheck](https://github.com/renatomefi/php-fpm-healthcheck):

```bash
# Check health manually
docker exec <container> php-fpm-healthcheck

# Status endpoints (for custom checks)
# /status - PHP-FPM status page
# /ping   - Simple ping endpoint
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
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

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

## Building a Custom Image

```dockerfile
FROM tavib47/php-fpm:8.4

# Install additional extensions
RUN apk add --no-cache libpq-dev \
    && docker-php-ext-install pgsql pdo_pgsql

# Copy application code
COPY . /var/www/html

# Set ownership
RUN chown -R www-data:www-data /var/www/html
```

## Building Locally

```bash
# Using build script
./build.sh -v 8.4 -i php-fpm

# Or manually
docker build --build-arg PHP_VERSION=8.4 -t tavib47/php-fpm:8.4 ./php-fpm
```

## Build Arguments

| ARG | Default | Description |
|-----|---------|-------------|
| `PHP_VERSION` | 8.4 | PHP version (8.1, 8.2, 8.3, 8.4, 8.5) |

## Base Image

Built on `php:<version>-fpm-alpine`.
