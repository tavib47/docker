# Claude Code Instructions

This repository contains Docker images for PHP/Drupal CI pipelines with multi-version support.

## Repository Structure

```
.
├── php-ci/           # Base PHP image with Composer, Git, NVM/Node.js
│   └── Dockerfile
├── drupal-ci/        # Drupal-specific image extending php-ci
│   └── Dockerfile
├── README.md         # User documentation
└── CLAUDE.md         # This file
```

## Image Hierarchy

- `php-ci` is the base image containing PHP, Composer, Git, and NVM/Node.js
- `drupal-ci` extends `php-ci` and adds Drupal-specific PHP extensions and tools (Robo, Drush)

## PHP Version Support

Both images support multiple PHP versions via the `PHP_VERSION` build argument:
- Supported versions: 8.1, 8.2, 8.3, 8.4
- Default version: 8.3
- Tag convention: `tavib47/<image>:<php-version>` (e.g., `tavib47/php-ci:8.2`)
- `latest` tag points to PHP 8.3

## Build Order

Always build `php-ci` first, then `drupal-ci`. When building for a specific PHP version, use the same version for both:

```bash
# Build for PHP 8.2
docker build --build-arg PHP_VERSION=8.2 -t tavib47/php-ci:8.2 ./php-ci
docker build --build-arg PHP_VERSION=8.2 -t tavib47/drupal-ci:8.2 ./drupal-ci
```

## Key Conventions

- All images are based on `php:<version>-fpm` (official PHP FPM images)
- NVM is used for Node.js version management (default: Node 20)
- Composer is installed from the official image
- PHP extensions are installed using `docker-php-ext-install`
- Image tags match PHP versions (8.1, 8.2, 8.3, 8.4, latest)

## Build Arguments

### php-ci
| ARG | Default | Description |
|-----|---------|-------------|
| `PHP_VERSION` | 8.3 | PHP version to use |

### drupal-ci
| ARG | Default | Description |
|-----|---------|-------------|
| `PHP_VERSION` | 8.3 | PHP version to use |
| `PHP_CI_IMAGE` | tavib47/php-ci:${PHP_VERSION} | Base image to extend |

## When Adding New Images

1. Create a new directory with the image name
2. Add a Dockerfile in that directory
3. Include `ARG PHP_VERSION=8.3` for version support
4. Consider if it should extend an existing image (like php-ci)
5. Update README.md with build and push instructions
6. Follow the naming convention: `tavib47/<image-name>:<php-version>`

## When Adding New PHP Versions

1. Test that the base `php:<version>-fpm` image exists on Docker Hub
2. Build and test both images with the new version
3. Update the version list in README.md
4. Consider if new PHP version requires extension changes
