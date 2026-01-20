# drupal-ci

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-drupal--ci-blue?logo=docker)](https://hub.docker.com/r/tavib47/drupal-ci)

Alpine-based Drupal CI/CD image extending php-ci with PHP extensions, Robo, and Drush.

## Tags

### PHP + Node.js (default)
- `8.1`, `8.2`, `8.3`, `8.4`, `8.5`, `latest` — with Node.js 22

### PHP + Specific Node.js Version
- `8.4-node18`, `8.4-node20` — PHP 8.4 with Node.js 18/20
- `8.3-node18`, `8.3-node20` — PHP 8.3 with Node.js 18/20
- *(same pattern for other PHP versions)*

## What's Included

Everything from [php-ci](https://hub.docker.com/r/tavib47/php-ci), plus:

### PHP Extensions
- `mysqli`, `pdo_mysql`
- `bcmath`, `gd`

### Tools
- Robo task runner
- Drush launcher

## Usage

### GitLab CI

```yaml
image: tavib47/drupal-ci:8.4

build:
  script:
    - composer install
    - npm install
    - npm run build
    - drush cr
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
      - run: drush cr
```

### Multi-version Testing

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

test:node18:
  extends: .test
  image: tavib47/drupal-ci:8.4-node18

test:node20:
  extends: .test
  image: tavib47/drupal-ci:8.4-node20
```

## Choosing a Node.js Version

Node.js version is selected at build time via image tags:

```yaml
# Use default Node.js (22)
image: tavib47/drupal-ci:8.4

# Use Node.js 20
image: tavib47/drupal-ci:8.4-node20

# Use Node.js 18
image: tavib47/drupal-ci:8.4-node18
```

## Building Locally

```bash
# Using build script (builds php-ci first, default Node.js 22)
./build.sh -v 8.4 -i drupal-ci

# With specific Node.js version
./build.sh -v 8.4 -n 20 -i drupal-ci

# Build all Node.js versions for PHP 8.4
./build.sh -v 8.4 -N -i drupal-ci

# Or manually (requires php-ci to be built first)
docker build \
  --build-arg PHP_VERSION=8.4 \
  --build-arg PHP_CI_IMAGE=tavib47/php-ci:8.4-node20 \
  -t tavib47/drupal-ci:8.4-node20 \
  ./drupal-ci
```

## Build Arguments

| ARG | Default | Description |
|-----|---------|-------------|
| `PHP_VERSION` | 8.4 | PHP version (8.1, 8.2, 8.3, 8.4, 8.5) |
| `PHP_CI_IMAGE` | tavib47/php-ci:${PHP_VERSION} | Base image to extend |

## Base Image

Extends `tavib47/php-ci`, which is built on `php:<version>-fpm-alpine`.
