#!/bin/bash

set -e

# Default values
DEFAULT_PHP_VERSION="8.4"
DEFAULT_NODE_VERSION="22"
SUPPORTED_PHP_VERSIONS=("7.4" "8.1" "8.2" "8.3" "8.4" "8.5")
SUPPORTED_NODE_VERSIONS=("18" "20" "22" "24")
LATEST_PHP_VERSION="8.5"
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
    echo "  -v, --version VERSION   Build for specific PHP version (${SUPPORTED_PHP_VERSIONS[*]})"
    echo "  -n, --node VERSION      Build with specific Node.js version (${SUPPORTED_NODE_VERSIONS[*]})"
    echo "                          Only applies to php-ci and drupal-ci images"
    echo "  -a, --all               Build for all supported PHP versions"
    echo "  -N, --all-node          Build for all supported Node.js versions"
    echo "  -i, --image IMAGE       Build only specific image (php-ci, drupal-ci, php-fpm, drupal-php, drupal-nginx, alpine-ci)"
    echo "  -p, --push              Push images to Docker Hub after building"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Tag conventions:"
    echo "  - Without -n: tavib47/<image>:<php-version> (uses Node $DEFAULT_NODE_VERSION)"
    echo "  - With -n:    tavib47/<image>:<php-version>-node<node-version>"
    echo ""
    echo "Examples:"
    echo "  $0                      Build all images for PHP $DEFAULT_PHP_VERSION (Node $DEFAULT_NODE_VERSION)"
    echo "  $0 -v 8.2               Build all images for PHP 8.2"
    echo "  $0 -v 8.4 -n 20         Build php-ci/drupal-ci with PHP 8.4 and Node 20"
    echo "  $0 -a                   Build all images for all PHP versions"
    echo "  $0 -v 8.4 -N            Build PHP 8.4 with all Node versions"
    echo "  $0 -a -N                Build full matrix (all PHP × all Node versions)"
    echo "  $0 -v 8.4 -i php-ci     Build only php-ci for PHP 8.4"
    echo "  $0 -a --push            Build all versions and push to Docker Hub"
}

# PHP 7.x is built on Alpine 3.16 which only supports Node 18
# Returns the compatible Node version for a given PHP version
get_node_version_for_php() {
    local php_version=$1
    local node_version=$2
    if [[ "$php_version" == 7.* ]]; then
        echo "18"
    else
        echo "$node_version"
    fi
}

# Returns the Node Docker image to use for a given PHP version
get_node_image() {
    local php_version=$1
    local node_version=$2
    if [[ "$php_version" == 7.* ]]; then
        echo "node:18-alpine3.16"
    else
        echo "node:${node_version}-alpine"
    fi
}

get_tag() {
    local image=$1
    local php_version=$2
    local node_version=$3

    if [[ "$image" == "php-fpm" || "$image" == "drupal-php" ]]; then
        # php-fpm and drupal-php don't use Node.js
        echo "${IMAGE_PREFIX}/${image}:${php_version}"
    elif [[ "$image" == "drupal-nginx" || "$image" == "alpine-ci" ]]; then
        # drupal-nginx and alpine-ci don't use PHP or Node.js versions
        echo "${IMAGE_PREFIX}/${image}:latest"
    elif [[ -n "$node_version" && "$node_version" != "$DEFAULT_NODE_VERSION" ]]; then
        # Custom Node version specified
        echo "${IMAGE_PREFIX}/${image}:${php_version}-node${node_version}"
    else
        # Default Node version (no suffix)
        echo "${IMAGE_PREFIX}/${image}:${php_version}"
    fi
}

