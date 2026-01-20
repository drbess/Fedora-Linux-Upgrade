#!/bin/sh
#
# Fedora 41 to 43 Upgrade Script
# Compatible with sh, bash, dash, and other POSIX shells
# Created: January 2026
#
# Usage: sudo ./fedora-upgrade-41-to-43.sh
#####################
# Architect: drbess #
#####################

set -e  # Exit on error
set -u  # Exit on undefined variable

# Color codes for output (POSIX compatible)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log_message() {
    printf "%s[%s]%s %s\n" "$GREEN" "$(date '+%Y-%m-%d %H:%M:%S')" "$NC" "$1"
}

log_warning() {
    printf "%s[WARNING]%s %s\n" "$YELLOW" "$NC" "$1"
}

log_error() {
    printf "%s[ERROR]%s %s\n" "$RED" "$NC" "$1"
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    log_error "This script must be run as root. Use sudo."
    exit 1
fi

# Check current Fedora version
CURRENT_VERSION=$(grep "^VERSION_ID=" /etc/os-release | cut -d'=' -f2)
if [ "$CURRENT_VERSION" != "41" ]; then
    log_error "This script is designed for Fedora 41. Current version: $CURRENT_VERSION"
    exit 1
fi

log_message "Starting Fedora 41 to 43 upgrade process..."
log_message "Current Fedora version: $CURRENT_VERSION"

# Step 1: Update current system
log_message "Step 1/5: Updating current Fedora 41 system..."
if dnf upgrade --refresh -y; then
    log_message "System update completed successfully"
else
    log_error "System update failed. Please resolve issues before continuing."
    exit 1
fi

# Step 2: Check available disk space
log_message "Step 2/5: Checking available disk space..."
ROOT_AVAILABLE=$(df / --output=avail | tail -n 1)
ROOT_AVAILABLE_GB=$((ROOT_AVAILABLE / 1024 / 1024))

if [ "$ROOT_AVAILABLE_GB" -lt 5 ]; then
    log_warning "Low disk space detected: ${ROOT_AVAILABLE_GB}GB available"
    log_warning "Minimum 5GB recommended. Consider cleaning up space."
    printf "Continue anyway? (yes/no): "
    read -r CONTINUE
    if [ "$CONTINUE" != "yes" ]; then
        log_message "Upgrade cancelled by user."
        exit 0
    fi
else
    log_message "Disk space check passed: ${ROOT_AVAILABLE_GB}GB available"
fi

# Step 3: Download Fedora 43 packages
log_message "Step 3/5: Downloading Fedora 43 packages..."
log_message "This may take 15-30 minutes depending on your connection..."

# Try without --allowerasing first
if dnf system-upgrade download --releasever=43 -y; then
    log_message "Package download completed successfully"
else
    log_warning "Download failed. Retrying with --allowerasing flag..."
    if dnf system-upgrade download --releasever=43 --allowerasing -y; then
        log_message "Package download completed with --allowerasing"
    else
        log_error "Package download failed. Check dnf errors above."
        exit 1
    fi
fi

# Step 4: Verify download
log_message "Step 4/5: Verifying downloaded packages..."
if dnf system-upgrade log | tail -n 20 | grep -q "Download complete"; then
    log_message "Package verification successful"
else
    log_warning "Could not verify download status. Check manually with: dnf system-upgrade log"
fi

# Step 5: Prepare for reboot
log_message "Step 5/5: Preparation complete!"
log_message ""
log_message "=========================================="
log_message "IMPORTANT: Next Steps"
log_message "=========================================="
log_message "1. Close all applications and save your work"
log_message "2. The system will reboot into upgrade mode"
log_message "3. Upgrade process takes 20-45 minutes"
log_message "4. System will reboot again when complete"
log_message "5. DO NOT power off during the upgrade"
log_message ""
log_message "To start the upgrade, run:"
log_message "  sudo dnf system-upgrade reboot"
log_message ""
log_message "Or if you prefer DNF5 syntax:"
log_message "  sudo dnf5 offline reboot"
log_message ""
log_message "To cancel and delete downloaded packages:"
log_message "  sudo dnf system-upgrade clean"
log_message "=========================================="

exit 0
