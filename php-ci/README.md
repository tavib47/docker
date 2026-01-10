# php-ci

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-php--ci-blue?logo=docker)](https://hub.docker.com/r/tavib47/php-ci)

Base PHP image for CI/CD pipelines with Composer, Git, and NVM/Node.js.

## Tags

- `8.1`, `8.2`, `8.3`, `8.4`, `8.5`, `latest`

## What's Included

- PHP (with zip extension)
- Composer (latest)
- Git
- NVM with Node.js 20 (default)

## Usage

### GitLab CI

```yaml
image: tavib47/php-ci:8.4

build:
  script:
    - composer install
    - npm install
    - npm run build
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
      - run: npm install
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
  image: tavib47/php-ci:8.3

test:8.4:
  extends: .test
  image: tavib47/php-ci:8.4
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
# Using build script
./build.sh -v 8.4 -i php-ci

# Or manually
docker build --build-arg PHP_VERSION=8.4 -t tavib47/php-ci:8.4 ./php-ci
```

## Build Arguments

| ARG | Default | Description |
|-----|---------|-------------|
| `PHP_VERSION` | 8.3 | PHP version to use |
