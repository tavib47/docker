# Claude Code Instructions

This repository contains Docker images for PHP/Drupal CI pipelines and production with multi-version support.

## Repository Structure

```
.
├── php-ci/           # Base PHP image with Composer, Git, NVM/Node.js
│   └── Dockerfile
├── drupal-ci/        # Drupal-specific image extending php-ci
│   └── Dockerfile
├── php-fpm/          # Production PHP-FPM image with common extensions
│   └── Dockerfile
├── build.sh          # Local build script for testing
├── .gitlab-ci.yml    # CI/CD pipeline configuration
├── README.md         # User documentation
└── CLAUDE.md         # This file
```

## Image Hierarchy

- `php-ci` is the base image containing PHP, Composer, Git, and NVM/Node.js
- `drupal-ci` extends `php-ci` and adds Drupal-specific PHP extensions and tools (Robo, Drush)
- `php-fpm` is a standalone production image with PHP-FPM and common extensions (works with external web server)

## PHP Version Support

Both images support multiple PHP versions via the `PHP_VERSION` build argument:
- Supported versions: 8.1, 8.2, 8.3, 8.4, 8.5
- Default build version: 8.4 (in build.sh)
- Tag convention: `tavib47/<image>:<php-version>` (e.g., `tavib47/php-ci:8.2`)
- `latest` tag points to the highest PHP version (currently 8.5)

## Building Locally

Use `build.sh` for local builds:

```bash
./build.sh                      # Build both images for PHP 8.4 (default)
./build.sh -v 8.3               # Build for specific PHP version
./build.sh -a                   # Build all supported versions
./build.sh -v 8.5 -i php-ci     # Build only php-ci for PHP 8.5
```

The script handles build order automatically (php-ci before drupal-ci) and tags the highest version as `latest`.

## Build Order

Always build `php-ci` first, then `drupal-ci`. When building for a specific PHP version, use the same version for both:

```bash
# Build for PHP 8.2
docker build --build-arg PHP_VERSION=8.2 -t tavib47/php-ci:8.2 ./php-ci
docker build --build-arg PHP_VERSION=8.2 -t tavib47/drupal-ci:8.2 ./drupal-ci
```

## GitLab CI/CD

The `.gitlab-ci.yml` handles automated builds:
- Builds all PHP versions defined in `PHP_VERSIONS` variable
- Auto-triggers on changes to `php-ci/`, `drupal-ci/`, or `php-fpm/` directories
- Tags the highest version (sorted with `sort -V`) as `latest`
- Requires `DOCKER_USERNAME` and `DOCKER_PASSWORD` CI variables

## Key Conventions

- All images are based on `php:<version>-fpm` (official PHP FPM images)
- NVM is used for Node.js version management (default: Node 20)
- Composer is installed from the official image
- PHP extensions are installed using `docker-php-ext-install`
- Image tags match PHP versions (8.1, 8.2, 8.3, 8.4, 8.5, latest)

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

### php-fpm
| ARG | Default | Description |
|-----|---------|-------------|
| `PHP_VERSION` | 8.4 | PHP version to use |

## When Adding New Images

1. Create a new directory with the image name
2. Add a Dockerfile in that directory
3. Include `ARG PHP_VERSION=8.3` for version support
4. Consider if it should extend an existing image (like php-ci)
5. Update README.md with build and push instructions
6. Add build job to `.gitlab-ci.yml`
7. Follow the naming convention: `tavib47/<image-name>:<php-version>`

## When Adding New PHP Versions

1. Test that the base `php:<version>-fpm` image exists on Docker Hub
2. Build and test both images with the new version
3. Update the following files:
   - `build.sh`: Add to `SUPPORTED_VERSIONS` array, update `LATEST_VERSION` if needed
   - `.gitlab-ci.yml`: Add to `PHP_VERSIONS` variable
   - `README.md`: Update version list
4. Consider if new PHP version requires extension changes
