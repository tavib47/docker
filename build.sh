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
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Build Docker images for PHP/Drupal CI pipelines and production."
    echo ""
    echo "Options:"
    echo "  -v, --version VERSION   Build for specific PHP version (${SUPPORTED_VERSIONS[*]})"
    echo "  -a, --all               Build for all supported PHP versions"
    echo "  -i, --image IMAGE       Build only specific image (php-ci, drupal-ci, or php-fpm)"
    echo "  -p, --push              Push images to Docker Hub after building"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                      Build all images for PHP $DEFAULT_PHP_VERSION"
    echo "  $0 -v 8.2               Build all images for PHP 8.2"
    echo "  $0 -a                   Build all images for all PHP versions"
    echo "  $0 -v 8.4 -i php-ci     Build only php-ci for PHP 8.4"
    echo "  $0 -a --push            Build all versions and push to Docker Hub"
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

check_docker_login() {
    echo -e "${YELLOW}Checking Docker Hub login status...${NC}"

    # Try to get the logged-in username
    if docker info 2>/dev/null | grep -q "Username:"; then
        local username=$(docker info 2>/dev/null | grep "Username:" | awk '{print $2}')
        echo -e "${GREEN}Logged in to Docker Hub as: ${username}${NC}"
        return 0
    fi

    # Not logged in - prompt for login
    echo -e "${RED}Not logged in to Docker Hub.${NC}"
    echo -e "${YELLOW}Please log in to continue with push:${NC}"

    if docker login; then
        echo -e "${GREEN}Successfully logged in to Docker Hub.${NC}"
        return 0
    else
        echo -e "${RED}Docker login failed. Cannot push images.${NC}"
        exit 1
    fi
}

push_image() {
    local image=$1
    local version=$2
    local tag="${IMAGE_PREFIX}/${image}:${version}"

    echo -e "${BLUE}Pushing ${tag}...${NC}"
    docker push "$tag"

    # Push latest tag if this is the latest PHP version
    if [[ "$version" == "$LATEST_VERSION" ]]; then
        local latest_tag="${IMAGE_PREFIX}/${image}:latest"
        echo -e "${BLUE}Pushing ${latest_tag}...${NC}"
        docker push "$latest_tag"
    fi

    echo -e "${GREEN}Successfully pushed ${tag}${NC}"
}

build_for_version() {
    local version=$1
    local image=$2
    local do_push=$3

    echo -e "${GREEN}=== Building for PHP ${version} ===${NC}"

    if [[ -z "$image" || "$image" == "php-ci" ]]; then
        build_image "php-ci" "$version"
        [[ "$do_push" == true ]] && push_image "php-ci" "$version"
    fi

    if [[ -z "$image" || "$image" == "drupal-ci" ]]; then
        build_image "drupal-ci" "$version"
        [[ "$do_push" == true ]] && push_image "drupal-ci" "$version"
    fi

    if [[ -z "$image" || "$image" == "php-fpm" ]]; then
        build_image "php-fpm" "$version"
        [[ "$do_push" == true ]] && push_image "php-fpm" "$version"
    fi
}

# Parse arguments
PHP_VERSION=""
BUILD_ALL=false
TARGET_IMAGE=""
DO_PUSH=false

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
        -p|--push)
            DO_PUSH=true
            shift
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
if [[ -n "$TARGET_IMAGE" && "$TARGET_IMAGE" != "php-ci" && "$TARGET_IMAGE" != "drupal-ci" && "$TARGET_IMAGE" != "php-fpm" ]]; then
    echo -e "${RED}Invalid image name: $TARGET_IMAGE${NC}"
    echo "Valid images: php-ci, drupal-ci, php-fpm"
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

# Check Docker login if pushing
if [[ "$DO_PUSH" == true ]]; then
    check_docker_login
fi

# Build images
if [[ "$BUILD_ALL" == true ]]; then
    for version in "${SUPPORTED_VERSIONS[@]}"; do
        build_for_version "$version" "$TARGET_IMAGE" "$DO_PUSH"
    done
else
    version="${PHP_VERSION:-$DEFAULT_PHP_VERSION}"
    build_for_version "$version" "$TARGET_IMAGE" "$DO_PUSH"
fi

if [[ "$DO_PUSH" == true ]]; then
    echo -e "${GREEN}=== Build and push complete ===${NC}"
else
    echo -e "${GREEN}=== Build complete ===${NC}"
fi
