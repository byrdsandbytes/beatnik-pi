#!/bin/bash

# Beatnik Pi Uninstallation Script
# Automates the removal of Snapcast, related services, and configurations.

set -e # Exit on any error

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

# Stop and disable services
stop_services() {
    log_info "Stopping and disabling all related services..."
    
    # Stop Beatnik Controller if it exists
    if [ -d "$HOME/beatnik-controller" ] && [ -f "$HOME/beatnik-controller/docker-compose.yml" ]; then
        log_info "Stopping Beatnik Controller Docker container..."
        cd "$HOME/beatnik-controller"
        docker compose down
        cd - > /dev/null
    fi

    # Stop main services
    sudo systemctl stop snapserver snapclient shairport-sync raspotify 2>/dev/null || true
    sudo systemctl disable snapserver snapclient shairport-sync raspotify 2>/dev/null || true
    
    log_success "Services stopped and disabled."
}

# Uninstall audio packages
uninstall_packages() {
    log_info "Uninstalling packages (Snapcast, Shairport-Sync, Raspotify)..."
    
    # Purge packages to remove configs as well
    sudo apt-get purge --auto-remove -y snapserver snapclient shairport-sync raspotify 2>/dev/null || true
    
    # Clean up apt cache
    sudo apt-get autoremove -y
    sudo apt-get clean
    
    log_success "Snapcast, Shairport-Sync, and Raspotify have been uninstalled."
}

# Uninstall Docker (optional)
uninstall_docker() {
    log_warning "Docker is installed. It might be used by other applications."
    read -p "Do you want to uninstall Docker and Docker Compose? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Uninstalling Docker and Docker Compose..."
        sudo apt-get purge --auto-remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-compose 2>/dev/null || true
        log_success "Docker components uninstalled."
    else
        log_info "Skipping Docker uninstallation."
    fi
}

# Remove configuration files
remove_configs() {
    log_info "Removing configuration files..."
    
    sudo rm -f /etc/snapserver.conf /etc/snapclient.conf
    sudo rm -f /etc/snapserver.conf.backup* /etc/snapclient.conf.backup*
    
    # Remove Raspotify config directory
    sudo rm -rf /etc/raspotify
    
    log_success "Configuration files removed."
}

# Remove Beatnik Controller directory
remove_controller() {
    if [ -d "$HOME/beatnik-controller" ]; then
        log_info "The Beatnik Controller directory was found at ~/beatnik-controller."
        read -p "Do you want to permanently delete this directory? (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            rm -rf "$HOME/beatnik-controller"
            log_success "Beatnik Controller directory removed."
        else
            log_info "Skipping removal of Beatnik Controller directory."
        fi
    fi
}

# Advise on manual steps
show_manual_steps() {
    log_warning "The following steps must be performed manually:"
    echo "1. Edit the boot configuration file:"
    echo "   sudo nano /boot/firmware/config.txt"
    echo "2. Remove any lines related to your soundcard, for example:"
    echo "   - dtoverlay=hifiberry-..."
    echo "   - dtoverlay=iqaudio-..."
    echo "   - dtoverlay=vc4-kms-v3d,noaudio"
    echo "3. If you want to re-enable the built-in HDMI audio, make sure this line is present:"
    echo "   dtparam=audio=on"
    echo "4. After saving the file, reboot the system to apply the changes."
    echo
}

# Main uninstallation function
main() {
    echo "=================================================="
    echo "         Beatnik Pi Uninstallation Script"
    echo "=================================================="
    echo
    
    check_root
    
    log_warning "This script will permanently remove Beatnik Pi and all related components."
    echo "This includes Snapcast, Shairport-Sync, Raspotify, and their configurations."
    read -p "Are you sure you want to continue? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Uninstallation cancelled."
        exit 0
    fi
    
    stop_services
    uninstall_packages
    
    # Check if Docker is installed and ask to remove it
    if command -v docker &> /dev/null; then
        uninstall_docker
    fi
    
    remove_configs
    remove_controller
    
    echo
    log_success "Uninstallation completed."
    echo
    show_manual_steps
}

# Run