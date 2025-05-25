#!/bin/bash

# Test script to validate Tado Enhanced installation
echo "🧪 Testing Tado Enhanced Installation"
echo "====================================="

# Test 1: Check if all dashboard files exist
echo "✅ Testing dashboard files..."
for dashboard in "tado-dashboard-enhanced.yaml" "tado-infographic-enhanced.yaml" "tado-configuration.yaml"; do
    if [ -f "dashboards/$dashboard" ]; then
        echo "  ✓ $dashboard exists"
    else
        echo "  ✗ $dashboard missing"
        exit 1
    fi
done

# Test 2: Check if package file exists
echo "✅ Testing package file..."
if [ -f "packages/tado_enhanced.yaml" ]; then
    echo "  ✓ tado_enhanced.yaml exists"
else
    echo "  ✗ tado_enhanced.yaml missing"
    exit 1
fi

# Test 3: Validate YAML syntax (basic check)
echo "✅ Testing YAML syntax..."
for file in dashboards/*.yaml packages/*.yaml; do
    # Basic YAML validation using ruby if available, otherwise skip
    if command -v ruby >/dev/null 2>&1; then
        if ruby -e "require 'yaml'; YAML.load_file('$file')" 2>/dev/null; then
            echo "  ✓ $file has valid YAML syntax"
        else
            echo "  ✗ $file has invalid YAML syntax"
            exit 1
        fi
    else
        echo "  ⚠️  $file - YAML validation skipped (no ruby/python yaml available)"
    fi
done

# Test 4: Check for correct entity patterns
echo "✅ Testing entity patterns..."
pattern_count=$(grep -r "(sensor_\|radiator_)" dashboards/ packages/ | wc -l)
if [ "$pattern_count" -gt 0 ]; then
    echo "  ✓ Found $pattern_count instances of correct entity patterns"
else
    echo "  ✗ No correct entity patterns found"
    exit 1
fi

# Test 5: Check dashboard configuration in main config
echo "✅ Testing configuration.yaml..."
if [ -f "configuration.yaml" ]; then
    if grep -q "tado-enhanced" configuration.yaml && grep -q "tado-configuration" configuration.yaml; then
        echo "  ✓ All dashboards configured in configuration.yaml"
    else
        echo "  ✗ Missing dashboard configurations"
        exit 1
    fi
else
    echo "  ⚠️  configuration.yaml not found (will be created during installation)"
fi

echo ""
echo "🎉 All tests passed! Installation appears to be ready."
echo ""
echo "Next steps:"
echo "1. Run './install_tado_enhanced.sh' to install the configuration"
echo "2. Restart Home Assistant"
echo "3. Check that all three dashboards appear in the sidebar"
echo "4. Verify auto-discovery works with your Tado entities"
