# TAG_VERSION is the published tag; DENO_VERSION is resolved by the workflow to
# the latest 2.x release on every refresh (the registry has no floating 2.x tag).
ARG TAG_VERSION=2.0
ARG DENO_VERSION=2.9.8
FROM denoland/deno:${DENO_VERSION}

# Deno's image ships as a nonroot user already, but the agent forces
# 1000:1000, so the ids have to line up.
RUN groupadd -r -g 1000 nellyx \
 && useradd -r -u 1000 -g nellyx -d /home/nellyx -s /bin/sh nellyx \
 && mkdir -p /home/nellyx/app /var/log/nellyx /tmp/nellyx /var/lib/nellyx/builds \
 && chown -R nellyx:nellyx /home/nellyx /var/log/nellyx /tmp/nellyx /var/lib/nellyx \
 && chmod 1777 /tmp/nellyx

COPY --chmod=0755 shared/entrypoint.sh /usr/local/bin/nellyx-entrypoint

ENV APP_DIR=/home/nellyx/app \
    DENO_DIR=/home/nellyx/.cache/deno \
    DENO_NO_UPDATE_CHECK=1 \
    HOME=/home/nellyx

WORKDIR /home/nellyx/app
USER 1000:1000
EXPOSE 8000

ENTRYPOINT ["/usr/local/bin/nellyx-entrypoint"]