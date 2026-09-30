#!/bin/bash

# Beatnik OS - CI image provisioning script
# Runs INSIDE a QEMU-emulated chroot (pguyot/arm-runner-action) against a
# pristine Raspberry Pi OS Lite (arm64) image, as root. There is no running
# systemd (PID 1) here - so this script only ever uses `systemctl enable`
# (offline/symlink-based) and never `start`/`stop`.
#
# Mirrors the manual golden-master process: a fixed `beatnik` account is
# created and locked at build time (Raspberry Pi Imager's userconf-service
# resets its password on first boot if the end user picks that same
# username; otherwise it stays locked and unused). Everything Beatnik-specific
# lives under its home directory, same as when a person runs install.sh by hand.
#
# Default build target: Beatnik Pi Server + HiFiBerry Amp4 Pro.

set -euo pipefail

# Resolve before any function below does `cd` and invalidates a relative path.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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

BEATNIK_USER="beatnik"
BEATNIK_HOME="/home/$BEATNIK_USER"

# Fresh raspios images mount the boot partition at /boot/firmware; fall back
# to /boot for older layouts so this script doesn't depend on action internals.
BOOT_CONFIG="/boot/firmware/config.txt"
[ -f "$BOOT_CONFIG" ] || BOOT_CONFIG="/boot/config.txt"

get_os_codename() {
    . /etc/os-release
    OS_CODENAME=$VERSION_CODENAME
    log_info "Detected OS Codename: $OS_CODENAME"
}

