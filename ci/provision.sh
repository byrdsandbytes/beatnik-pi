#!/bin/bash

# Beatnik OS - CI image provisioning script
# Runs INSIDE a QEMU-emulated chroot (pguyot/arm-runner-action) against a
# pristine Raspberry Pi OS Lite (arm64) image, as root. There is no running
# systemd (PID 1) here, and no end-user account exists yet (Raspberry Pi
# Imager creates that on first real boot) - so this script only ever uses
# `systemctl enable` (offline/symlink-based) and never `start`/`stop`, and it
# runs CamillaDSP/hardware services as the fixed `snapclient` system account
# (created by the snapclient .deb) instead of a not-yet-existing login user.
#
# Default build target: Beatnik Pi Server + HiFiBerry Amp4 Pro.

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

INSTALL_TYPE="server"
SOUNDCARD="hifiberry-amp4pro"
OVERLAY="dtoverlay=hifiberry-amp4pro"

# Fresh raspios images mount the boot partition at /boot/firmware; fall back
# to /boot for older layouts so this script doesn't depend on action internals.
BOOT_CONFIG="/boot/firmware/config.txt"
[ -f "$BOOT_CONFIG" ] || BOOT_CONFIG="/boot/config.txt"

get_os_codename() {
    . /etc/os-release
    OS_CODENAME=$VERSION_CODENAME
    log_info "Detected OS Codename: $OS_CODENAME"
}

