# Alpine CI Image

[![Docker Hub](https://img.shields.io/docker/pulls/tavib47/alpine-ci?label=pulls&logo=docker)](https://hub.docker.com/r/tavib47/alpine-ci)
[![Image Size](https://img.shields.io/docker/image-size/tavib47/alpine-ci/latest?logo=docker)](https://hub.docker.com/r/tavib47/alpine-ci)

A lightweight Alpine image for CI/CD utility tasks such as SSH operations, API calls, and JSON processing.

## Features

- `openssh-client` — SSH, SCP, ssh-agent, ssh-add for remote operations
- `curl` — HTTP requests for notifications and file uploads
- `jq` — JSON parsing for API response processing

## Supported Tags

- `latest`

## Quick Start

```bash
docker pull tavib47/alpine-ci
```

## Usage Examples

### SSH Setup

```yaml
.ssh_setup:
  image: tavib47/alpine-ci
  before_script:
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" | ssh-add -
    - mkdir -p ~/.ssh
    - chmod 700 ~/.ssh
```

### Discord Notification

```yaml
notify:
  image: tavib47/alpine-ci
  script:
    - |
      curl -H "Content-Type: application/json" \
        -d "{\"content\": \"Deployment complete\"}" \
        "$DISCORD_WEBHOOK_URL"
```

### GitLab Package Registry Cleanup

```yaml
cleanup:
  image: tavib47/alpine-ci
  script:
    - |
      curl -s --header "PRIVATE-TOKEN: $CI_TOKEN" \
        "$CI_API_V4_URL/projects/$CI_PROJECT_ID/packages" | \
        jq -r '.[] | .id' | while read id; do
          curl -s --request DELETE \
            --header "PRIVATE-TOKEN: $CI_TOKEN" \
            "$CI_API_V4_URL/projects/$CI_PROJECT_ID/packages/$id"
        done
```

## Building

```bash
docker build -t tavib47/alpine-ci:latest ./alpine-ci
```

## Related Images

- [tavib47/php-ci](https://hub.docker.com/r/tavib47/php-ci) — PHP CI image with Composer, Git, and Node.js
- [tavib47/drupal-ci](https://hub.docker.com/r/tavib47/drupal-ci) — Drupal CI image with Drush and Robo

## Source

[GitHub Repository](https://github.com/tavib47/docker)
