#!/bin/bash

# Beatnik OS - real first-boot hook.
# Docker Compose needs a live daemon, so starting the Beatnik Controller
# (already installed under /home/beatnik at build time, see provision.sh) can
# only happen here, once, on the Pi's actual first boot. Everything else is
# already in place by the time this runs.

set -euo pipefail

BEATNIK_USER="beatnik"
MARKER=/etc/beatnik/firstboot.done
LOG_TAG="beatnik-firstboot"

log() { echo "[$LOG_TAG] $1"; logger -t "$LOG_TAG" "$1" 2>/dev/null || true; }

finish() {
    mkdir -p "$(dirname "$MARKER")"
    touch "$MARKER"
    systemctl disable beatnik-firstboot.service 2>/dev/null || true
}
trap finish EXIT

if [ -f "$MARKER" ]; then
    log "Already ran, exiting."
    exit 0
fi

systemctl enable --now docker.service

su - "$BEATNIK_USER" -c 'cd ~/beatnik-controller && docker compose up -d'

log "Beatnik Controller started. Access it at http://$(hostname).local:8181"