build_image() {
    local image=$1
    local php_version=$2
    local node_version=$3
    local tag=$(get_tag "$image" "$php_version" "$node_version")

    echo -e "${YELLOW}Building ${tag}...${NC}"

    if [[ "$image" == "drupal-ci" ]]; then
        local php_ci_tag=$(get_tag "php-ci" "$php_version" "$node_version")
        docker build \
            --build-arg PHP_VERSION="$php_version" \
            --build-arg PHP_CI_IMAGE="${php_ci_tag}" \
            -t "$tag" \
            "./${image}"
    elif [[ "$image" == "php-ci" ]]; then
        local effective_node="${node_version:-$DEFAULT_NODE_VERSION}"
        local node_image=$(get_node_image "$php_version" "$effective_node")
        effective_node=$(get_node_version_for_php "$php_version" "$effective_node")
        docker build \
            --build-arg PHP_VERSION="$php_version" \
            --build-arg NODE_VERSION="$effective_node" \
            --build-arg NODE_IMAGE="$node_image" \
            -t "$tag" \
            "./${image}"
    elif [[ "$image" == "drupal-php" ]]; then
        # drupal-php depends on php-fpm (no Node.js)
        docker build \
            --build-arg PHP_VERSION="$php_version" \
            -t "$tag" \
            "./${image}"
    elif [[ "$image" == "drupal-nginx" || "$image" == "alpine-ci" ]]; then
        # drupal-nginx and alpine-ci are standalone (no PHP or Node.js)
        docker build \
            -t "$tag" \
            "./${image}"
    else
        # php-fpm (no Node.js)
        docker build \
            --build-arg PHP_VERSION="$php_version" \
            -t "$tag" \
            "./${image}"
    fi

    # For default Node version, also tag with explicit node version (e.g., 8.4 and 8.4-node22)
    if [[ "$image" != "php-fpm" && "$image" != "drupal-php" && "$image" != "drupal-nginx" && "$image" != "alpine-ci" && ( -z "$node_version" || "$node_version" == "$DEFAULT_NODE_VERSION" ) ]]; then
        local explicit_node_tag="${IMAGE_PREFIX}/${image}:${php_version}-node${DEFAULT_NODE_VERSION}"
        echo -e "${YELLOW}Tagging ${tag} as ${explicit_node_tag}${NC}"
        docker tag "$tag" "$explicit_node_tag"
    fi

    # For PHP 7.x CI images, also create a simple <php-version> tag (e.g., 7.4)
    # since Node 18 is the only supported version for these
    if [[ "$image" != "php-fpm" && "$image" != "drupal-php" && "$image" != "drupal-nginx" && "$image" != "alpine-ci" && "$php_version" == 7.* ]]; then
        local simple_tag="${IMAGE_PREFIX}/${image}:${php_version}"
        echo -e "${YELLOW}Tagging ${tag} as ${simple_tag}${NC}"
        docker tag "$tag" "$simple_tag"
    fi

    # Tag as latest if this is the latest PHP version and default Node version
    # drupal-nginx is always tagged as latest (no PHP version)
    if [[ "$image" == "drupal-nginx" || "$image" == "alpine-ci" ]]; then
        : # already tagged as latest
    elif [[ "$php_version" == "$LATEST_PHP_VERSION" && ( -z "$node_version" || "$node_version" == "$DEFAULT_NODE_VERSION" ) ]]; then
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
    local php_version=$2
    local node_version=$3
    local tag=$(get_tag "$image" "$php_version" "$node_version")

    echo -e "${BLUE}Pushing ${tag}...${NC}"
    docker push "$tag"

    # Push explicit node tag for default Node version (e.g., 8.4-node22)
    if [[ "$image" != "php-fpm" && "$image" != "drupal-php" && "$image" != "drupal-nginx" && "$image" != "alpine-ci" && ( -z "$node_version" || "$node_version" == "$DEFAULT_NODE_VERSION" ) ]]; then
        local explicit_node_tag="${IMAGE_PREFIX}/${image}:${php_version}-node${DEFAULT_NODE_VERSION}"
        echo -e "${BLUE}Pushing ${explicit_node_tag}...${NC}"
        docker push "$explicit_node_tag"
    fi

    # Push simple tag for PHP 7.x CI images (e.g., 7.4)
    if [[ "$image" != "php-fpm" && "$image" != "drupal-php" && "$image" != "drupal-nginx" && "$image" != "alpine-ci" && "$php_version" == 7.* ]]; then
        local simple_tag="${IMAGE_PREFIX}/${image}:${php_version}"
        echo -e "${BLUE}Pushing ${simple_tag}...${NC}"
        docker push "$simple_tag"
    fi

    # Push latest tag if this is the latest PHP version and default Node version
    # drupal-nginx is always tagged as latest (no PHP version)
    if [[ "$image" == "drupal-nginx" || "$image" == "alpine-ci" ]]; then
        : # already pushed as latest
    elif [[ "$php_version" == "$LATEST_PHP_VERSION" && ( -z "$node_version" || "$node_version" == "$DEFAULT_NODE_VERSION" ) ]]; then
        local latest_tag="${IMAGE_PREFIX}/${image}:latest"
        echo -e "${BLUE}Pushing ${latest_tag}...${NC}"
        docker push "$latest_tag"
    fi

    echo -e "${GREEN}Successfully pushed ${tag}${NC}"
}

