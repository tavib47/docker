# Drupal CI Image

[![Docker Hub](https://img.shields.io/docker/pulls/tavib47/drupal-ci?label=pulls&logo=docker)](https://hub.docker.com/r/tavib47/drupal-ci)
[![Image Size](https://img.shields.io/docker/image-size/tavib47/drupal-ci/latest?logo=docker)](https://hub.docker.com/r/tavib47/drupal-ci)

An Alpine-based Drupal CI/CD image extending [php-ci](https://hub.docker.com/r/tavib47/php-ci) with Drupal-specific PHP extensions and tools.

## Features

Everything from [php-ci](https://hub.docker.com/r/tavib47/php-ci), plus:

### PHP Extensions
- `mysqli`, `pdo_mysql` — MySQL database support
- `bcmath` — Arbitrary precision math
- `gd` — Image processing

### Tools
- [Drush Launcher](https://github.com/drush-ops/drush-launcher) — Drush command wrapper
- [Robo](https://robo.li/) — Task runner for PHP

## Supported Tags

| Tag | PHP | Node.js |
|-----|-----|---------|
| `8.5`, `latest` | 8.5 | 22 |
| `8.4` | 8.4 | 22 |
| `8.3` | 8.3 | 22 |
| `8.2` | 8.2 | 22 |
| `8.1` | 8.1 | 22 |
| `<php>-node24` | 8.1-8.5 | 24 |
| `<php>-node22` | 8.1-8.5 | 22 |
| `<php>-node20` | 8.1-8.5 | 20 |
| `<php>-node18` | 8.1-8.5 | 18 |

Examples: `8.4-node24`, `8.4-node20`, `8.3-node18`

## Usage

```bash
docker pull tavib47/drupal-ci:8.4
docker run -v $(pwd):/app -w /app tavib47/drupal-ci:8.4 composer install
```

### GitLab CI

```yaml
image: tavib47/drupal-ci:8.4

stages:
  - build
  - test
  - deploy

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

deploy:
  stage: deploy
  script:
    - drush deploy
```

### GitHub Actions

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: tavib47/drupal-ci:8.4
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
  image: tavib47/drupal-ci:8.3

test:php8.4:
  extends: .test
  image: tavib47/drupal-ci:8.4

test:node20:
  extends: .test
  image: tavib47/drupal-ci:8.4-node20
```

## Related Images

- [tavib47/php-ci](https://hub.docker.com/r/tavib47/php-ci) — Base CI image (without Drupal tools)
- [tavib47/php-fpm](https://hub.docker.com/r/tavib47/php-fpm) — Production PHP-FPM image

## Source

[GitHub Repository](https://github.com/tavib47/docker)
