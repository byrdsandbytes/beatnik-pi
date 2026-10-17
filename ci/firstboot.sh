#!/bin/bash

# Beatnik OS - real first-boot hook.
# Docker Compose needs a live daemon, so starting the Beatnik Controller
# can only happen here, once, on the Pi's actual first boot.

set -euo pipefail

BEATNIK_USER="beatnik"
MARKER=/etc/beatnik/firstboot.done
LOG_TAG="beatnik-firstboot"

log() { echo "[$LOG_TAG] $1"; logger -t "$LOG_TAG" "$1" 2>/dev/null || true; }

if [ -f "$MARKER" ]; then
    log "Already ran, exiting."
    exit 0
fi

systemctl enable --now docker.service

# 1. Wait for Docker daemon socket to be fully responsive
log "Waiting for Docker daemon..."
until docker info >/dev/null 2>&1; do
    sleep 2
done

# 2. Wait for actual internet routing/DNS to pull the container image
log "Waiting for internet connectivity..."
until ping -c 1 -W 2 github.com >/dev/null 2>&1; do
    sleep 2
done

# 3. Start the controller
log "Starting Beatnik Controller..."
su - "$BEATNIK_USER" -c 'cd ~/beatnik-controller && docker compose up -d'

# 4. Mark as done ONLY on success (removed the EXIT trap)
mkdir -p "$(dirname "$MARKER")"
touch "$MARKER"
systemctl disable beatnik-firstboot.service 2>/dev/null || true

log "Beatnik Controller started. Access it at http://$(hostname).local"