build_for_version() {
    local php_version=$1
    local node_version=$2
    local image=$3
    local do_push=$4

    # PHP 7.x only supports Node 18 (Alpine 3.16 compatibility)
    if [[ "$php_version" == 7.* ]]; then
        if [[ -n "$node_version" && "$node_version" != "18" ]]; then
            echo -e "${YELLOW}Warning: PHP ${php_version} only supports Node 18 (Alpine 3.16). Ignoring Node ${node_version}.${NC}"
        fi
        node_version="18"
    fi

    echo -e "${GREEN}=== Building for PHP ${php_version}${node_version:+ with Node ${node_version}} ===${NC}"

    if [[ -z "$image" || "$image" == "php-ci" ]]; then
        build_image "php-ci" "$php_version" "$node_version"
        [[ "$do_push" == true ]] && push_image "php-ci" "$php_version" "$node_version"
    fi

    if [[ -z "$image" || "$image" == "drupal-ci" ]]; then
        build_image "drupal-ci" "$php_version" "$node_version"
        [[ "$do_push" == true ]] && push_image "drupal-ci" "$php_version" "$node_version"
    fi

    if [[ -z "$image" || "$image" == "php-fpm" ]]; then
        build_image "php-fpm" "$php_version" ""
        [[ "$do_push" == true ]] && push_image "php-fpm" "$php_version" ""
    fi

    if [[ -z "$image" || "$image" == "drupal-php" ]]; then
        build_image "drupal-php" "$php_version" ""
        [[ "$do_push" == true ]] && push_image "drupal-php" "$php_version" ""
    fi

    # drupal-nginx and alpine-ci only need to be built once (no PHP version)
    if [[ "$image" == "drupal-nginx" ]]; then
        build_image "drupal-nginx" "" ""
        [[ "$do_push" == true ]] && push_image "drupal-nginx" "" ""
    fi

    if [[ "$image" == "alpine-ci" ]]; then
        build_image "alpine-ci" "" ""
        [[ "$do_push" == true ]] && push_image "alpine-ci" "" ""
    fi
}

# Parse arguments
PHP_VERSION=""
NODE_VERSION=""
BUILD_ALL_PHP=false
BUILD_ALL_NODE=false
TARGET_IMAGE=""
DO_PUSH=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--version)
            PHP_VERSION="$2"
            shift 2
            ;;
        -n|--node)
            NODE_VERSION="$2"
            shift 2
            ;;
        -a|--all)
            BUILD_ALL_PHP=true
            shift
            ;;
        -N|--all-node)
            BUILD_ALL_NODE=true
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
if [[ -n "$TARGET_IMAGE" && "$TARGET_IMAGE" != "php-ci" && "$TARGET_IMAGE" != "drupal-ci" && "$TARGET_IMAGE" != "php-fpm" && "$TARGET_IMAGE" != "drupal-php" && "$TARGET_IMAGE" != "drupal-nginx" && "$TARGET_IMAGE" != "alpine-ci" ]]; then
    echo -e "${RED}Invalid image name: $TARGET_IMAGE${NC}"
    echo "Valid images: php-ci, drupal-ci, php-fpm, drupal-php, drupal-nginx, alpine-ci"
    exit 1
