# Claude Code Instructions

This repository contains Alpine-based Docker images for PHP/Drupal CI pipelines and production with multi-version support.

## Repository Structure

```
.
├── php-ci/           # Base PHP image with Composer, Git, Node.js
│   └── Dockerfile
├── drupal-ci/        # Drupal-specific image extending php-ci
│   └── Dockerfile
├── php-fpm/          # Production PHP-FPM image with common extensions
│   └── Dockerfile
├── drupal-php/       # Base PHP-FPM image for Drupal (extends php-fpm)
│   └── Dockerfile
├── drupal-nginx/     # Base Nginx image for Drupal
│   ├── Dockerfile
│   ├── nginx.conf
│   └── default.conf.template
├── build.sh          # Build script (supports --push for Docker Hub)
├── .gitlab-ci.yml    # CI/CD pipeline configuration
├── README.md         # User documentation
└── CLAUDE.md         # This file
```

## Image Hierarchy

### CI/CD Images
- `php-ci` is the base image containing PHP, Composer, Git, and Node.js
- `drupal-ci` extends `php-ci` and adds Drupal-specific PHP extensions and tools (Robo, Drush)

### Production Images
- `php-fpm` is a standalone production image with PHP-FPM and common extensions (works with external web server)
- `drupal-php` extends `php-fpm` and adds drupal user configuration (for production Drupal sites)
- `drupal-nginx` is a standalone Nginx image with drupal user and Drupal-optimized configuration (pairs with drupal-php)

## Version Support

### PHP Versions
- Supported: 8.1, 8.2, 8.3, 8.4, 8.5
- Default: 8.4 (in build.sh)
- Latest tag: 8.5

### Node.js Versions (php-ci and drupal-ci only)
- Supported: 18, 20, 22, 24
- Default: 22
- Node.js is copied from official `node:alpine` image via multi-stage build

### Tag Conventions
- `tavib47/<image>:<php-version>` — default Node.js (e.g., `tavib47/php-ci:8.4`)
- `tavib47/<image>:<php-version>-node<node-version>` — specific Node.js (e.g., `tavib47/php-ci:8.4-node20`)
- `latest` tag points to highest PHP version with default Node.js

## Building Locally

Use `build.sh` for local builds:

```bash
./build.sh                      # Build all images for PHP 8.4 + Node 22 (defaults)
./build.sh -v 8.3               # Build for specific PHP version
./build.sh -v 8.4 -n 20         # Build with specific Node.js version
./build.sh -a                   # Build all PHP versions
./build.sh -v 8.4 -N            # Build all Node.js versions for PHP 8.4
./build.sh -a -N                # Build full matrix (all PHP × all Node)
./build.sh -v 8.5 -i php-ci     # Build only php-ci for PHP 8.5
./build.sh -a --push            # Build all versions and push to Docker Hub
./build.sh -v 8.4 -i php-fpm -p # Build and push specific image/version
./build.sh -i drupal-nginx     # Build drupal-nginx (no PHP version needed)
```

The script handles build order automatically (php-ci before drupal-ci) and tags the highest version as `latest`. Use `--push` or `-p` to push images to Docker Hub after building (requires `docker login`).

## Build Order

Build dependencies:
- `php-ci` → `drupal-ci` (CI images)
- `php-fpm` → `drupal-php` (Production images)
- `drupal-nginx` is standalone (no dependencies)

When building for a specific PHP/Node version, use the same versions for dependent images:

```bash
# Build CI images for PHP 8.2 with Node 20
docker build --build-arg PHP_VERSION=8.2 --build-arg NODE_VERSION=20 -t tavib47/php-ci:8.2-node20 ./php-ci
docker build --build-arg PHP_VERSION=8.2 --build-arg PHP_CI_IMAGE=tavib47/php-ci:8.2-node20 -t tavib47/drupal-ci:8.2-node20 ./drupal-ci

# Build production images for PHP 8.2
docker build --build-arg PHP_VERSION=8.2 -t tavib47/php-fpm:8.2 ./php-fpm
docker build --build-arg PHP_VERSION=8.2 -t tavib47/drupal-php:8.2 ./drupal-php

# Build nginx (standalone)
docker build -t tavib47/drupal-nginx:latest ./drupal-nginx
```

