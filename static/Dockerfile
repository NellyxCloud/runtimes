# TAG_VERSION is the published tag; NGINX_VERSION tracks the stable line.
ARG TAG_VERSION=1.0
ARG NGINX_VERSION=stable
FROM nginx:${NGINX_VERSION}-alpine

# Static sites are served, never executed: the contract sets
# rules.noExecution and rules.onlyFiles, and the agent may add --read-only.
# nginx:alpine runs as a nonroot user, but the agent forces 1000:1000 so the
# ids have to match, and the writable paths have to be owned by it.
RUN mkdir -p /home/nellyx/app /var/log/nellyx /tmp/nellyx /var/cache/nginx \
 && chown -R 1000:1000 /home/nellyx /var/log/nellyx /tmp/nellyx /var/cache/nginx \
 && chmod 1777 /tmp/nellyx

COPY --chmod=0755 shared/entrypoint.sh /usr/local/bin/nellyx-entrypoint
COPY static/nginx.conf /etc/nginx/conf.d/default.conf

# The image runs as uid 1000, so the pid file must live on a writable path.
RUN sed -i '1i pid /tmp/nginx.pid;' /etc/nginx/nginx.conf

ENV APP_DIR=/home/nellyx/app

WORKDIR /home/nellyx/app
USER 1000:1000
EXPOSE 8080

# The contract's entrypoint, as everywhere else; nginx is started by it.
ENTRYPOINT ["/usr/local/bin/nellyx-entrypoint"]