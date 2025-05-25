#!/bin/bash

# Tado Enhanced Update Script
# This script checks for and applies updates to the Tado Enhanced package

set -e

echo "🔄 Tado Enhanced Update Manager"
echo "==============================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️ $1${NC}"; }

# Check current version
if [ -f "version.yaml" ]; then
    CURRENT_VERSION=$(grep "version:" version.yaml | cut -d'"' -f2)
    print_info "Current version: $CURRENT_VERSION"
else
    CURRENT_VERSION="unknown"
    print_warning "No version file found. This might be an older installation."
fi

# Repository information
REPO_URL="https://raw.githubusercontent.com/your-username/tado-ha-enhanced/main"
LATEST_VERSION_URL="$REPO_URL/version.yaml"

print_info "Checking for updates..."

# Download latest version info
if command -v curl >/dev/null 2>&1; then
    LATEST_VERSION_INFO=$(curl -s "$LATEST_VERSION_URL" 2>/dev/null || echo "")
elif command -v wget >/dev/null 2>&1; then
    LATEST_VERSION_INFO=$(wget -qO- "$LATEST_VERSION_URL" 2>/dev/null || echo "")
else
    print_error "Neither curl nor wget is available. Cannot check for updates."
    exit 1
fi

if [ -z "$LATEST_VERSION_INFO" ]; then
    print_error "Unable to fetch latest version information. Check your internet connection."
    exit 1
fi

LATEST_VERSION=$(echo "$LATEST_VERSION_INFO" | grep "version:" | cut -d'"' -f2)

if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    print_status "You're already running the latest version ($CURRENT_VERSION)"
    exit 0
fi

print_info "Latest version available: $LATEST_VERSION"
echo ""

# Show changelog for the new version
echo "📋 What's new in $LATEST_VERSION:"
echo "$LATEST_VERSION_INFO" | grep -A 10 "changelog:" | grep -A 5 "\"$LATEST_VERSION\":" | tail -n +2

echo ""

# Ask user if they want to update
read -p "Do you want to update to version $LATEST_VERSION? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Update cancelled by user."
    exit 0
fi

# Create backup before update
BACKUP_DIR="tado_backup_update_$(date +%Y%m%d_%H%M%S)"
print_info "Creating backup in $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

# Backup current installation
cp -r packages/ "$BACKUP_DIR/" 2>/dev/null || true
cp -r dashboards/ "$BACKUP_DIR/" 2>/dev/null || true
cp *.yaml "$BACKUP_DIR/" 2>/dev/null || true
cp *.sh "$BACKUP_DIR/" 2>/dev/null || true

print_status "Backup created successfully"

# Download and run the latest installation script
print_info "Downloading latest installation script..."
if command -v curl >/dev/null 2>&1; then
    curl -sSL "$REPO_URL/install_tado_enhanced.sh" -o install_tado_enhanced_latest.sh
elif command -v wget >/dev/null 2>&1; then
    wget -qO install_tado_enhanced_latest.sh "$REPO_URL/install_tado_enhanced.sh"
fi

chmod +x install_tado_enhanced_latest.sh

print_info "Running update installation..."
./install_tado_enhanced_latest.sh --update

# Clean up
rm -f install_tado_enhanced_latest.sh

print_status "Update completed successfully!"
print_info "Backup of your previous installation is available in: $BACKUP_DIR"
print_warning "Please restart Home Assistant to apply all changes."

echo ""
echo "📋 What's new in $LATEST_VERSION:"
echo "$LATEST_VERSION_INFO" | grep -A 10 "\"$LATEST_VERSION\":" | tail -n +2 | head -n -1

echo ""
print_info "Update complete! 🎉"
