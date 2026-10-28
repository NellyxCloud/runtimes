ARG TAG_VERSION=3.14
ARG PYTHON_VERSION=3.14
FROM python:${PYTHON_VERSION}-slim-bookworm

RUN groupadd -r -g 1000 nellyx \
 && useradd -r -u 1000 -g nellyx -d /home/nellyx -s /bin/sh nellyx \
 && mkdir -p /home/nellyx/app /var/log/nellyx /tmp/nellyx /var/lib/nellyx/builds \
 && chown -R nellyx:nellyx /home/nellyx /var/log/nellyx /tmp/nellyx /var/lib/nellyx \
 && chmod 1777 /tmp/nellyx

# The agent's python allowlist (service.ts) accepts pip, uvicorn, gunicorn,
# poetry and pdm, so the common ones ship in the image; anything else is an
# INSTALL_COMMAND away.
RUN pip install --no-cache-dir --break-system-packages \
      "uvicorn[standard]" gunicorn \
 && ln -sf /usr/local/bin/uvicorn /usr/local/bin/uvicorn3

COPY --chmod=0755 shared/entrypoint.sh /usr/local/bin/nellyx-entrypoint

ENV APP_DIR=/home/nellyx/app \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/home/nellyx/.local/bin:${PATH}"

WORKDIR /home/nellyx/app
USER 1000:1000
EXPOSE 8000

ENTRYPOINT ["/usr/local/bin/nellyx-entrypoint"]