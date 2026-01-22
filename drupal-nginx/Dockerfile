FROM nginx:alpine

# UID 41821 = d(4) r(18) u(21) letter positions
ARG DRUPAL_UID=41821
ARG DRUPAL_GID=41821

LABEL maintainer="tavib47"
LABEL description="Base Nginx image for Drupal with drupal user configured"

# Create drupal user and group with configurable UID/GID
RUN addgroup -g ${DRUPAL_GID} drupal && \
    adduser -u ${DRUPAL_UID} -G drupal -D -H drupal

# Create necessary directories and set permissions
RUN mkdir -p /var/www/html/web \
    /tmp/client_temp \
    /tmp/proxy_temp \
    /tmp/fastcgi_temp \
    /tmp/uwsgi_temp \
    /tmp/scgi_temp && \
    chown -R drupal:drupal /var/www/html \
    /tmp/client_temp \
    /tmp/proxy_temp \
    /tmp/fastcgi_temp \
    /tmp/uwsgi_temp \
    /tmp/scgi_temp \
    /var/cache/nginx \
    /var/log/nginx

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf.template /etc/nginx/templates/default.conf.template

# Environment variables for PHP-FPM connection
ENV PHP_FPM_HOST=php
ENV PHP_FPM_PORT=9000
ENV ROBOTS_FILE=robots.txt

# Environment variables for nginx tuning
ENV NGINX_CLIENT_MAX_BODY_SIZE=50M
ENV NGINX_FASTCGI_CONNECT_TIMEOUT=60s
ENV NGINX_FASTCGI_SEND_TIMEOUT=60s
ENV NGINX_FASTCGI_READ_TIMEOUT=300s

WORKDIR /var/www/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
