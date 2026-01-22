# Docker Images

A collection of Alpine-based Docker images for CI/CD pipelines and production.

## Available Images

### CI/CD Images

| Image | Description | |
|-------|-------------|:-:|
| [php-ci](./php-ci) | Base PHP image with Composer, Git, and Node.js | [![Docker Hub](https://img.shields.io/badge/Docker%20Hub-php--ci-blue?logo=docker)](https://hub.docker.com/r/tavib47/php-ci) |
| [drupal-ci](./drupal-ci) | Drupal image extending php-ci with PHP extensions, Robo, and Drush | [![Docker Hub](https://img.shields.io/badge/Docker%20Hub-drupal--ci-blue?logo=docker)](https://hub.docker.com/r/tavib47/drupal-ci) |

### Production Images

| Image | Description | |
|-------|-------------|:-:|
| [php-fpm](./php-fpm) | Production PHP-FPM image with common extensions | [![Docker Hub](https://img.shields.io/badge/Docker%20Hub-php--fpm-blue?logo=docker)](https://hub.docker.com/r/tavib47/php-fpm) |
| [drupal-php](./drupal-php) | Base PHP-FPM image for Drupal with drupal user configured | [![Docker Hub](https://img.shields.io/badge/Docker%20Hub-drupal--php-blue?logo=docker)](https://hub.docker.com/r/tavib47/drupal-php) |
| [drupal-nginx](./drupal-nginx) | Base Nginx image for Drupal with drupal user and Drupal-optimized config | [![Docker Hub](https://img.shields.io/badge/Docker%20Hub-drupal--nginx-blue?logo=docker)](https://hub.docker.com/r/tavib47/drupal-nginx) |

## Tag Conventions

| Tag | Description |
|-----|-------------|
| `tavib47/php-ci:8.4` | PHP 8.4 with Node.js 22 (default) |
| `tavib47/php-ci:8.4-node20` | PHP 8.4 with Node.js 20 |
| `tavib47/php-ci:8.4-node18` | PHP 8.4 with Node.js 18 |
| `tavib47/php-ci:latest` | Latest PHP (8.5) with Node.js 22 |
| `tavib47/php-fpm:8.4` | PHP 8.4 (no Node.js) |
| `tavib47/drupal-php:8.4` | PHP 8.4 with drupal user configured |
| `tavib47/drupal-nginx:latest` | Nginx with Drupal config and drupal user |

## Building Locally

Use the included build script:

```bash
# Build all images for PHP 8.4 with Node.js 22 (defaults)
./build.sh

# Build for a specific PHP version
./build.sh -v 8.3

# Build with a specific Node.js version
./build.sh -v 8.4 -n 20

# Build all supported PHP versions
./build.sh -a

# Build all Node.js versions for a PHP version
./build.sh -v 8.4 -N

# Build full matrix (all PHP × all Node versions)
./build.sh -a -N

# Build only a specific image
./build.sh -v 8.4 -i php-ci

# Build and push to Docker Hub
./build.sh -a --push
./build.sh -v 8.4 -n 20 -i php-ci --push
```

### Build Script Options

| Option | Description |
|--------|-------------|
| `-v, --version` | PHP version (8.1, 8.2, 8.3, 8.4, 8.5) |
| `-n, --node` | Node.js version (18, 20, 22) |
| `-a, --all` | Build all PHP versions |
| `-N, --all-node` | Build all Node.js versions |
| `-i, --image` | Build specific image (php-ci, drupal-ci, php-fpm, drupal-php, drupal-nginx) |
| `-p, --push` | Push to Docker Hub after building |
| `-h, --help` | Show help |

Note: Run `docker login` before using `--push`.

## License

MIT
