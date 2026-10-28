ARG TAG_VERSION=1.23
ARG GO_VERSION=1.23
FROM golang:${GO_VERSION}-bookworm

# The go allowlist in the agent is `go`, `go build`, `go run`, `go test`, so the
# toolchain has to be present: this image compiles, it does not only run a
# prebuilt binary.
RUN groupadd -r -g 1000 nellyx \
 && useradd -r -u 1000 -g nellyx -d /home/nellyx -s /bin/sh nellyx \
 && mkdir -p /home/nellyx/app /var/log/nellyx /tmp/nellyx /var/lib/nellyx/builds \
 && chown -R nellyx:nellyx /home/nellyx /var/log/nellyx /tmp/nellyx /var/lib/nellyx \
 && chmod 1777 /tmp/nellyx \
 && chmod -R a+rX /usr/local/go

COPY --chmod=0755 shared/entrypoint.sh /usr/local/bin/nellyx-entrypoint

ENV APP_DIR=/home/nellyx/app \
    GOPATH=/home/nellyx/go \
    GOCACHE=/home/nellyx/.cache/go-build \
    CGO_ENABLED=0 \
    GOFLAGS=-buildvcs=false \
    HOME=/home/nellyx \
    PATH="/usr/local/go/bin:/home/nellyx/go/bin:${PATH}"

WORKDIR /home/nellyx/app
USER 1000:1000
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/nellyx-entrypoint"]