# TAG_VERSION is the published tag; BUN_VERSION floats within the 1.x line.
ARG TAG_VERSION=1
ARG BUN_VERSION=1
FROM oven/bun:${BUN_VERSION}-debian

# uid 1000:1000, same reason as the node image: the agent runs every service as
# that uid and mounts the host workspace over /home/nellyx/app.
RUN groupadd -r -g 1000 nellyx \
 && useradd -r -u 1000 -g nellyx -d /home/nellyx -s /bin/sh nellyx \
 && mkdir -p /home/nellyx/app /var/log/nellyx /tmp/nellyx /var/lib/nellyx/builds \
 && chown -R nellyx:nellyx /home/nellyx /var/log/nellyx /tmp/nellyx /var/lib/nellyx \
 && chmod 1777 /tmp/nellyx

COPY --chmod=0755 shared/entrypoint.sh /usr/local/bin/nellyx-entrypoint

ENV APP_DIR=/home/nellyx/app \
    BUN_INSTALL=/home/nellyx/.bun \
    NODE_ENV=production

WORKDIR /home/nellyx/app
USER 1000:1000
EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/nellyx-entrypoint"]