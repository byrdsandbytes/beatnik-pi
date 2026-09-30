#!/bin/bash

# Beatnik OS - real first-boot hook.
# Runs once via beatnik-firstboot.service on actual Raspberry Pi hardware
# (real systemd, real network, real Docker) - things that can't run safely
# inside the QEMU chroot used during image provisioning (ci/provision.sh).
# Installs Docker + the Beatnik Controller web UI for the account created by
# Raspberry Pi Imager, then disables itself so it never runs again.

set -euo pipefail

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

# Find the real login user created by Raspberry Pi Imager (first uid >= 1000).
REAL_USER=$(getent passwd | awk -F: '$3>=1000 && $3<60000 {print $1; exit}')
if [ -z "$REAL_USER" ]; then
    log "No regular user account found yet, skipping Docker/Controller setup."
    exit 0
fi
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
log "Provisioning for user: $REAL_USER ($REAL_HOME)"

if ! command -v docker &> /dev/null; then
    log "Installing Docker..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sh /tmp/get-docker.sh
    rm -f /tmp/get-docker.sh
    usermod -aG docker "$REAL_USER"
fi

if ! docker compose version &> /dev/null; then
    apt-get update
    apt-get install -y docker-compose-plugin
fi

systemctl enable --now docker.service

CONTROLLER_DIR="$REAL_HOME/beatnik-controller"
rm -rf "$CONTROLLER_DIR"
git clone https://github.com/byrdsandbytes/beatnik-controller.git "$CONTROLLER_DIR"
chown -R "$REAL_USER:$REAL_USER" "$CONTROLLER_DIR"

cd "$CONTROLLER_DIR"
docker compose up -d

log "Beatnik Controller started. Access it at http://$(hostname).local:8181"