## GitLab CI/CD

The `.gitlab-ci.yml` handles builds with manual triggers (to conserve CI minutes):
- Builds all PHP versions defined in `PHP_VERSIONS` variable
- Creates jobs on changes to `php-ci/`, `drupal-ci/`, `php-fpm/`, `drupal-php/`, or `drupal-nginx/` directories (manual start required)
- Tags the highest version (sorted with `sort -V`) as `latest`
- Requires `DOCKER_USERNAME` and `DOCKER_PASSWORD` CI variables

## Key Conventions

- All images are based on `php:<version>-fpm-alpine` (official PHP Alpine images)
- Node.js is installed via multi-stage build from `node:<version>-alpine`
- Composer is installed from the official image
- System packages are installed using `apk add --no-cache`
- PHP extensions are installed using `docker-php-ext-install`

## Build Arguments

### php-ci
| ARG | Default | Description |
|-----|---------|-------------|
| `PHP_VERSION` | 8.4 | PHP version to use |
| `NODE_VERSION` | 22 | Node.js version to use |

### drupal-ci
| ARG | Default | Description |
|-----|---------|-------------|
| `PHP_VERSION` | 8.3 | PHP version to use |
| `PHP_CI_IMAGE` | tavib47/php-ci:${PHP_VERSION} | Base image to extend |

### php-fpm
| ARG | Default | Description |
|-----|---------|-------------|
| `PHP_VERSION` | 8.4 | PHP version to use |

### drupal-php
| ARG | Default | Description |
|-----|---------|-------------|
| `PHP_VERSION` | 8.4 | PHP version to use |
| `DRUPAL_UID` | 41821 | UID for drupal user |
| `DRUPAL_GID` | 41821 | GID for drupal group |

### drupal-nginx
| ARG | Default | Description |
|-----|---------|-------------|
| `DRUPAL_UID` | 41821 | UID for drupal user |
| `DRUPAL_GID` | 41821 | GID for drupal group |

### drupal-nginx Environment Variables
| ENV | Default | Description |
|-----|---------|-------------|
| `PHP_FPM_HOST` | php | PHP-FPM container hostname |
| `PHP_FPM_PORT` | 9000 | PHP-FPM port |
| `ROBOTS_FILE` | robots.txt | Robots file path |

## When Adding New Images

1. Create a new directory with the image name
2. Add a Dockerfile in that directory
3. Use `php:<version>-fpm-alpine` as base image
4. Include `ARG PHP_VERSION=8.4` for version support
5. Use `apk add --no-cache` for system packages
6. Consider if it should extend an existing image (like php-ci)
7. Update README.md with build and push instructions
8. Add build job to `.gitlab-ci.yml`
9. Follow the naming convention: `tavib47/<image-name>:<php-version>`

## When Adding New PHP Versions

1. Test that the base `php:<version>-fpm-alpine` image exists on Docker Hub
2. Build and test all images with the new version
3. Update the following files:
   - `build.sh`: Add to `SUPPORTED_PHP_VERSIONS` array, update `LATEST_PHP_VERSION` if needed
   - `.gitlab-ci.yml`: Add to `PHP_VERSIONS` variable
   - `README.md`: Update version list
4. Consider if new PHP version requires extension changes

## When Adding New Node.js Versions

1. Test that the base `node:<version>-alpine` image exists on Docker Hub
2. Build and test php-ci and drupal-ci with the new version
3. Update `build.sh`: Add to `SUPPORTED_NODE_VERSIONS` array, update `DEFAULT_NODE_VERSION` if needed
4. Update README.md and CLAUDE.md version lists
