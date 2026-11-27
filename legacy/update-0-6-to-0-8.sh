#!/bin/bash

# Beatnik Pi 0.6 -> 0.8 Update Script
#
# Beatnik 0.6 ran the Hardware API, Bleno and CamillaDSP from Git checkouts in
# the user's home folder. 0.8 ships them as Debian packages. This script:
#   1. removes the old checkouts and the unit files they wrote,
#   2. installs the 0.8 Snapserver config (the Hardware API package's preamp
#      service waits for its Line-In pipe and hangs the install without it),
#   3. installs Node.js 22 and the Hardware API and Bleno release packages,
#   4. enables Snapserver and the Line-In preamp only on a server,
#   5. optionally installs/updates the self-hosted Beatnik Controller.
#
# Docs: docs/advanced/legacy-updating/migration-0-6-to0-8.md

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

REPO_RAW="https://raw.githubusercontent.com/byrdsandbytes/beatnik-pi/master"
CAMILLA_VERSION="v2.0.3"
LINE_IN_PIPE="/tmp/snap-line-in"

ROLE=""
SELFHOST_CONTROLLER=""
REMOVE_CONTROLLER="n"

# Answers come from the terminal, so the script also works when piped into bash.
ask() {
    local prompt="$1" reply
    read -r -p "$prompt" reply < /dev/tty
    echo "$reply"
}

ask_yes_no() {
    local prompt="$1" default="$2" reply
    while true; do
        reply=$(ask "$prompt")
        reply=${reply:-$default}
        case "$reply" in
            [Yy]*) echo "y"; return ;;
            [Nn]*) echo "n"; return ;;
            *) echo "Please answer y or n." > /dev/tty ;;
        esac
    done
}

latest_tag() {
    curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
        | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1
}

# ---------------------------------------------------------------------------
# Checks and questions
# ---------------------------------------------------------------------------

preflight() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Run this script as your normal user (e.g. beatnik), not as root. It uses sudo where needed."
        exit 1
    fi
    if [[ "$(dpkg --print-architecture)" != "arm64" ]]; then
        log_error "Beatnik 0.8 needs a 64-bit (arm64) Raspberry Pi OS. This system is $(dpkg --print-architecture)."
        exit 1
    fi
    if ! curl -fsS --max-time 10 -o /dev/null https://api.github.com; then
        log_error "Cannot reach GitHub. Check the internet connection and try again."
        exit 1
    fi
    sudo -v
}

show_current_state() {
    echo
    log_info "Found on this device:"
    local d
    for d in beatnik-hardware-api beatnik-bleno camilladsp beatnik-controller; do
        if [[ -d "$HOME/$d" ]]; then echo "   - ~/$d"; fi
    done
    dpkg -l 'beatnik-*' 2>/dev/null | awk '/^ii/ {print "   - package " $2 " " $3}' || true
    echo
}

ask_questions() {
    echo "How should this device run?"
    echo "  1) Server - runs Snapserver and plays audio itself"
    echo "  2) Client - plays audio from another Beatnik server (Snapserver stays off)"
    while [[ -z "$ROLE" ]]; do
        case "$(ask "Choice [1]: ")" in
            ""|1) ROLE="server" ;;
            2)    ROLE="client" ;;
            *)    echo "Please enter 1 or 2." ;;
        esac
    done

    echo
    local default="n" hint="y/N"
    if [[ "$ROLE" == "server" ]]; then default="y"; hint="Y/n"; fi
    SELFHOST_CONTROLLER=$(ask_yes_no "Self-host the Beatnik Controller web app on this device (Docker)? [$hint]: " "$default")

    if [[ "$SELFHOST_CONTROLLER" == "n" && -d "$HOME/beatnik-controller" ]]; then
        REMOVE_CONTROLLER=$(ask_yes_no "Stop and remove the existing controller in ~/beatnik-controller? [y/N]: " "n")
    fi

    echo
    log_info "Summary:"
    echo "   - Role: $ROLE"
    echo "   - Self-hosted controller: $SELFHOST_CONTROLLER"
    [[ "$REMOVE_CONTROLLER" == "y" ]] && echo "   - Remove existing controller: yes"
    echo "   - Snapserver config is replaced with the 0.8 config (a backup is kept)"
    echo "   - Old checkouts in your home folder are deleted"
    echo
    if [[ "$(ask_yes_no "Continue? [y/N]: " "n")" != "y" ]]; then
        log_info "Update cancelled. Nothing was changed."
        exit 0
    fi
}

# ---------------------------------------------------------------------------
# Remove the 0.6 installation
# ---------------------------------------------------------------------------

backup_camilla_config() {
    local src="$HOME/camilladsp/configs/client_config.yml"
    if [[ -f "$src" ]]; then
        cp "$src" "$HOME/client_config.yml.0-6-backup"
        log_success "Backed up CamillaDSP config to ~/client_config.yml.0-6-backup"
    fi
}

