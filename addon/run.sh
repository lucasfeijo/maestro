#!/bin/bash
set -e

ARGS=()
[ -n "$BASEURL" ] && ARGS+=(--baseurl "$BASEURL")
[ -n "$TOKEN" ] && ARGS+=(--token "$TOKEN")
[ "$SIMULATE" = "true" ] && ARGS+=(--simulate)
[ "$NO_NOTIFY" = "true" ] && ARGS+=(--no-notify)
[ -n "$PROGRAM" ] && ARGS+=(--program "$PROGRAM")

exec /usr/local/bin/maestro "${ARGS[@]}"
