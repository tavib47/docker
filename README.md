# Docker Images

A collection of Docker images for CI/CD pipelines and production.

## Available Images

| Image | Description | |
|-------|-------------|:-:|
| [php-ci](./php-ci) | Base PHP image with Composer, Git, and NVM/Node.js | [![Docker Hub](https://img.shields.io/badge/Docker%20Hub-php--ci-blue?logo=docker)](https://hub.docker.com/r/tavib47/php-ci) |
| [drupal-ci](./drupal-ci) | Drupal image extending php-ci with PHP extensions, Robo, and Drush | [![Docker Hub](https://img.shields.io/badge/Docker%20Hub-drupal--ci-blue?logo=docker)](https://hub.docker.com/r/tavib47/drupal-ci) |
| [php-fpm](./php-fpm) | Production PHP-FPM image with common extensions | [![Docker Hub](https://img.shields.io/badge/Docker%20Hub-php--fpm-blue?logo=docker)](https://hub.docker.com/r/tavib47/php-fpm) |

All images support PHP versions: `8.1`, `8.2`, `8.3`, `8.4`, `8.5 (latest)`

## Building Locally

Use the included build script:

```bash
# Build all images for PHP 8.4 (default)
./build.sh

# Build for a specific PHP version
./build.sh -v 8.3

# Build all supported PHP versions
./build.sh -a

# Build only a specific image
./build.sh -v 8.4 -i php-ci
./build.sh -v 8.4 -i php-fpm
```

## CI/CD Pipeline

This repository uses GitLab CI to automatically build and push images.

### Required Variables

Set in GitLab **Settings > CI/CD > Variables**:

| Variable | Description |
|----------|-------------|
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub password or access token |

### Build Triggers

| Trigger | Behavior |
|---------|----------|
| Commit to main/master | Auto-builds images with changed Dockerfiles |
| Manual trigger | Run jobs manually from GitLab UI |

### Auto-detection

- `php-ci/` changes → rebuilds php-ci and drupal-ci
- `drupal-ci/` changes → rebuilds only drupal-ci
- `php-fpm/` changes → rebuilds only php-fpm

## License

MIT