remove_old_install() {
    log_info "Stopping old services..."
    local unit file
    for unit in beatnik-hardware.service beatnik-bleno.service camilladsp.service camilladsp-preamp.service; do
        sudo systemctl stop "$unit" 2>/dev/null || true
        sudo systemctl disable "$unit" 2>/dev/null || true
    done

    # Only delete unit files the 0.6 scripts wrote. Files owned by an installed
    # package are left alone; the reinstall below replaces them anyway.
    for unit in beatnik-hardware.service beatnik-bleno.service camilladsp.service; do
        file="/etc/systemd/system/$unit"
        if [[ -f "$file" ]] && ! dpkg -S "$file" >/dev/null 2>&1; then
            sudo rm -f "$file"
            log_info "Removed old $file"
        fi
    done
    sudo systemctl daemon-reload

    rm -rf "$HOME/beatnik-hardware-api" "$HOME/beatnik-bleno" "$HOME/camilladsp"
    log_success "Old 0.6 installation removed"
}

# ---------------------------------------------------------------------------
# Snapcast
# ---------------------------------------------------------------------------

install_stream_sources_if_missing() {
    if ! command -v shairport-sync >/dev/null 2>&1; then
        log_info "Installing Shairport-Sync (AirPlay)..."
        sudo apt-get install -y shairport-sync
        sudo systemctl disable --now shairport-sync.service 2>/dev/null || true
    fi
    if ! command -v librespot >/dev/null 2>&1; then
        log_info "Installing Raspotify (Spotify Connect)..."
        curl -sL https://dtcooper.github.io/raspotify/install.sh | sh \
            || log_warning "Raspotify installation failed; Spotify Connect will not be available"
        sudo systemctl disable --now raspotify.service 2>/dev/null || true
    fi
}

# Every device gets the 0.8 config. Only a server enables and starts Snapserver,
# which creates the Line-In pipe the preamp service waits for.
configure_snapserver() {
    log_info "Installing the 0.8 Snapserver config..."
    if [[ -f /etc/snapserver.conf ]]; then
        sudo cp /etc/snapserver.conf /etc/snapserver.conf.0-6-backup
        log_info "Backed up /etc/snapserver.conf to /etc/snapserver.conf.0-6-backup"
    fi
    sudo wget -q -O /etc/snapserver.conf "$REPO_RAW/ci/snapserver.conf"
    sudo wget -q -O /etc/shairport-snapcast.conf "$REPO_RAW/ci/shairport-snapcast.conf"

    if [[ "$ROLE" != "server" ]]; then
        log_info "Client: Snapserver is not enabled or started"
        return
    fi

    sudo systemctl enable snapserver.service
    sudo systemctl restart snapserver.service

    log_info "Waiting for Snapserver to create $LINE_IN_PIPE..."
    local _
    for _ in $(seq 1 30); do
        if [[ -p "$LINE_IN_PIPE" ]]; then
            log_success "Snapserver is running with the 0.8 config"
            return
        fi
        sleep 1
    done
    log_error "$LINE_IN_PIPE was not created. Installing the Hardware API now would hang."
    log_error "Check Snapserver with: journalctl -u snapserver -n 60 --no-pager"
    exit 1
}

# ---------------------------------------------------------------------------
# Beatnik packages
# ---------------------------------------------------------------------------

install_nodejs22() {
    local major=0
    if [[ -x /usr/bin/node ]]; then
        major=$(/usr/bin/node --version | sed -E 's/^v([0-9]+).*/\1/')
    fi
    if (( major >= 22 )); then
        log_info "System Node.js $(/usr/bin/node --version) found"
        return
    fi
    log_info "Installing system Node.js 22..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
}

install_camilladsp_binary() {
    if [[ -x /usr/local/bin/camilladsp ]]; then
        return
    fi
    log_info "Installing CamillaDSP $CAMILLA_VERSION..."
    wget -q -O /tmp/camilladsp.tar.gz \
        "https://github.com/HEnquist/camilladsp/releases/download/${CAMILLA_VERSION}/camilladsp-linux-aarch64.tar.gz"
    sudo tar -xzf /tmp/camilladsp.tar.gz -C /usr/local/bin/
    rm -f /tmp/camilladsp.tar.gz
}

# The package's postinst runs a blocking `systemctl restart camilladsp-preamp`,
# which waits forever when the Line-In pipe is missing (always on a client).
# A temporary runtime drop-in caps that start so the install can finish.
PREAMP_GUARD=/run/systemd/system/camilladsp-preamp.service.d

add_preamp_guard() {
    sudo mkdir -p "$PREAMP_GUARD"
    printf '[Service]\nTimeoutStartSec=5\n' | sudo tee "$PREAMP_GUARD/zz-update-guard.conf" > /dev/null
    sudo systemctl daemon-reload
}