# apt (and third-party installers calling it) occasionally hit transient
# "Cannot allocate memory" errors under QEMU emulation; retry before giving up.
retry() {
    local attempts=3 n=1
    until "$@"; do
        if (( n >= attempts )); then
            return 1
        fi
        log_warning "Command failed (attempt $n/$attempts), retrying in 5s: $*"
        n=$((n + 1))
        sleep 5
    done
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

create_beatnik_user() {
    log_info "Creating $BEATNIK_USER account..."
    if ! id "$BEATNIK_USER" &>/dev/null; then
        useradd -m -s /bin/bash "$BEATNIK_USER"
    fi
    for grp in sudo audio gpio i2c spi dialout plugdev netdev video render bluetooth adm systemd-journal; do
        getent group "$grp" >/dev/null 2>&1 && usermod -aG "$grp" "$BEATNIK_USER"
    done
    echo "$BEATNIK_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/010-beatnik-nopasswd
    chmod 440 /etc/sudoers.d/010-beatnik-nopasswd
    # Locked until Raspberry Pi Imager sets a real password on first boot; if the end
    # user picks a different username instead, this account just stays locked/unused.
    passwd -l "$BEATNIK_USER"
    log_success "$BEATNIK_USER account created and locked"
}

install_firstrun_tools() {
    log_info "Installing first-boot configuration tools..."
    retry apt-get install -y raspberrypi-sys-mods raspberrypi-net-mods
    for unit in regenerate_ssh_host_keys.service sshswitch.service userconf-service.service; do
        systemctl enable "$unit" 2>/dev/null || log_warning "Could not enable $unit (may not exist on this image)"
    done
    log_success "First-boot tools ready"
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
    local attempts=3 n=1
    until apt-get update; do
        if (( n >= attempts )); then
            log_error "apt-get update failed after $attempts attempts"
            return 1
        fi
        # A failed update can leave a truncated/corrupted list file that apt then
        # treats as "up to date" forever, so a plain retry alone never recovers.
        log_warning "apt-get update failed (attempt $n/$attempts); clearing apt cache and retrying in 5s..."
        rm -rf /var/lib/apt/lists/*
        n=$((n + 1))
        sleep 5
    done
}

install_snapcast() {
    log_info "Installing Snapcast $SNAPCAST_VERSION for $OS_CODENAME..."
    cd /tmp
    wget -q -O snapserver.deb "https://github.com/badaix/snapcast/releases/download/${SNAPCAST_VERSION_TAG}/snapserver_${SNAPCAST_VERSION}-1_arm64_${OS_CODENAME}.deb"
    wget -q -O snapclient.deb "https://github.com/badaix/snapcast/releases/download/${SNAPCAST_VERSION_TAG}/snapclient_${SNAPCAST_VERSION}-1_arm64_${OS_CODENAME}.deb"
    retry apt-get install -y ./snapserver.deb ./snapclient.deb
    systemctl enable snapserver.service snapclient.service
    log_success "Snapcast server and client installed"
}

install_shairport_sync() {
    log_info "Installing Shairport-Sync for AirPlay support..."
    retry apt-get install -y shairport-sync
    systemctl disable shairport-sync.service
    log_success "Shairport-Sync installed and disabled"
}

install_raspotify() {
    log_info "Installing Raspotify for Spotify Connect support..."
    retry apt-get install -y curl
    retry sh -c 'curl -sL https://dtcooper.github.io/raspotify/install.sh | sh' \
        || log_warning "Raspotify installer failed after retries, continuing"
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
source = airplay:///usr/bin/shairport-sync?name=AirPlay2&devicename=Beatnik-Airplay2&port=7000

[stream]
# Spotify Connect
source = spotify:///usr/bin/librespot?name=Spotify&devicename=Beatnik-Spotify
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

    retry apt-get install -y git alsa-utils unzip

    CAMILLADSP_DIR="$BEATNIK_HOME/camilladsp"
    rm -rf "$CAMILLADSP_DIR"
    git clone https://github.com/byrdsandbytes/camilladsp.git "$CAMILLADSP_DIR"

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
    chown -R "$BEATNIK_USER:$BEATNIK_USER" "$CAMILLADSP_DIR"

    tee /etc/systemd/system/camilladsp.service > /dev/null <<EOF
[Unit]
Description=CamillaDSP
Wants=snapclient.service
After=snapclient.service

[Service]
Type=simple
User=$BEATNIK_USER
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
    local cmd='set -e
mkdir -p ~/beatnik-hardware-api
cd ~/beatnik-hardware-api
wget -q -O setup.sh https://raw.githubusercontent.com/byrdsandbytes/beatnik-hardware-api/master/setup.sh
chmod +x setup.sh
./setup.sh'
    # su - gives a real login environment (correct $HOME/$USER), same as running it by hand.
    retry su - "$BEATNIK_USER" -c "$cmd" \
        || log_warning "Beatnik Hardware API setup failed after retries, continuing"
    log_success "Beatnik Hardware API installed"
}

install_beatnik_bleno() {
    log_info "Installing Beatnik Bleno..."
    local cmd='set -e
mkdir -p ~/beatnik-bleno
cd ~/beatnik-bleno
wget -q -O setup.sh https://raw.githubusercontent.com/byrdsandbytes/beatnik-bleno/master/setup.sh
chmod +x setup.sh
./setup.sh'
    retry su - "$BEATNIK_USER" -c "$cmd" \
        || log_warning "Beatnik Bleno setup failed after retries, continuing"
    systemctl enable beatnik-bleno.service 2>/dev/null || true
    log_success "Beatnik Bleno installed"
}

install_beatnik_controller() {
    log_info "Installing Docker + Beatnik Controller..."
    if ! command -v docker &>/dev/null; then
        retry sh -c 'curl -fsSL https://get.docker.com -o /tmp/get-docker.sh && sh /tmp/get-docker.sh' \
            || log_warning "Docker install failed after retries, continuing"
    fi
    getent group docker >/dev/null 2>&1 && usermod -aG docker "$BEATNIK_USER"
    # Enabled only - actually starting Docker and running `docker compose up -d`
    # needs a live daemon, so that happens once on the Pi's real first boot.
    systemctl enable docker.service 2>/dev/null || true

    local cmd="set -e
rm -rf ~/beatnik-controller
git clone https://github.com/byrdsandbytes/beatnik-controller.git ~/beatnik-controller"
    su - "$BEATNIK_USER" -c "$cmd" \
        || log_warning "Beatnik Controller clone failed, continuing"
    log_success "Docker installed and Beatnik Controller cloned"
}

install_firstboot_hook() {
    log_info "Installing first-boot hook (starts Beatnik Controller via Docker Compose)..."
    mkdir -p /opt/beatnik
    install -m 755 "$SCRIPT_DIR/firstboot.sh" /opt/beatnik/firstboot.sh
    install -m 644 "$SCRIPT_DIR/beatnik-firstboot.service" /etc/systemd/system/beatnik-firstboot.service
    systemctl enable beatnik-firstboot.service
    log_success "First-boot hook installed"
}

main() {
    get_os_codename
    get_latest_snapcast_version
    update_system
    create_beatnik_user
    install_firstrun_tools
    configure_soundcard
    install_snapcast
    install_shairport_sync
    install_raspotify
    configure_snapserver
    configure_snapclient
    install_camilladsp
    install_beatnik_hardware_api
    install_beatnik_bleno
    install_beatnik_controller
    install_firstboot_hook
    log_success "Provisioning complete"
}

main "$@"