fi

# Validate PHP version if specified
if [[ -n "$PHP_VERSION" ]]; then
    valid=false
    for v in "${SUPPORTED_PHP_VERSIONS[@]}"; do
        if [[ "$v" == "$PHP_VERSION" ]]; then
            valid=true
            break
        fi
    done
    if [[ "$valid" == false ]]; then
        echo -e "${RED}Invalid PHP version: $PHP_VERSION${NC}"
        echo "Supported versions: ${SUPPORTED_PHP_VERSIONS[*]}"
        exit 1
    fi
fi

# Validate Node version if specified
if [[ -n "$NODE_VERSION" ]]; then
    if [[ "$BUILD_ALL_NODE" == true ]]; then
        echo -e "${RED}Cannot use both -n and -N together${NC}"
        exit 1
    fi

    valid=false
    for v in "${SUPPORTED_NODE_VERSIONS[@]}"; do
        if [[ "$v" == "$NODE_VERSION" ]]; then
            valid=true
            break
        fi
    done
    if [[ "$valid" == false ]]; then
        echo -e "${RED}Invalid Node.js version: $NODE_VERSION${NC}"
        echo "Supported versions: ${SUPPORTED_NODE_VERSIONS[*]}"
        exit 1
    fi

    # Warn if Node version specified for images without Node.js
    if [[ "$TARGET_IMAGE" == "php-fpm" || "$TARGET_IMAGE" == "drupal-php" || "$TARGET_IMAGE" == "drupal-nginx" || "$TARGET_IMAGE" == "alpine-ci" ]]; then
        echo -e "${YELLOW}Warning: Node.js version is ignored for $TARGET_IMAGE (no Node.js in that image)${NC}"
    fi
fi

# Warn if --all-node specified for images without Node.js
if [[ "$BUILD_ALL_NODE" == true && ( "$TARGET_IMAGE" == "php-fpm" || "$TARGET_IMAGE" == "drupal-php" || "$TARGET_IMAGE" == "drupal-nginx" || "$TARGET_IMAGE" == "alpine-ci" ) ]]; then
    echo -e "${YELLOW}Warning: --all-node is ignored for $TARGET_IMAGE (no Node.js in that image)${NC}"
    BUILD_ALL_NODE=false
fi

# Check Docker login if pushing
if [[ "$DO_PUSH" == true ]]; then
    check_docker_login
fi

# Build images
if [[ "$BUILD_ALL_PHP" == true ]]; then
    if [[ "$BUILD_ALL_NODE" == true ]]; then
        # Full matrix: all PHP × all Node versions
        for php_version in "${SUPPORTED_PHP_VERSIONS[@]}"; do
            for node_version in "${SUPPORTED_NODE_VERSIONS[@]}"; do
                build_for_version "$php_version" "$node_version" "$TARGET_IMAGE" "$DO_PUSH"
            done
        done
    else
        # All PHP versions, single Node version
        for php_version in "${SUPPORTED_PHP_VERSIONS[@]}"; do
            build_for_version "$php_version" "$NODE_VERSION" "$TARGET_IMAGE" "$DO_PUSH"
        done
    fi
else
    php_version="${PHP_VERSION:-$DEFAULT_PHP_VERSION}"
    if [[ "$BUILD_ALL_NODE" == true ]]; then
        # Single PHP version, all Node versions
        for node_version in "${SUPPORTED_NODE_VERSIONS[@]}"; do
            build_for_version "$php_version" "$node_version" "$TARGET_IMAGE" "$DO_PUSH"
        done
    else
        # Single PHP version, single Node version
        build_for_version "$php_version" "$NODE_VERSION" "$TARGET_IMAGE" "$DO_PUSH"
    fi
fi

if [[ "$DO_PUSH" == true ]]; then
    echo -e "${GREEN}=== Build and push complete ===${NC}"
else
    echo -e "${GREEN}=== Build complete ===${NC}"
fi
