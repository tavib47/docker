# PHP CI Base Image

[![Docker Hub](https://img.shields.io/docker/pulls/tavib47/php-ci?label=pulls&logo=docker)](https://hub.docker.com/r/tavib47/php-ci)
[![Image Size](https://img.shields.io/docker/image-size/tavib47/php-ci/latest?logo=docker)](https://hub.docker.com/r/tavib47/php-ci)

A lightweight Alpine-based PHP image optimized for CI/CD pipelines, bundling PHP with Composer, Git, and Node.js.

## Features

- PHP with zip extension
- Composer (latest)
- Git
- Node.js with npm and npx
- curl, wget, zip, unzip

## Supported Tags

| Tag | PHP | Node.js |
|-----|-----|---------|
| `8.5`, `latest` | 8.5 | 22 |
| `8.4` | 8.4 | 22 |
| `8.3` | 8.3 | 22 |
| `8.2` | 8.2 | 22 |
| `8.1` | 8.1 | 22 |
| `<php>-node20` | 8.1-8.5 | 20 |
| `<php>-node18` | 8.1-8.5 | 18 |

Examples: `8.4-node20`, `8.3-node18`

## Usage

```bash
docker pull tavib47/php-ci:8.4
docker run -v $(pwd):/app -w /app tavib47/php-ci:8.4 composer install
```

### GitLab CI

```yaml
image: tavib47/php-ci:8.4

stages:
  - build
  - test

build:
  stage: build
  script:
    - composer install
    - npm install
    - npm run build

test:
  stage: test
  script:
    - ./vendor/bin/phpunit
```

### GitHub Actions

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: tavib47/php-ci:8.4
    steps:
      - uses: actions/checkout@v4
      - run: composer install
      - run: npm install && npm run build
      - run: ./vendor/bin/phpunit
```

### Multi-Version Testing

```yaml
# GitLab CI
.test:
  script:
    - composer install
    - ./vendor/bin/phpunit

test:php8.3:
  extends: .test
  image: tavib47/php-ci:8.3

test:php8.4:
  extends: .test
  image: tavib47/php-ci:8.4

test:node20:
  extends: .test
  image: tavib47/php-ci:8.4-node20
```

## Related Images

- [tavib47/drupal-ci](https://hub.docker.com/r/tavib47/drupal-ci) — Extends this image with Drupal-specific tools (Drush, Robo) and PHP extensions
- [tavib47/php-fpm](https://hub.docker.com/r/tavib47/php-fpm) — Production PHP-FPM image

## Source

[GitHub Repository](https://github.com/tavib47/docker)
