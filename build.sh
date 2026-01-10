#!/bin/bash

set -e

# Default values
DEFAULT_PHP_VERSION="8.4"
SUPPORTED_VERSIONS=("8.1" "8.2" "8.3" "8.4" "8.5")
LATEST_VERSION="8.5"
IMAGE_PREFIX="tavib47"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Build Docker images for PHP/Drupal CI pipelines."
    echo ""
    echo "Options:"
    echo "  -v, --version VERSION   Build for specific PHP version (${SUPPORTED_VERSIONS[*]})"
    echo "  -a, --all               Build for all supported PHP versions"
    echo "  -i, --image IMAGE       Build only specific image (php-ci or drupal-ci)"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                      Build both images for PHP $DEFAULT_PHP_VERSION"
    echo "  $0 -v 8.2               Build both images for PHP 8.2"
    echo "  $0 -a                   Build both images for all PHP versions"
    echo "  $0 -v 8.4 -i php-ci     Build only php-ci for PHP 8.4"
}

build_image() {
    local image=$1
    local version=$2
    local tag="${IMAGE_PREFIX}/${image}:${version}"

    echo -e "${YELLOW}Building ${tag}...${NC}"

    if [[ "$image" == "drupal-ci" ]]; then
        docker build \
            --build-arg PHP_VERSION="$version" \
            --build-arg PHP_CI_IMAGE="${IMAGE_PREFIX}/php-ci:${version}" \
            -t "$tag" \
            "./${image}"
    else
        docker build \
            --build-arg PHP_VERSION="$version" \
            -t "$tag" \
            "./${image}"
    fi

    # Tag as latest if this is the latest PHP version
    if [[ "$version" == "$LATEST_VERSION" ]]; then
        local latest_tag="${IMAGE_PREFIX}/${image}:latest"
        echo -e "${YELLOW}Tagging ${tag} as ${latest_tag}${NC}"
        docker tag "$tag" "$latest_tag"
    fi

    echo -e "${GREEN}Successfully built ${tag}${NC}"
}

build_for_version() {
    local version=$1
    local image=$2

    echo -e "${GREEN}=== Building for PHP ${version} ===${NC}"

    if [[ -z "$image" || "$image" == "php-ci" ]]; then
        build_image "php-ci" "$version"
    fi

    if [[ -z "$image" || "$image" == "drupal-ci" ]]; then
        build_image "drupal-ci" "$version"
    fi
}

# Parse arguments
PHP_VERSION=""
BUILD_ALL=false
TARGET_IMAGE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--version)
            PHP_VERSION="$2"
            shift 2
            ;;
        -a|--all)
            BUILD_ALL=true
            shift
            ;;
        -i|--image)
            TARGET_IMAGE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Validate image name if specified
if [[ -n "$TARGET_IMAGE" && "$TARGET_IMAGE" != "php-ci" && "$TARGET_IMAGE" != "drupal-ci" ]]; then
    echo -e "${RED}Invalid image name: $TARGET_IMAGE${NC}"
    echo "Valid images: php-ci, drupal-ci"
    exit 1
fi

# Validate PHP version if specified
if [[ -n "$PHP_VERSION" ]]; then
    valid=false
    for v in "${SUPPORTED_VERSIONS[@]}"; do
        if [[ "$v" == "$PHP_VERSION" ]]; then
            valid=true
            break
        fi
    done
    if [[ "$valid" == false ]]; then
        echo -e "${RED}Invalid PHP version: $PHP_VERSION${NC}"
        echo "Supported versions: ${SUPPORTED_VERSIONS[*]}"
        exit 1
    fi
fi

# Build images
if [[ "$BUILD_ALL" == true ]]; then
    for version in "${SUPPORTED_VERSIONS[@]}"; do
        build_for_version "$version" "$TARGET_IMAGE"
    done
else
    version="${PHP_VERSION:-$DEFAULT_PHP_VERSION}"
    build_for_version "$version" "$TARGET_IMAGE"
fi

echo -e "${GREEN}=== Build complete ===${NC}"
