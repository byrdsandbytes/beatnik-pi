#!/bin/bash

# Beatnik Pi Installation Script
# Automates the installation of Snapcast with AirPlay and Spotify Connect support

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get latest Snapcast version
get_latest_snapcast_version() {
    log_info "Fetching latest Snapcast version..."
    SNAPCAST_VERSION_TAG=$(curl -sL https://api.github.com/repos/badaix/snapcast/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$SNAPCAST_VERSION_TAG" ]; then
        log_error "Failed to fetch latest Snapcast version. Please check your internet connection."
        exit 1
    fi
    SNAPCAST_VERSION=${SNAPCAST_VERSION_TAG#v} # Remove 'v' prefix
    log_info "Latest Snapcast version is $SNAPCAST_VERSION"
}

# Get OS codename (e.g., bookworm, trixie)
get_os_codename() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_CODENAME=$VERSION_CODENAME
        log_info "Detected OS Codename: $OS_CODENAME"
    else
        log_error "Cannot determine OS version. /etc/os-release not found."
        exit 1
    fi
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root. Please run as a regular user with sudo privileges."
        exit 1
    fi
}

# Check if running on Raspberry Pi
check_raspberry_pi() {
    if ! grep -q "Raspberry Pi" /proc/cpuinfo 2>/dev/null; then
        log_warning "This script is designed for Raspberry Pi. Continuing anyway..."
    fi
}

# Installation type selection
select_installation_type() {
    log_info "What would you like to install?"
    echo "1) Full Beatnik Pi Server (Snapserver + Snapclient + AirPlay + Spotify)"
    echo "2) Snapcast Client Only (connects to existing server)"
    
    while true; do
        read -p "Enter your choice (1-2): " choice
        case $choice in
            1)
                INSTALL_TYPE="server"
                break
                ;;
            2)
                INSTALL_TYPE="client"
                break
                ;;
            *)
                log_error "Invalid choice. Please enter 1 or 2."
                ;;
        esac
    done
}

# Soundcard selection menu
select_soundcard() {
    log_info "Please select your soundcard/HAT:"
    echo "1) HiFiBerry Amp4 Pro"
    echo "2) Raspberry Pi DAC+ (former IQAudio)"
    echo "3) Raspberry Pi DigiAmp+ (former IQAudio)"
    echo "4) HiFiBerry MiniAmp (for clients)"
    echo "5) Built-in 3.5mm jack"
    echo "6) USB Audio Device"
    echo "7) Other/Skip soundcard configuration"
    
    while true; do
        read -p "Enter your choice (1-7): " choice
        case $choice in
            1)
                SOUNDCARD="hifiberry-amp4pro"
                OVERLAY="dtoverlay=hifiberry-amp4pro"
                break
                ;;
            2)
                SOUNDCARD="raspberry-dacplus"
                # Will be configured after HAT detection
                break
                ;;
            3)
                SOUNDCARD="raspberry-digiampplus"
                # Will be configured after HAT detection
                break
                ;;
            4)
                SOUNDCARD="hifiberry-miniamp"
                OVERLAY="dtoverlay=hifiberry-dac"
                break
                ;;
            5)
                SOUNDCARD="builtin"
                OVERLAY="dtparam=audio=on"
                break
                ;;
            6)
                SOUNDCARD="usb"
                log_info "USB audio will be auto-detected. Make sure your USB audio device is connected."
                break
                ;;
            7)
                SOUNDCARD="skip"
                log_warning "Skipping soundcard configuration. You'll need to configure it manually."
                break
                ;;
            *)
                log_error "Invalid choice. Please enter 1-7."
                ;;
        esac
    done
}

