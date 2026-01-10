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

# Build and push to Docker Hub
./build.sh -a --push
./build.sh -v 8.4 -i php-fpm --push
```

Note: Run `docker login` before using `--push`.

## CI/CD Pipeline

This repository uses GitLab CI to build and push images with manual triggers.

### Required Variables

Set in GitLab **Settings > CI/CD > Variables**:

| Variable | Description |
|----------|-------------|
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub password or access token |

### Build Triggers

Jobs are created automatically when relevant files change, but require manual start to conserve CI minutes:

| Trigger | Behavior |
|---------|----------|
| Commit to main/master | Creates jobs (manual start required) |
| Web UI | Run jobs manually from GitLab Pipelines |

### Change Detection

- `php-ci/` changes → creates php-ci and drupal-ci jobs
- `drupal-ci/` changes → creates drupal-ci job
- `php-fpm/` changes → creates php-fpm job

## License

MIT
