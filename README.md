# Docker CI Images

Docker images for PHP and Drupal CI/CD pipelines. Supports multiple PHP versions (8.1, 8.2, 8.3, 8.4, etc.).

## Available Images

### php-ci

Base PHP image for general PHP projects.

**Includes:**
- PHP (configurable version: 8.1, 8.2, 8.3, 8.4)
- Composer (latest)
- Git
- NVM with Node.js 20 (switchable at runtime)
- npm

### drupal-ci

Extended image for Drupal projects, built on top of `php-ci`.

**Includes everything from php-ci, plus:**
- PHP extensions: mysqli, pdo, pdo_mysql, bcmath, curl, gd, mbstring, opcache, xml, zip
- Robo task runner
- Drush launcher

## Building Images

Images must be built in order since `drupal-ci` depends on `php-ci`.

### Build a Single Version

```bash
# Build php-ci for PHP 8.3 (default)
docker build -t tavib47/php-ci:8.3 ./php-ci

# Build php-ci for a specific PHP version
docker build --build-arg PHP_VERSION=8.1 -t tavib47/php-ci:8.1 ./php-ci
docker build --build-arg PHP_VERSION=8.2 -t tavib47/php-ci:8.2 ./php-ci
docker build --build-arg PHP_VERSION=8.4 -t tavib47/php-ci:8.4 ./php-ci

# Build drupal-ci (automatically uses matching php-ci version)
docker build --build-arg PHP_VERSION=8.3 -t tavib47/drupal-ci:8.3 ./drupal-ci
```

### Build All PHP Versions

```bash
# Build all php-ci versions
for version in 8.1 8.2 8.3 8.4; do
  docker build --build-arg PHP_VERSION=$version -t tavib47/php-ci:$version ./php-ci
done

# Build all drupal-ci versions
for version in 8.1 8.2 8.3 8.4; do
  docker build --build-arg PHP_VERSION=$version -t tavib47/drupal-ci:$version ./drupal-ci
done

# Tag latest
docker tag tavib47/php-ci:8.3 tavib47/php-ci:latest
docker tag tavib47/drupal-ci:8.3 tavib47/drupal-ci:latest
```

## Publishing Images

```bash
docker login

# Push all php-ci versions
for version in 8.1 8.2 8.3 8.4 latest; do
  docker push tavib47/php-ci:$version
done

# Push all drupal-ci versions
for version in 8.1 8.2 8.3 8.4 latest; do
  docker push tavib47/drupal-ci:$version
done
```

## Testing Images

```bash
# Test php-ci
docker run --rm -it tavib47/php-ci:8.3 bash
php --version
composer --version
node --version
npm --version

# Test drupal-ci
docker run --rm -it tavib47/drupal-ci:8.3 bash
php -m  # List installed PHP modules
robo --version
drush --version
```

## Using in CI/CD

### GitLab CI Example

```yaml
# Use specific PHP version
image: tavib47/drupal-ci:8.3

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

# Matrix build for multiple PHP versions
.test-template:
  stage: test
  script:
    - composer install
    - ./vendor/bin/phpunit

test:php8.1:
  extends: .test-template
  image: tavib47/drupal-ci:8.1

test:php8.2:
  extends: .test-template
  image: tavib47/drupal-ci:8.2

test:php8.3:
  extends: .test-template
  image: tavib47/drupal-ci:8.3
```

### GitHub Actions Example

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        php: ['8.1', '8.2', '8.3', '8.4']
    container:
      image: tavib47/drupal-ci:${{ matrix.php }}
    steps:
      - uses: actions/checkout@v4
      - run: composer install
      - run: npm install && npm run build
      - run: ./vendor/bin/phpunit
```

## Customizing Node.js Version

The `php-ci` image uses NVM, allowing you to switch Node.js versions at runtime:

```bash
# In your CI script or container
source $NVM_DIR/nvm.sh
nvm install 18
nvm use 18
node --version  # v18.x.x
```

## Available Tags

| Image | Tags |
|-------|------|
| php-ci | `8.1`, `8.2`, `8.3`, `8.4`, `latest` |
| drupal-ci | `8.1`, `8.2`, `8.3`, `8.4`, `latest` |

`latest` points to PHP 8.3.

## License

MIT
