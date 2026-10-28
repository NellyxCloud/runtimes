ARG TAG_VERSION=8.3
ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-cli-bookworm

# nginx + php-fpm, because the contract sets stack.nginx and stack.fpm: the
# staticphp runtime routes through a real web server instead of the PHP
# built-in server. SUPERVISOR starts both from the entrypoint.
RUN groupadd -r nellyx 1000 \
 && useradd -r -u 1000 -g nellyx -d /home/nellyx -s /bin/sh nellyx \
 && mkdir -p /home/nellyx/app /var/log/nellyx /tmp/nellyx /var/lib/nellyx/builds \
 && chown -R nellyx:nellyx /home/nellyx /var/log/nellyx /tmp/nellyx /var/lib/nellyx \
 && chmod 1777 /tmp/nellyx \
 && apt-get update \
 && apt-get install -y --no-install-recommends nginx-light supervisor \
 && rm -rf /var/lib/apt/lists/*

COPY --chmod=0755 shared/entrypoint.sh /usr/local/bin/nellyx-entrypoint

ENV APP_DIR=/home/nellyx/app \
    HOME=/home/nellyx

WORKDIR /home/nellyx/app
USER 1000:1000
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/nellyx-entrypoint"]