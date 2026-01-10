# drupal-ci

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-drupal--ci-blue?logo=docker)](https://hub.docker.com/r/tavib47/drupal-ci)

Drupal CI/CD image extending php-ci with PHP extensions, Robo, and Drush.

## Tags

- `8.1`, `8.2`, `8.3`, `8.4`, `8.5`, `latest`

## What's Included

Everything from [php-ci](../php-ci), plus:

### PHP Extensions
- `mysqli`, `pdo`, `pdo_mysql`
- `bcmath`, `curl`, `gd`
- `mbstring`, `opcache`, `xml`

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

test:8.3:
  extends: .test
  image: tavib47/drupal-ci:8.3

test:8.4:
  extends: .test
  image: tavib47/drupal-ci:8.4
```

## Customizing Node.js Version

Images use NVM, allowing runtime version switching:

```bash
source $NVM_DIR/nvm.sh
nvm install 18
nvm use 18
```

## Building Locally

```bash
# Using build script (builds php-ci first)
./build.sh -v 8.4 -i drupal-ci

# Or manually (requires php-ci to be built first)
docker build --build-arg PHP_VERSION=8.4 -t tavib47/drupal-ci:8.4 ./drupal-ci
```

## Build Arguments

| ARG | Default | Description |
|-----|---------|-------------|
| `PHP_VERSION` | 8.3 | PHP version to use |
| `PHP_CI_IMAGE` | tavib47/php-ci:${PHP_VERSION} | Base image to extend |
