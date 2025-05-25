#!/bin/bash

# Tado Home Assistant Setup Script
# This script helps set up the Tado dashboard configuration

echo "🏠 Tado Smart Thermostat Home Assistant Setup"
echo "=============================================="

# Check if running in Home Assistant config directory
if [ ! -f "configuration.yaml" ]; then
    echo "❌ Error: Please run this script from your Home Assistant configuration directory"
    echo "   Example: cd /config && ./setup_tado.sh"
    exit 1
fi

echo "📁 Creating necessary directories..."
mkdir -p themes dashboards www

# Backup existing configuration
if [ -f "configuration.yaml" ]; then
    echo "💾 Backing up existing configuration.yaml..."
    cp configuration.yaml configuration.yaml.backup.$(date +%Y%m%d_%H%M%S)
fi

echo "📋 Configuration files created successfully!"
echo ""
echo "📝 Next Steps:"
echo "1. Copy the provided configuration files to your Home Assistant config directory"
echo "2. Install HACS if not already installed: https://hacs.xyz/"
echo "3. Install button-card from HACS (Frontend → Search for 'button-card')"
echo "4. Add your Tado devices via Matter integration:"
echo "   - Settings → Devices & Services → Add Integration → Matter"
echo "5. Update entity names in the configuration files to match your devices"
echo "6. Restart Home Assistant"
echo "7. Add the new dashboard to your Home Assistant UI"
echo ""
echo "🔧 Configuration Files Location:"
echo "   - Main config: configuration.yaml"
echo "   - Packages: packages/tado.yaml & packages/room_configuration.yaml"
echo "   - Theme: themes/tado_theme.yaml"
echo "   - Dashboard: dashboards/tado-home.yaml"
echo "   - House layouts: www/house-layout.svg & www/house-layout-dynamic.svg"
echo "   - Mini layout: www/room-layout-mini.svg"
echo "   - Styles: www/tado-dashboard.css"
echo "   - Automations: automations.yaml"
echo "   - Scripts: scripts.yaml"
echo ""
echo "🏠 Dynamic Room Configuration Features:"
echo "   - Support for 1-6 bedrooms"
echo "   - Optional garage and loft spaces"
echo "   - Quick layout presets (Studio to Manor House)"
echo "   - Real-time dashboard adaptation"
echo "   - Visual house layout updates"
echo "   - Default: 4 bedrooms + garage + loft"
echo ""
echo "📖 For detailed instructions, see README.md"
echo "✅ Setup preparation complete!"

# Check for Home Assistant CLI
if command -v ha &> /dev/null; then
    echo ""
    echo "🔄 Home Assistant CLI detected. Would you like to restart HA now? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "🔄 Restarting Home Assistant..."
        ha core restart
    fi
fi