remove_preamp_guard() {
    sudo rm -rf "$PREAMP_GUARD"
    sudo systemctl daemon-reload
}

# --reinstall restores package files that were deleted; --allow-downgrades lets
# a newer test build be replaced by the release version.
install_release_deb() {
    local repo="$1" suffix="$2" name tag
    name=${repo#*/}
    tag=$(latest_tag "$repo")
    if [[ -z "$tag" ]]; then
        log_error "Could not determine the latest $name release."
        exit 1
    fi
    log_info "Installing $name $tag..."
    wget -q -O "/tmp/$name.deb" \
        "https://github.com/${repo}/releases/download/${tag}/${name}_${tag#v}_${suffix}.deb"
    sudo apt-get install -y --reinstall --allow-downgrades "/tmp/$name.deb"
    rm -f "/tmp/$name.deb"
    log_success "$name $tag installed"
}

# ---------------------------------------------------------------------------
# Role and controller
# ---------------------------------------------------------------------------

apply_role() {
    if [[ "$ROLE" == "server" ]]; then
        sudo systemctl enable camilladsp-preamp.service
        log_success "Configured as server"
    else
        # Line-In is fed into Snapserver, so the preamp is only useful on a server.
        # Without Snapserver it would wait for the pipe forever.
        sudo systemctl disable --now camilladsp-preamp.service 2>/dev/null || true
        log_success "Configured as client (Snapserver left off)"
    fi
}

install_docker_if_missing() {
    if command -v docker >/dev/null 2>&1 && systemctl cat docker.service >/dev/null 2>&1; then
        return
    fi
    log_info "Installing Docker..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sudo sh /tmp/get-docker.sh
    rm -f /tmp/get-docker.sh
    sudo usermod -aG docker "$USER"
}

docker_compose() {
    # sudo, so this also works before a new docker group membership is active.
    (cd "$HOME/beatnik-controller" && sudo docker compose "$@")
}

setup_controller() {
    if [[ "$SELFHOST_CONTROLLER" == "y" ]]; then
        install_docker_if_missing
        sudo systemctl enable --now docker.service
        command -v git >/dev/null 2>&1 || sudo apt-get install -y git
        if [[ -d "$HOME/beatnik-controller/.git" ]]; then
            log_info "Updating Beatnik Controller..."
            git -C "$HOME/beatnik-controller" pull --ff-only
        else
            log_info "Installing Beatnik Controller..."
            rm -rf "$HOME/beatnik-controller"
            git clone https://github.com/byrdsandbytes/beatnik-controller.git "$HOME/beatnik-controller"
        fi
        docker_compose pull
        docker_compose up -d
        log_success "Beatnik Controller running at http://$(hostname).local:8181"
    elif [[ "$REMOVE_CONTROLLER" == "y" ]]; then
        log_info "Removing Beatnik Controller..."
        if command -v docker >/dev/null 2>&1 && [[ -f "$HOME/beatnik-controller/docker-compose.yml" ]]; then
            docker_compose down || true
        fi
        rm -rf "$HOME/beatnik-controller"
        log_success "Beatnik Controller removed"
    fi
}

# ---------------------------------------------------------------------------

finish() {
    echo
    log_success "Update to Beatnik 0.8 complete."
    echo "   Installed packages:"
    dpkg -l 'beatnik-*' | awk '/^ii/ {print "     - " $2 " " $3}'
    if [[ -f "$HOME/client_config.yml.0-6-backup" ]]; then
        echo "   Your old CamillaDSP config is in ~/client_config.yml.0-6-backup."
        echo "   Set up EQ again in the app, or see the docs for restoring it manually."
    fi
    echo "   After the reboot, check with:"
    echo "     systemctl status beatnik-hardware camilladsp beatnik-bleno snapclient --no-pager"
    echo
    if [[ "$(ask_yes_no "Reboot now? Needed for the Bleno LED settings. [Y/n]: " "y")" == "y" ]]; then
        sudo reboot
    else
        log_warning "Reboot later with: sudo reboot"
    fi
}

main() {
    echo "=========================================="
    echo "   Beatnik Pi: update from 0.6 to 0.8"
    echo "=========================================="
    preflight
    show_current_state
    ask_questions

    backup_camilla_config
    remove_old_install

    sudo apt-get update
    [[ "$ROLE" == "server" ]] && install_stream_sources_if_missing
    configure_snapserver

    install_nodejs22
    install_camilladsp_binary
    if [[ "$ROLE" == "client" ]]; then
        add_preamp_guard
        trap remove_preamp_guard EXIT
    fi
    install_release_deb byrdsandbytes/beatnik-hardware-api all
    if [[ "$ROLE" == "client" ]]; then
        trap - EXIT
        remove_preamp_guard
    fi
    install_release_deb byrdsandbytes/beatnik-bleno arm64

    apply_role
    setup_controller
    finish
}

main "$@"
