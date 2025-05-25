#!/bin/bash

# Tado Configuration Validation Script
# Checks if all necessary files and configurations are in place

echo "🔍 Tado Configuration Validation"
echo "================================"

CONFIG_DIR="/config"
ERRORS=0
WARNINGS=0

# Function to check file existence
check_file() {
    if [ -f "$1" ]; then
        echo "✅ $1 - Found"
    else
        echo "❌ $1 - Missing"
        ((ERRORS++))
    fi
}

# Function to check directory existence
check_dir() {
    if [ -d "$1" ]; then
        echo "✅ $1/ - Found"
    else
        echo "❌ $1/ - Missing"
        ((ERRORS++))
    fi
}

# Function to check for string in file
check_config() {
    if grep -q "$2" "$1" 2>/dev/null; then
        echo "✅ $1 contains '$2'"
    else
        echo "⚠️  $1 missing '$2'"
        ((WARNINGS++))
    fi
}

echo ""
echo "📁 Checking directory structure..."
check_dir "packages"
check_dir "dashboards" 
check_dir "themes"
check_dir "www"

echo ""
echo "📄 Checking required files..."
check_file "packages/tado_enhanced.yaml"
check_file "packages/room_configuration.yaml"
check_file "packages/tado_demo_data.yaml"
check_file "dashboards/tado-infographic-enhanced.yaml"
check_file "themes/tado_theme.yaml"
check_file "www/house-layout-infographic.svg"
check_file "www/tado-infographic.css"
check_file "www/tado-infographic.js"
check_file "automations.yaml"
check_file "scripts.yaml"

echo ""
echo "⚙️  Checking main configuration..."
check_file "configuration.yaml"
if [ -f "configuration.yaml" ]; then
    check_config "configuration.yaml" "packages: !include_dir_named packages"
    check_config "configuration.yaml" "frontend:"
    check_config "configuration.yaml" "matter:"
fi

echo ""
echo "🏠 Checking room configuration..."
if [ -f "packages/room_configuration.yaml" ]; then
    check_config "packages/room_configuration.yaml" "input_number:"
    check_config "packages/room_configuration.yaml" "tado_number_of_bedrooms:"
    check_config "packages/room_configuration.yaml" "input_boolean:"
    check_config "packages/room_configuration.yaml" "tado_has_garage:"
    check_config "packages/room_configuration.yaml" "tado_has_loft:"
    check_config "packages/room_configuration.yaml" "input_select:"
    check_config "packages/room_configuration.yaml" "tado_room_layout_preset:"
fi

echo ""
echo "🎨 Checking theme configuration..."
if [ -f "themes/tado_theme.yaml" ]; then
    check_config "themes/tado_theme.yaml" "tado_theme:"
    check_config "themes/tado_theme.yaml" "primary-color:"
fi

echo ""
echo "📊 Checking dashboard configuration..."
if [ -f "dashboards/tado-infographic-enhanced.yaml" ]; then
    check_config "dashboards/tado-infographic-enhanced.yaml" "custom:button-card"
    check_config "dashboards/tado-infographic-enhanced.yaml" "picture-elements"
    check_config "dashboards/tado-infographic-enhanced.yaml" "/local/house-layout-infographic.svg"
    check_config "dashboards/tado-infographic-enhanced.yaml" "/local/tado-infographic.css"
    check_config "dashboards/tado-infographic-enhanced.yaml" "/local/tado-infographic.js"
fi

echo ""
echo "🤖 Checking Matter integration..."
if [ -f "packages/tado_enhanced.yaml" ]; then
    check_config "packages/tado_enhanced.yaml" "climate."
    check_config "packages/tado_enhanced.yaml" "sensor."
    check_config "packages/tado_enhanced.yaml" "template:"
fi

echo ""
echo "📋 Validation Summary"
echo "===================="

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "🎉 Perfect! All files and configurations are in place."
    echo ""
    echo "✅ Next steps:"
    echo "   1. Restart Home Assistant"
    echo "   2. Add Tado devices via Matter integration"
    echo "   3. Update entity names to match your devices"
    echo "   4. Add the Tado dashboard to your UI"
elif [ $ERRORS -eq 0 ]; then
    echo "✅ Good! Core files are present but some configurations may need attention."
    echo "⚠️  $WARNINGS warning(s) found - check the items marked with ⚠️  above"
    echo ""
    echo "💡 These warnings might be OK if you've customized the configuration."
else
    echo "❌ Issues found! $ERRORS missing file(s) and $WARNINGS warning(s)"
    echo ""
    echo "🔧 To fix:"
    echo "   1. Copy missing files from the Tado setup directory"
    echo "   2. Check the INSTALLATION.md guide"
    echo "   3. Run this script again to verify"
fi

echo ""
echo "📖 For detailed setup instructions, see:"
echo "   - README.md - Overview and quick start"
echo "   - INSTALLATION.md - Step-by-step installation"

exit $ERRORS
