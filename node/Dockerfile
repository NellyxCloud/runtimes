ARG NODE_VERSION=22
# The workflow derives the published tag from the first VERSION arg, so
# NODE_VERSION stays first. Bun lives in this image because the agent maps the
# `bun` runtime to node-22 and the panel's default template runs `bun run ...`.
ARG BUN_VERSION=1.4.2
FROM node:${NODE_VERSION}-bookworm-slim

COPY --from=oven/bun:${BUN_VERSION}-debian /usr/local/bin/bun /usr/local/bin/bun

# The agent runs every container as 1000:1000 and mounts the host workspace at
# /home/nellyx/app, so the image needs that uid to own the workdir and the log
# directory. Without it the service starts and then cannot write anything.
RUN groupadd -r nellyx 1000 \
 && useradd -r -u 1000 -g nellyx -d /home/nellyx -s /bin/sh nellyx \
 && mkdir -p /home/nellyx/app /var/log/nellyx /tmp/nellyx /var/lib/nellyx/builds \
 && chown -R nellyx:nellyx /home/nellyx /var/log/nellyx /tmp/nellyx /var/lib/nellyx \
 && chmod 1777 /tmp/nellyx

COPY --chmod=0755 shared/entrypoint.sh /usr/local/bin/nellyx-entrypoint

ENV APP_DIR=/home/nellyx/app \
    NODE_ENV=production \
    NPM_CONFIG_UPDATE_NOTIFIER=false

WORKDIR /home/nellyx/app
USER 1000:1000
EXPOSE 3000

# The contract's entrypoint; CMD stays empty so the contract is what decides,
# and a service pinned to its own image can override it.
ENTRYPOINT ["/usr/local/bin/nellyx-entrypoint"]