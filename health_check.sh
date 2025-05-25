#!/bin/bash

# Tado Enhanced Health Check Script
# This script validates the installation and configuration

set -e

echo "🏥 Tado Enhanced Health Check"
echo "============================="
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

ERRORS=0
WARNINGS=0

# Check if we're in the right directory
if [ ! -f "configuration.yaml" ]; then
    print_error "Not in Home Assistant config directory"
    exit 1
fi

print_info "Running health check from: $(pwd)"
echo ""

# Check required files
print_info "Checking required files..."

REQUIRED_FILES=(
    "packages/tado_enhanced.yaml"
    "dashboards/tado-dashboard-enhanced.yaml"
    "dashboards/tado-configuration.yaml"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_status "$file exists"
    else
        print_error "$file is missing"
        ((ERRORS++))
    fi
done

# Check if packages are included in configuration.yaml
print_info "Checking configuration.yaml setup..."
if grep -q "packages:" configuration.yaml; then
    if grep -q "packages: !include_dir_named packages" configuration.yaml; then
        print_status "Packages directory correctly configured"
    else
        print_warning "Packages configured but may not include packages directory"
        ((WARNINGS++))
    fi
else
    print_warning "Packages not configured in configuration.yaml"
    echo "  Add this to configuration.yaml:"
    echo "  homeassistant:"
    echo "    packages: !include_dir_named packages"
    ((WARNINGS++))
fi

# Check YAML syntax
print_info "Checking YAML syntax..."

for file in packages/*.yaml dashboards/*.yaml; do
    if [ -f "$file" ]; then
        if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
            print_status "$file has valid YAML syntax"
        else
            print_error "$file has YAML syntax errors"
            ((ERRORS++))
        fi
    fi
done

# Check for Home Assistant CLI and validate config
if command -v ha >/dev/null 2>&1; then
    print_info "Validating Home Assistant configuration..."
    if ha core check >/dev/null 2>&1; then
        print_status "Home Assistant configuration is valid"
    else
        print_warning "Home Assistant configuration validation failed"
        echo "  Run 'ha core check' for details"
        ((WARNINGS++))
    fi
    
    # Check if HA is running
    if ha core info >/dev/null 2>&1; then
        print_status "Home Assistant is running"
        
        # Try to check for Tado entities
        # Check if Home Assistant CLI is available (for basic operations only)
print_info "Checking Home Assistant CLI availability..."
if command -v ha &> /dev/null; then
    if ha core info >/dev/null 2>&1; then
        print_status "Home Assistant CLI is available and responsive"
        
        print_info "Note: Entity discovery is handled by Home Assistant template sensors"
        print_info "Check the 'Tado Configuration' dashboard for discovered entities"
    else
        print_warning "Home Assistant CLI found but not responsive"
        ((WARNINGS++))
    fi
else
    print_info "Home Assistant CLI not available (this is normal for some installations)"
    print_info "Entity discovery will work through Home Assistant's template sensors"
fi
        echo "  Make sure Home Assistant is running"
        ((WARNINGS++))
    fi
fi

# Check for Tado integration
print_info "Checking for Tado integration..."
if [ -f ".storage/core.config_entries" ]; then
    if grep -q "tado" ".storage/core.config_entries"; then
        print_status "Tado integration is configured"
    else
        print_warning "Tado integration not found in config entries"
        echo "  Make sure you have added the Tado integration in Settings > Integrations"
        ((WARNINGS++))
    fi
else
    print_info "Cannot check integration status (config entries file not found)"
fi

# Check input helpers configuration
print_info "Checking input helpers..."
if [ -f "packages/tado_enhanced.yaml" ]; then
    if grep -q "input_text:" packages/tado_enhanced.yaml; then
        print_status "Input helpers are configured"
    else
        print_warning "Input helpers may not be properly configured"
        ((WARNINGS++))
    fi
fi

# Check dashboard configuration
print_info "Checking dashboard configuration..."
if grep -q "mode: yaml" ui-lovelace.yaml 2>/dev/null || grep -q "mode: yaml" configuration.yaml; then
    print_status "Dashboard in YAML mode"
    
    if grep -q "dashboards:" configuration.yaml || [ -f "ui-lovelace.yaml" ]; then
        print_status "Dashboard configuration found"
    else
        print_warning "Dashboard configuration may not be complete"
        ((WARNINGS++))
    fi
else
    print_info "Dashboard in UI mode - manual dashboard import required"
fi

# Summary
echo ""
echo "==============================================="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    print_status "Health check passed! All systems are operational. 🎉"
elif [ $ERRORS -eq 0 ]; then
    print_warning "Health check completed with $WARNINGS warning(s). System should work but may need attention."
else
    print_error "Health check failed with $ERRORS error(s) and $WARNINGS warning(s)."
    echo ""
    print_info "To fix issues:"
    echo "  1. Run the installation script: ./install_tado_enhanced.sh"
    echo "  2. Check Home Assistant logs for detailed error messages"
    echo "  3. Restart Home Assistant after making changes"
fi

echo ""
print_info "For support, check README_ENHANCED.md or create an issue on GitHub"
