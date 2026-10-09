#!/bin/sh
# Nellyx runtime entrypoint, shared by every runtime image.
#
# The node passes three commands and a port; this runs them in order and hands
# the last one's output to PID 1's caller. It is what the runtime contracts in
# NellyxAgent point at (see src/runtime/contracts.builtin.ts), so its path is
# part of the contract: /usr/local/bin/nellyx-entrypoint.
#
# Failures are loud on purpose. A service that came up because its install step
# silently did nothing is worse than one that exits, because the panel would
# report it running while it serves nothing.

set -eu

APP_DIR="${APP_DIR:-/home/nellyx/app}"
cd "$APP_DIR"

log() {
	echo "[nellyx-runtime] $*"
}

run_optional() {
	label="$1"
	command="$2"
	if [ -z "$command" ]; then
		return 0
	fi
	log "$label: $command"
	# shellcheck disable=SC2086
	if ! sh -c "$command"; then
		log "$label failed (exit $?)"
		return 1
	fi
}

if [ -f .npmrc ] || [ -f .yarnrc ]; then
	: # project-local package manager config, nothing to do
fi

run_optional install "${INSTALL_COMMAND:-}"
run_optional build "${BUILD_COMMAND:-}"

START="${START_COMMAND:-}"
if [ -z "$START" ]; then
	log "no START_COMMAND provided; nothing to run"
	exit 1
fi

: "${PORT:=3000}"
export PORT
export NODE_ENV="${NODE_ENV:-production}"

log "start on port $PORT: $START"

# exec so the service becomes PID 1: signals (stop, restart, docker stop) reach
# the app itself instead of this shell, which is what makes a stop prompt
# instead of a kill after the grace period.
# shellcheck disable=SC2086
exec sh -c "$START"