# Configure soundcard drivers
configure_soundcard() {
    if [[ "$SOUNDCARD" == "skip" ]]; then
        return
    fi

    log_info "Configuring soundcard drivers..."
    
    # Backup config.txt
    sudo cp /boot/firmware/config.txt /boot/firmware/config.txt.backup.$(date +%Y%m%d_%H%M%S)
    
    # Handle built-in audio differently
    if [[ "$SOUNDCARD" == "builtin" ]]; then
        # Enable built-in audio
        if ! grep -q "^dtparam=audio=on" /boot/firmware/config.txt; then
            echo "dtparam=audio=on" | sudo tee -a /boot/firmware/config.txt > /dev/null
        fi
        return
    fi
    
    # Handle USB audio
    if [[ "$SOUNDCARD" == "usb" ]]; then
        log_info "USB audio configuration will be handled automatically."
        return
    fi
    
    # Remove dtparam=audio=on if it exists (for HAT configurations)
    sudo sed -i '/^dtparam=audio=on/d' /boot/firmware/config.txt
    
    # Add noaudio to vc4-kms-v3d if it exists
    if grep -q "^dtoverlay=vc4-kms-v3d" /boot/firmware/config.txt; then
        sudo sed -i 's/^dtoverlay=vc4-kms-v3d.*/dtoverlay=vc4-kms-v3d,noaudio/' /boot/firmware/config.txt
    fi
    
    # Handle Raspberry Pi HATs (DAC+ and DigiAmp+)
    if [[ "$SOUNDCARD" == "raspberry-dacplus" || "$SOUNDCARD" == "raspberry-digiampplus" ]]; then
        log_info "HAT configuration will be completed after reboot and HAT detection."
        NEEDS_HAT_DETECTION=true
    else
        # Add the overlay for HiFiBerry cards
        if ! grep -q "$OVERLAY" /boot/firmware/config.txt; then
            echo "$OVERLAY" | sudo tee -a /boot/firmware/config.txt > /dev/null
        fi
    fi
}

# Detect and configure Raspberry Pi HATs
configure_raspberry_hat() {
    if [[ "$NEEDS_HAT_DETECTION" != "true" ]]; then
        return
    fi

    log_info "Detecting HAT configuration..."
    
    if grep -q "Raspberry Pi DAC Plus" /proc/device-tree/hat/product 2>/dev/null; then
        log_info "Detected Raspberry Pi DAC+ HAT"
        OVERLAY="dtoverlay=iqaudio-dacplus"
    elif grep -q "Raspberry Pi DigiAMP+" /proc/device-tree/hat/product 2>/dev/null; then
        log_info "Detected Raspberry Pi DigiAmp+ HAT"
        OVERLAY="dtoverlay=iqaudio-digiamp"
    else
        log_warning "Could not detect HAT type. Please configure manually."
        return
    fi
    
    # Add the detected overlay
    if ! grep -q "$OVERLAY" /boot/firmware/config.txt; then
        echo "$OVERLAY" | sudo tee -a /boot/firmware/config.txt > /dev/null
        log_info "Added $OVERLAY to config.txt"
    fi
}

# Update system
update_system() {
    log_info "Updating system package lists..."
    sudo apt update
    
    if [[ "$INSTALL_TYPE" == "server" ]]; then
        log_info "Performing a full system upgrade (this may take a while)..."
        sudo apt full-upgrade -y
    else
        log_info "Skipping full system upgrade for faster client installation."
    fi
}

# Install Snapcast
install_snapcast() {
    log_info "Installing Snapcast $SNAPCAST_VERSION for $OS_CODENAME..."
    
    cd /tmp
    
    if [[ "$INSTALL_TYPE" == "server" ]]; then
        # Download both server and client packages
        wget -q -O snapserver.deb "https://github.com/badaix/snapcast/releases/download/${SNAPCAST_VERSION_TAG}/snapserver_${SNAPCAST_VERSION}-1_arm64_${OS_CODENAME}.deb"
        wget -q -O snapclient.deb "https://github.com/badaix/snapcast/releases/download/${SNAPCAST_VERSION_TAG}/snapclient_${SNAPCAST_VERSION}-1_arm64_${OS_CODENAME}.deb"
        
        # Install packages
        sudo apt install ./snapserver.deb ./snapclient.deb -y
        
        log_success "Snapcast server and client installed successfully"
    else
        # Download only client package
        wget -q -O snapclient.deb "https://github.com/badaix/snapcast/releases/download/${SNAPCAST_VERSION_TAG}/snapclient_${SNAPCAST_VERSION}-1_arm64_${OS_CODENAME}.deb"
        
        # Install package
        sudo apt install ./snapclient.deb -y
        
        log_success "Snapcast client installed successfully"
    fi
}

# Install Shairport-Sync (AirPlay)
install_shairport_sync() {
    log_info "Installing Shairport-Sync for AirPlay support..."
    
    sudo apt install shairport-sync -y
    
    # Disable the service (Snapserver will manage it)
    sudo systemctl disable shairport-sync.service
    
    log_success "Shairport-Sync installed and disabled"
}

