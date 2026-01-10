# Docker Images

A collection of Docker images for CI/CD pipelines.

## Available Images

| Image | Description | |
|-------|-------------|:-:|
| [php-ci](./php-ci) | Base PHP image with Composer, Git, and NVM/Node.js | [![Docker Hub](https://img.shields.io/badge/Docker%20Hub-php--ci-blue?logo=docker)](https://hub.docker.com/r/tavib47/php-ci) |
| [drupal-ci](./drupal-ci) | Drupal image extending php-ci with PHP extensions, Robo, and Drush | [![Docker Hub](https://img.shields.io/badge/Docker%20Hub-drupal--ci-blue?logo=docker)](https://hub.docker.com/r/tavib47/drupal-ci) |

All images support PHP versions: `8.1`, `8.2`, `8.3`, `8.4`, `8.5`, `latest`

`latest` points to the highest PHP version.

## Building Locally

Use the included build script:

```bash
# Build both images for PHP 8.4 (default)
./build.sh

# Build for a specific PHP version
./build.sh -v 8.3

# Build all supported PHP versions
./build.sh -a

# Build only a specific image
./build.sh -v 8.4 -i php-ci
```

Or build manually:

```bash
# Build php-ci (required first)
docker build --build-arg PHP_VERSION=8.5 -t tavib47/php-ci:8.5 ./php-ci

# Build drupal-ci
docker build --build-arg PHP_VERSION=8.5 -t tavib47/drupal-ci:8.5 ./drupal-ci
```

## Using in CI/CD

### GitLab CI

```yaml
image: tavib47/drupal-ci:8.5

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
      image: tavib47/drupal-ci:8.5
    steps:
      - uses: actions/checkout@v4
      - run: composer install
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

test:8.5:
  extends: .test
  image: tavib47/drupal-ci:8.5
```

## Customizing Node.js Version

Images use NVM, allowing runtime version switching:

```bash
source $NVM_DIR/nvm.sh
nvm install 18
nvm use 18
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

## License

MIT
