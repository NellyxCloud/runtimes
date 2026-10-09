ARG NGINX_VERSION=1.27
FROM nginx:${NGINX_VERSION}-alpine

# Static sites are served, never executed: the contract sets
# rules.noExecution and rules.onlyFiles, and the agent may add --read-only.
# nginx:alpine runs as a nonroot user, but the agent forces 1000:1000 so the
# ids have to match, and the writable paths have to be owned by it.
RUN apk add --no-cache su-exec \
 && addgroup -g 1000 nellyx 2>/dev/null || true \
 && adduser -D -u 1000 -G nellyx nellyx 2>/dev/null || true \
 && mkdir -p /home/nellyx/app /var/log/nellyx /tmp/nellyx /var/cache/nginx \
 && chown -R nellyx:nellyx /home/nellyx /var/log/nellyx /tmp/nellyx /var/cache/nginx \
 && chmod 1777 /tmp/nellyx

COPY --chmod=0755 shared/entrypoint.sh /usr/local/bin/nellyx-entrypoint
COPY static/nginx.conf /etc/nginx/templates/default.conf.template

ENV APP_DIR=/home/nellyx/app

WORKDIR /home/nellyx/app
USER 1000:1000
EXPOSE 8080

# The contract's entrypoint, as everywhere else; nginx is started by it.
ENTRYPOINT ["/usr/local/bin/nellyx-entrypoint"]