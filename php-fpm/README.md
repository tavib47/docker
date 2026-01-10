# php-fpm

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-php--fpm-blue?logo=docker)](https://hub.docker.com/r/tavib47/php-fpm)

Production PHP-FPM image with common extensions. Designed to work with an external web server (nginx, Apache, Caddy, etc.).

## Tags

- `8.1`, `8.2`, `8.3`, `8.4`, `8.5`, `latest`

## What's Included

- PHP-FPM with production configuration
- Common PHP extensions for web applications

### PHP Extensions

`pdo_mysql`, `mysqli`, `gd`, `zip`, `bcmath`, `opcache`, `mbstring`, `xml`, `curl`, `intl`, `exif`, `redis`

## Quick Start

```bash
docker run -d -p 9000:9000 -v /path/to/app:/var/www/html tavib47/php-fpm:8.4
```

Then configure your web server to proxy PHP requests to `localhost:9000`.

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
version: '3.8'
services:
  php:
    image: tavib47/php-fpm:8.4
    volumes:
      - ./src:/var/www/html
    expose:
      - "9000"

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./src:/var/www/html
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - php
```

## Building a Custom Image

```dockerfile
FROM tavib47/php-fpm:8.4

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
| `PHP_VERSION` | 8.4 | PHP version to use |
