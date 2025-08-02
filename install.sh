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

# Soundcard selection menu
select_soundcard() {
    log_info "Please select your soundcard/HAT:"
    echo "1) HiFiBerry Amp4 Pro"
    echo "2) Raspberry Pi DAC+ (former IQAudio)"
    echo "3) Raspberry Pi DigiAmp+ (former IQAudio)"
    echo "4) HiFiBerry MiniAmp (for clients)"
    echo "5) Other/Skip soundcard configuration"
    
    while true; do
        read -p "Enter your choice (1-5): " choice
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
                SOUNDCARD="skip"
                log_warning "Skipping soundcard configuration. You'll need to configure it manually."
                break
                ;;
            *)
                log_error "Invalid choice. Please enter 1-5."
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
    
    # Remove dtparam=audio=on if it exists
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
    log_info "Updating system packages..."
    sudo apt update
    sudo apt full-upgrade -y
}

# Install Snapcast
install_snapcast() {
    log_info "Installing Snapcast 0.31.0..."
    
    cd /tmp
    
    # Download Snapcast packages
    wget -q https://github.com/badaix/snapcast/releases/download/v0.31.0/snapserver_0.31.0-1_arm64_bookworm.deb
    wget -q https://github.com/badaix/snapcast/releases/download/v0.31.0/snapclient_0.31.0-1_arm64_bookworm.deb
    
    # Install packages
    sudo apt install ./snapserver_* ./snapclient_* -y
    
    log_success "Snapcast installed successfully"
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
    
    # Create snapclient configuration
    sudo tee /etc/snapclient.conf > /dev/null <<'EOF'
[snapclient]
host = localhost
sound_device = hw:0,0
# buffer = 80
EOF
    
    log_success "Snapclient configured"
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
    
    sudo systemctl enable snapserver snapclient
    sudo systemctl start snapserver snapclient
    
    log_success "Services started"
}

# Install Docker and Beatnik Controller
install_beatnik_controller() {
    log_info "Would you like to install the Beatnik Controller web interface? (y/n)"
    read -p "Choice: " install_controller
    
    if [[ "$install_controller" =~ ^[Yy]$ ]]; then
        log_info "Installing Docker..."
        
        # Install Docker
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        sudo usermod -aG docker $USER
        
        # Install Docker Compose
        sudo apt install docker-compose -y
        
        log_info "Installing Beatnik Controller..."
        
        # Clone and setup Beatnik Controller
        git clone https://github.com/byrdsandbytes/beatnik-controller.git
        cd beatnik-controller
        docker compose up -d
        
        log_success "Beatnik Controller installed. Access it at http://$(hostname).local:8181"
        cd ..
    fi
}

# Display final information
show_completion_info() {
    log_success "Installation completed successfully!"
    echo
    log_info "Next steps:"
    echo "1. The system will reboot to apply soundcard configuration"
    echo "2. After reboot, test your setup:"
    echo "   - Classic Snapweb UI: http://$(hostname).local:1780"
    if [[ "$install_controller" =~ ^[Yy]$ ]]; then
        echo "   - Beatnik Controller: http://$(hostname).local:8181"
    fi
    echo "3. Test AirPlay from your phone/computer"
    echo "4. Test Spotify Connect from the Spotify app"
    echo
    log_info "Useful commands:"
    echo "   - Check services: sudo systemctl status snapserver snapclient"
    echo "   - View logs: journalctl -u snapserver -f"
    echo "   - Check soundcard: aplay -l"
    echo
    
    if [[ "$SOUNDCARD" != "skip" ]]; then
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
    
    log_info "This script will install:"
    echo "- Snapcast server and client"
    echo "- Shairport-Sync (AirPlay support)"
    echo "- Raspotify (Spotify Connect support)"
    echo "- Configure your selected soundcard/HAT"
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
    install_shairport_sync
    install_raspotify
    configure_snapserver
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