get_latest_snapcast_version() {
    log_info "Fetching latest Snapcast version..."
    SNAPCAST_VERSION_TAG=$(curl -sL https://api.github.com/repos/badaix/snapcast/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$SNAPCAST_VERSION_TAG" ]; then
        log_error "Failed to fetch latest Snapcast version."
        exit 1
    fi
    SNAPCAST_VERSION=${SNAPCAST_VERSION_TAG#v}
    log_info "Latest Snapcast version is $SNAPCAST_VERSION"
}

configure_soundcard() {
    log_info "Configuring soundcard drivers ($SOUNDCARD)..."
    cp "$BOOT_CONFIG" "${BOOT_CONFIG}.backup"
    sed -i '/^dtparam=audio=on/d' "$BOOT_CONFIG"
    if grep -q "^dtoverlay=vc4-kms-v3d" "$BOOT_CONFIG"; then
        sed -i 's/^dtoverlay=vc4-kms-v3d.*/dtoverlay=vc4-kms-v3d,noaudio/' "$BOOT_CONFIG"
    fi
    if ! grep -q "$OVERLAY" "$BOOT_CONFIG"; then
        echo "$OVERLAY" >> "$BOOT_CONFIG"
    fi
}

update_system() {
    log_info "Updating package lists..."
    apt-get update
}

install_snapcast() {
    log_info "Installing Snapcast $SNAPCAST_VERSION for $OS_CODENAME..."
    cd /tmp
    wget -q -O snapserver.deb "https://github.com/badaix/snapcast/releases/download/${SNAPCAST_VERSION_TAG}/snapserver_${SNAPCAST_VERSION}-1_arm64_${OS_CODENAME}.deb"
    wget -q -O snapclient.deb "https://github.com/badaix/snapcast/releases/download/${SNAPCAST_VERSION_TAG}/snapclient_${SNAPCAST_VERSION}-1_arm64_${OS_CODENAME}.deb"
    apt-get install -y ./snapserver.deb ./snapclient.deb
    systemctl enable snapserver.service snapclient.service
    log_success "Snapcast server and client installed"
}

install_shairport_sync() {
    log_info "Installing Shairport-Sync for AirPlay support..."
    apt-get install -y shairport-sync
    systemctl disable shairport-sync.service
    log_success "Shairport-Sync installed and disabled"
}

install_raspotify() {
    log_info "Installing Raspotify for Spotify Connect support..."
    apt-get install -y curl
    curl -sL https://dtcooper.github.io/raspotify/install.sh | sh \
        || log_warning "Raspotify installer reported an error, continuing"
    systemctl disable raspotify.service 2>/dev/null || true
    log_success "Raspotify installed and disabled"
}

configure_snapserver() {
    log_info "Configuring Snapserver..."
    tee /etc/snapserver.conf > /dev/null <<'EOF'
# Beatnik Pi Snapserver Configuration

[http]
enabled = true
bind_to_address = 0.0.0.0
port = 1780

[tcp]
enabled = true
bind_to_address = 0.0.0.0
port = 1705

[stream]
# AirPlay 1 (port 5000)
source = airplay:///usr/bin/shairport-sync?name=AirPlay&devicename=Beatnik-Airplay1&port=5000

[stream]
# AirPlay 2 (port 7000)
source = airplay:///shairport-sync?name=AirPlay2&devicename=Beatnik-Airplay2&port=7000

[stream]
# Spotify Connect
source = spotify:///librespot?name=Spotify&devicename=Beatnik-Spotify
EOF
    log_success "Snapserver configured"
}

configure_snapclient() {
    log_info "Configuring Snapclient..."
    usermod -aG audio snapclient
    tee /etc/snapclient.conf > /dev/null <<EOF
[snapclient]
host = localhost
sound_device = hw:0,0
EOF
    log_success "Snapclient configured"
}

install_camilladsp() {
    log_info "Installing CamillaDSP..."

    CAMILLADSP_DIR="/opt/beatnik/camilladsp"
    rm -rf "$CAMILLADSP_DIR"
    git clone https://github.com/byrdsandbytes/camilladsp.git "$CAMILLADSP_DIR"
    apt-get install -y alsa-utils unzip

    CAMILLA_VERSION="v2.0.3"
    wget -q "https://github.com/HEnquist/camilladsp/releases/download/${CAMILLA_VERSION}/camilladsp-linux-aarch64.tar.gz" -P /tmp
    tar -xvf /tmp/camilladsp-linux-aarch64.tar.gz -C /usr/local/bin/
    rm /tmp/camilladsp-linux-aarch64.tar.gz

    # Loopback module is loaded on real boot via this modules-load config
    # (modprobe here would touch the CI runner's own x86 kernel, not the image).
    echo "snd-aloop" | tee /etc/modules-load.d/snd-aloop.conf > /dev/null

    sed -i 's|^sound_device = .*|sound_device = hw:Loopback,0,0|' /etc/snapclient.conf

    PLAYBACK_DEVICE="plughw:CARD=sndrpihifiberry,DEV=0"

    cat > "$CAMILLADSP_DIR/configs/client_config.yml" <<EOF
devices:
  samplerate: 48000
  chunksize: 1024
  enable_rate_adjust: true
  target_level: 1024
  capture:
    type: Alsa
    channels: 2
    device: "hw:Loopback,1,0"
    format: S16LE
  playback:
    type: Alsa
    channels: 2
    device: "$PLAYBACK_DEVICE"
    format: S16LE

filters:
  bass:
    type: Biquad
    parameters:
      type: Lowshelf
      freq: 100
      slope: 6
      gain: 0.0
  mid:
    type: Biquad
    parameters:
      type: Peaking
      freq: 1000
      q: 0.7
      gain: 0.0
  high:
    type: Biquad
    parameters:
      type: Highshelf
      freq: 5000
      slope: 6
      gain: 0.0

mixers:
  stereo:
    channels:
      in: 2
      out: 2
    mapping:
      - dest: 0
        sources:
          - channel: 0
            gain: 0
            inverted: false
      - dest: 1
        sources:
          - channel: 1
            gain: 0
            inverted: false

pipeline:
  - type: Mixer
    name: stereo
  - type: Filter
    channel: 0
    names:
      - bass
      - mid
      - high
  - type: Filter
    channel: 1
    names:
      - bass
      - mid
      - high
EOF
    chown -R snapclient:snapclient "$CAMILLADSP_DIR"

    tee /etc/systemd/system/camilladsp.service > /dev/null <<EOF
[Unit]
Description=CamillaDSP
Wants=snapclient.service
After=snapclient.service

[Service]
Type=simple
User=snapclient
ExecStartPre=/bin/sleep 2
ExecStart=/usr/local/bin/camilladsp --address 0.0.0.0 --port 1234 $CAMILLADSP_DIR/configs/client_config.yml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    systemctl enable camilladsp.service
    log_success "CamillaDSP installed and configured"
}

install_beatnik_hardware_api() {
    log_info "Installing Beatnik Hardware API..."
    mkdir -p /opt/beatnik/hardware-api
    cd /opt/beatnik/hardware-api
    wget -q -O setup.sh https://raw.githubusercontent.com/byrdsandbytes/beatnik-hardware-api/master/setup.sh
    chmod +x setup.sh
    HOME=/root ./setup.sh || log_warning "Beatnik Hardware API setup reported an error, continuing"
    log_success "Beatnik Hardware API installed"
}

install_beatnik_bleno() {
    log_info "Installing Beatnik Bleno..."
    mkdir -p /opt/beatnik/bleno
    cd /opt/beatnik/bleno
    wget -q -O setup.sh https://raw.githubusercontent.com/byrdsandbytes/beatnik-bleno/master/setup.sh
    chmod +x setup.sh
    HOME=/root ./setup.sh || log_warning "Beatnik Bleno setup reported an error, continuing"
    systemctl enable beatnik-bleno.service 2>/dev/null || true
    log_success "Beatnik Bleno installed"
}

install_firstboot_hook() {
    log_info "Installing first-boot hook (Docker + Beatnik Controller)..."
    mkdir -p /opt/beatnik
    install -m 755 "$(dirname "$0")/firstboot.sh" /opt/beatnik/firstboot.sh
    install -m 644 "$(dirname "$0")/beatnik-firstboot.service" /etc/systemd/system/beatnik-firstboot.service
    systemctl enable beatnik-firstboot.service
    log_success "First-boot hook installed"
}

main() {
    get_os_codename
    get_latest_snapcast_version
    update_system
    configure_soundcard
    install_snapcast
    install_shairport_sync
    install_raspotify
    configure_snapserver
    configure_snapclient
    install_camilladsp
    install_beatnik_hardware_api
    install_beatnik_bleno
    install_firstboot_hook
    log_success "Provisioning complete"
}

main "$@"
