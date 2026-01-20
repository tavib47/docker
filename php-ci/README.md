# php-ci

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-php--ci-blue?logo=docker)](https://hub.docker.com/r/tavib47/php-ci)

Alpine-based PHP image for CI/CD pipelines with Composer, Git, and Node.js.

## Tags

### PHP + Node.js (default)
- `8.1`, `8.2`, `8.3`, `8.4`, `8.5`, `latest` — with Node.js 22

### PHP + Specific Node.js Version
- `8.4-node18`, `8.4-node20` — PHP 8.4 with Node.js 18/20
- `8.3-node18`, `8.3-node20` — PHP 8.3 with Node.js 18/20
- *(same pattern for other PHP versions)*

## What's Included

- PHP (with zip extension)
- Composer (latest)
- Git
- Node.js (18, 20, or 22 depending on tag)
- npm and npx

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

test:php8.3:
  extends: .test
  image: tavib47/php-ci:8.3

test:php8.4:
  extends: .test
  image: tavib47/php-ci:8.4

test:node18:
  extends: .test
  image: tavib47/php-ci:8.4-node18

test:node20:
  extends: .test
  image: tavib47/php-ci:8.4-node20
```

## Choosing a Node.js Version

Node.js version is selected at build time via image tags:

```yaml
# Use default Node.js (22)
image: tavib47/php-ci:8.4

# Use Node.js 20
image: tavib47/php-ci:8.4-node20

# Use Node.js 18
image: tavib47/php-ci:8.4-node18
```

## Building Locally

```bash
# Using build script (default Node.js 22)
./build.sh -v 8.4 -i php-ci

# With specific Node.js version
./build.sh -v 8.4 -n 20 -i php-ci

# Build all Node.js versions for PHP 8.4
./build.sh -v 8.4 -N -i php-ci

# Or manually
docker build \
  --build-arg PHP_VERSION=8.4 \
  --build-arg NODE_VERSION=20 \
  -t tavib47/php-ci:8.4-node20 \
  ./php-ci
```

## Build Arguments

| ARG | Default | Description |
|-----|---------|-------------|
| `PHP_VERSION` | 8.4 | PHP version (8.1, 8.2, 8.3, 8.4, 8.5) |
| `NODE_VERSION` | 22 | Node.js version (18, 20, 22) |

## Base Image

Built on `php:<version>-fpm-alpine` with Node.js copied from `node:<version>-alpine` via multi-stage build.