# Install Raspotify (Spotify Connect)
install_raspotify() {
    log_info "Installing Raspotify for Spotify Connect support..."
    
    # Install curl if not present
    sudo apt-get install -y curl
    
    # Install raspotify
    curl -sL https://dtcooper.github.io/raspotify/install.sh | sh
    
    # Disable raspotify service (Snapserver will manage librespot)
    sudo systemctl disable raspotify
    sudo systemctl stop raspotify
    
    log_success "Raspotify installed and disabled"
}

# Configure Snapserver
configure_snapserver() {
    log_info "Configuring Snapserver..."
    
    # Backup existing config
    if [[ -f /etc/snapserver.conf ]]; then
        sudo cp /etc/snapserver.conf /etc/snapserver.conf.backup.$(date +%Y%m%d_%H%M%S)
    fi
    
    # Create snapserver configuration
    sudo tee /etc/snapserver.conf > /dev/null <<'EOF'
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

# Configure Snapclient
configure_snapclient() {
    log_info "Configuring Snapclient..."
    
    # Add snapclient user to audio group
    sudo usermod -aG audio snapclient
    
    # Get server hostname for client-only installations
    if [[ "$INSTALL_TYPE" == "client" ]]; then
        log_info "Enter the hostname or IP address of your Snapcast server:"
        read -p "Server address: " SERVER_HOST
        if [[ -z "$SERVER_HOST" ]]; then
            log_warning "No server address provided. Using localhost (you can change this later in /etc/snapclient.conf)"
            SERVER_HOST="localhost"
        fi
    else
        SERVER_HOST="localhost"
    fi
    
    # Detect the correct audio device
    AUDIO_DEVICE="hw:0,0"
    
    # For USB audio, try to find the correct device
    if [[ "$SOUNDCARD" == "usb" ]]; then
        USB_DEVICE=$(aplay -l 2>/dev/null | grep -E "USB|Audio" | head -1 | sed -n 's/card \([0-9]\):.*device \([0-9]\):.*/hw:\1,\2/p')
        if [[ -n "$USB_DEVICE" ]]; then
            AUDIO_DEVICE="$USB_DEVICE"
            log_info "Detected USB audio device: $AUDIO_DEVICE"
        else
            log_warning "USB audio device not found. Using default hw:0,0"
        fi
    fi
    
    # Create snapclient configuration
    sudo tee /etc/snapclient.conf > /dev/null <<EOF
[snapclient]
host = $SERVER_HOST
sound_device = $AUDIO_DEVICE
# buffer = 80
EOF
    
    log_success "Snapclient configured for server: $SERVER_HOST"
}

# Check soundcard after reboot
check_soundcard() {
    log_info "Checking soundcard configuration..."
    
    if aplay -l | grep -q "sndrpihifiberry\|card"; then
        log_success "Soundcard detected successfully"
        aplay -l
    else
        log_warning "Soundcard not detected. You may need to check your configuration."
    fi
}

# Start services
start_services() {
    log_info "Enabling and starting services..."
    
    if [[ "$INSTALL_TYPE" == "server" ]]; then
        sudo systemctl enable snapserver snapclient
        sudo systemctl start snapserver snapclient
        log_success "Snapserver and Snapclient services started"
    else
        sudo systemctl enable snapclient
        sudo systemctl start snapclient
        log_success "Snapclient service started"
    fi
}

# Install Docker and Beatnik Controller
install_beatnik_controller() {
    # Only offer controller installation for server installations
    if [[ "$INSTALL_TYPE" != "server" ]]; then
        return
    fi
    
    log_info "Would you like to install the Beatnik Controller web interface? (y/n)"
    read -p "Choice: " install_controller
    
    if [[ "$install_controller" =~ ^[Yy]$ ]]; then
        log_info "Installing Docker..."
        
        # Install Docker
        if ! command -v docker &> /dev/null; then
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh
            sudo usermod -aG docker $USER
        else
            log_info "Docker is already installed. Skipping installation."
        fi
        
        # Install Docker Compose Plugin (instead of standalone docker-compose)
        # The get-docker.sh script usually installs docker-compose-plugin, so we check first
        if ! docker compose version &> /dev/null; then
             sudo apt install docker-compose-plugin -y
        fi
        
        log_info "Installing Beatnik Controller..."
        
        # Clone and setup Beatnik Controller
        if [ -d "beatnik-controller" ]; then
            rm -rf beatnik-controller
        fi
        git clone https://github.com/byrdsandbytes/beatnik-controller.git
        cd beatnik-controller
        
        # Run docker compose using sg to pick up the new group membership
        if command -v sg &> /dev/null; then
            sg docker -c "docker compose up -d"
        else
            sudo docker compose up -d
        fi
        
        log_success "Beatnik Controller installed. Access it at http://$(hostname).local:8181"
        cd ..
    fi
}

# Display final information
show_completion_info() {
    log_success "Installation completed successfully!"
    echo
    
    if [[ "$INSTALL_TYPE" == "server" ]]; then
        log_info "Beatnik Pi Server is ready!"
        echo "Next steps:"
        echo "1. The system will reboot to apply soundcard configuration"
        echo "2. After reboot, test your setup:"
        echo "   - Classic Snapweb UI: http://$(hostname).local:1780"
        if [[ "$install_controller" =~ ^[Yy]$ ]]; then
            echo "   - Beatnik Controller: http://$(hostname).local:8181"
        fi
        echo "3. Test AirPlay from your phone/computer"
        echo "4. Test Spotify Connect from the Spotify app"
        echo "5. Install additional clients on other devices using this script"
    else
        log_info "Snapcast Client is ready!"
        echo "Next steps:"
        echo "1. The system will reboot to apply soundcard configuration"
        echo "2. After reboot, the client will automatically connect to: $SERVER_HOST"
        echo "3. Use the Snapcast server's web interface to control this client"
        echo "4. If the server address is wrong, edit /etc/snapclient.conf"
    fi
    
    echo
    log_info "Useful commands:"
    if [[ "$INSTALL_TYPE" == "server" ]]; then
        echo "   - Check services: sudo systemctl status snapserver snapclient"
        echo "   - View server logs: journalctl -u snapserver -f"
    fi
    echo "   - Check client: sudo systemctl status snapclient"
    echo "   - View client logs: journalctl -u snapclient -f"
    echo "   - Check soundcard: aplay -l"
    echo "   - Test audio: speaker-test -c2 -t wav"
    echo
    
    if [[ "$SOUNDCARD" != "skip" && "$SOUNDCARD" != "usb" ]]; then
        log_warning "System will reboot in 10 seconds to apply soundcard configuration..."
        echo "Press Ctrl+C to cancel the reboot."
        sleep 10
        sudo reboot
    fi
}

# Main installation function
main() {
    echo "================================================"
    echo "         Beatnik Pi Installation Script"
    echo "================================================"
    echo
    
    check_root
    check_raspberry_pi
    get_os_codename
    get_latest_snapcast_version
    
    # Select installation type first
    select_installation_type
    
    if [[ "$INSTALL_TYPE" == "server" ]]; then
        log_info "This script will install:"
        echo "- Snapcast server and client"
        echo "- Shairport-Sync (AirPlay support)"
        echo "- Raspotify (Spotify Connect support)"
        echo "- Configure your selected soundcard/HAT"
        echo "- Optional: Beatnik Controller web interface"
    else
        log_info "This script will install:"
        echo "- Snapcast client only"
        echo "- Configure your selected soundcard/HAT"
        echo "- Connect to an existing Snapcast server"
    fi
    echo
    
    read -p "Do you want to continue? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled."
        exit 0
    fi
    
    select_soundcard
    update_system
    configure_soundcard
    install_snapcast
    
    # Only install server components for server installation
    if [[ "$INSTALL_TYPE" == "server" ]]; then
        install_shairport_sync
        install_raspotify
        configure_snapserver
    fi
    
    configure_snapclient
    
    # If we needed HAT detection and haven't rebooted yet, do it now
    if [[ "$NEEDS_HAT_DETECTION" == "true" ]]; then
        log_warning "Rebooting to enable HAT detection..."
        sudo reboot
    fi
    
    check_soundcard
    start_services
    install_beatnik_controller
    show_completion_info
}

# Handle HAT configuration after reboot
if [[ "$1" == "--configure-hat" ]]; then
    configure_raspberry_hat
    check_soundcard
    start_services
    log_success "HAT configuration completed!"
    exit 0
fi

# Run main installation
main "$@"
