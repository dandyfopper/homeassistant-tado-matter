#!/bin/bash
# Validation script for Tado Infographic Dashboard

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DASHBOARD_FILE="$SCRIPT_DIR/dashboards/tado-infographic-enhanced.yaml"
SVG_FILE="$SCRIPT_DIR/www/house-layout-infographic.svg"
CSS_FILE="$SCRIPT_DIR/www/tado-infographic.css"
JS_FILE="$SCRIPT_DIR/www/tado-infographic.js"
DEMO_DATA_FILE="$SCRIPT_DIR/packages/tado_demo_data.yaml"

echo -e "${BLUE}🏠 Tado Infographic Dashboard Validation${NC}"
echo "================================================"

# Function to check if file exists
check_file() {
    local file="$1"
    local description="$2"
    
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} $description exists"
        return 0
    else
        echo -e "${RED}✗${NC} $description missing: $file"
        return 1
    fi
}

# Function to validate YAML syntax
validate_yaml() {
    local file="$1"
    local description="$2"
    
    if command -v yq >/dev/null 2>&1; then
        if yq eval . "$file" >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} $description YAML syntax valid"
            return 0
        else
            echo -e "${RED}✗${NC} $description YAML syntax invalid"
            yq eval . "$file" 2>&1 | head -5
            return 1
        fi
    elif python3 -c "import yaml" 2>/dev/null; then
        if python3 -c "
import yaml
import sys
try:
    with open('$file', 'r') as f:
        yaml.safe_load(f)
    print('YAML syntax valid')
except yaml.YAMLError as e:
    print(f'YAML syntax error: {e}')
    sys.exit(1)
" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} $description YAML syntax valid"
            return 0
        else
            echo -e "${RED}✗${NC} $description YAML syntax invalid"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠${NC} Cannot validate $description YAML (no yq or PyYAML)"
        return 0
    fi
}

# Function to validate SVG structure
validate_svg() {
    local file="$1"
    
    if command -v xmllint >/dev/null 2>&1; then
        if xmllint --noout "$file" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} SVG structure valid"
            
            # Check for required elements
            local required_rooms=("Living Room" "Kitchen" "Bedroom" "Office")
            local missing_rooms=()
            
            for room in "${required_rooms[@]}"; do
                if ! grep -q "$room" "$file"; then
                    missing_rooms+=("$room")
                fi
            done
            
            if [[ ${#missing_rooms[@]} -eq 0 ]]; then
                echo -e "${GREEN}✓${NC} All required rooms found in SVG"
            else
                echo -e "${YELLOW}⚠${NC} Missing rooms in SVG: ${missing_rooms[*]}"
            fi
            
            return 0
        else
            echo -e "${RED}✗${NC} SVG structure invalid"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠${NC} Cannot validate SVG (xmllint not available)"
        return 0
    fi
}

# Function to validate CSS syntax
validate_css() {
    local file="$1"
    
    # Basic CSS syntax check
    if grep -E "^[^{]*\{[^}]*\}$|^/\*.*\*/$|^@" "$file" >/dev/null; then
        echo -e "${GREEN}✓${NC} CSS basic syntax appears valid"
    else
        echo -e "${YELLOW}⚠${NC} CSS syntax may have issues"
    fi
    
    # Check for required CSS classes
    local required_classes=("infographic-container" "glass-card" "temp-circle" "metric-card")
    local missing_classes=()
    
    for class in "${required_classes[@]}"; do
        if ! grep -q "\.$class" "$file"; then
            missing_classes+=("$class")
        fi
    done
    
    if [[ ${#missing_classes[@]} -eq 0 ]]; then
        echo -e "${GREEN}✓${NC} All required CSS classes found"
    else
        echo -e "${YELLOW}⚠${NC} Missing CSS classes: ${missing_classes[*]}"
    fi
}

# Function to validate JavaScript
validate_js() {
    local file="$1"
    
    if command -v node >/dev/null 2>&1; then
        if node -c "$file" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} JavaScript syntax valid"
        else
            echo -e "${RED}✗${NC} JavaScript syntax invalid"
            node -c "$file" 2>&1 | head -3
            return 1
        fi
    else
        echo -e "${YELLOW}⚠${NC} Cannot validate JavaScript (Node.js not available)"
    fi
    
    # Check for required functions
    local required_functions=("getTemperatureColor" "updateTemperatureDisplay" "initializeDashboard")
    local missing_functions=()
    
    for func in "${required_functions[@]}"; do
        if ! grep -q "function $func\|$func.*=" "$file"; then
            missing_functions+=("$func")
        fi
    done
    
    if [[ ${#missing_functions[@]} -eq 0 ]]; then
        echo -e "${GREEN}✓${NC} All required JavaScript functions found"
    else
        echo -e "${YELLOW}⚠${NC} Missing JavaScript functions: ${missing_functions[*]}"
    fi
}

# Function to check dashboard entities
check_dashboard_entities() {
    local file="$1"
    
    echo -e "\n${BLUE}🔍 Checking Dashboard Entities${NC}"
    
    # Extract entity IDs from dashboard
    local entities=($(grep -oE "climate\.[a-zA-Z0-9_]+" "$file" | sort -u))
    local sensors=($(grep -oE "sensor\.[a-zA-Z0-9_]+" "$file" | sort -u))
    local inputs=($(grep -oE "input_[a-zA-Z0-9_]+\.[a-zA-Z0-9_]+" "$file" | sort -u))
    
    echo "Found entities in dashboard:"
    echo "  Climate entities: ${#entities[@]}"
    echo "  Sensor entities: ${#sensors[@]}"
    echo "  Input helpers: ${#inputs[@]}"
    
    # Check for demo data entities
    local demo_entities=("sensor.tado_energy_savings_today" "sensor.tado_comfort_score" "sensor.tado_efficiency_score")
    local found_demo=0
    
    for entity in "${demo_entities[@]}"; do
        if grep -q "$entity" "$DEMO_DATA_FILE" 2>/dev/null; then
            ((found_demo++))
        fi
    done
    
    if [[ $found_demo -eq ${#demo_entities[@]} ]]; then
        echo -e "${GREEN}✓${NC} All demo data entities are configured"
    else
        echo -e "${YELLOW}⚠${NC} Some demo data entities may be missing"
    fi
}

# Function to run dashboard tests
run_dashboard_tests() {
    echo -e "\n${BLUE}🧪 Running Dashboard Tests${NC}"
    
    # Test 1: Check for button-card usage
    if grep -q "custom:button-card" "$DASHBOARD_FILE"; then
        echo -e "${GREEN}✓${NC} Uses button-card custom component"
    else
        echo -e "${YELLOW}⚠${NC} No button-card usage found"
    fi
    
    # Test 2: Check for picture-elements
    if grep -q "picture-elements" "$DASHBOARD_FILE"; then
        echo -e "${GREEN}✓${NC} Uses picture-elements for house layout"
    else
        echo -e "${RED}✗${NC} No picture-elements found"
    fi
    
    # Test 3: Check for conditional elements
    if grep -q "type: conditional" "$DASHBOARD_FILE"; then
        echo -e "${GREEN}✓${NC} Has conditional room visibility"
    else
        echo -e "${YELLOW}⚠${NC} No conditional elements found"
    fi
    
    # Test 4: Check for custom styling
    if grep -q "style:" "$DASHBOARD_FILE"; then
        echo -e "${GREEN}✓${NC} Includes custom styling"
    else
        echo -e "${YELLOW}⚠${NC} No custom styling found"
    fi
    
    # Test 5: Check for multiple views
    local view_count=$(grep -c "^  - title:" "$DASHBOARD_FILE" || echo "0")
    if [[ $view_count -ge 3 ]]; then
        echo -e "${GREEN}✓${NC} Has multiple views ($view_count found)"
    else
        echo -e "${YELLOW}⚠${NC} Limited views ($view_count found)"
    fi
}

# Function to generate validation report
generate_report() {
    local exit_code="$1"
    
    echo -e "\n${BLUE}📊 Validation Summary${NC}"
    echo "=========================="
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}✓ All validations passed!${NC}"
        echo ""
        echo "Your Tado Infographic Dashboard is ready to use."
        echo ""
        echo "Next steps:"
        echo "1. Install required HACS components (button-card, apexcharts-card)"
        echo "2. Add the dashboard to Home Assistant"
        echo "3. Configure your Tado device entity names"
        echo "4. Enable demo mode if needed: input_boolean.tado_demo_mode"
    else
        echo -e "${YELLOW}⚠ Some issues found${NC}"
        echo ""
        echo "Please review the warnings above and fix any errors."
        echo "The dashboard may still work with minor issues."
    fi
    
    echo ""
    echo "Files validated:"
    echo "  📱 Dashboard: $(basename "$DASHBOARD_FILE")"
    echo "  🏠 SVG Layout: $(basename "$SVG_FILE")"
    echo "  🎨 CSS Styles: $(basename "$CSS_FILE")"
    echo "  ⚡ JavaScript: $(basename "$JS_FILE")"
    echo "  📊 Demo Data: $(basename "$DEMO_DATA_FILE")"
}

# Main validation process
main() {
    local exit_code=0
    
    echo -e "\n${BLUE}📁 File Existence Check${NC}"
    check_file "$DASHBOARD_FILE" "Infographic Dashboard" || exit_code=1
    check_file "$SVG_FILE" "Enhanced SVG Layout" || exit_code=1
    check_file "$CSS_FILE" "Custom CSS Styles" || exit_code=1
    check_file "$JS_FILE" "JavaScript Enhancements" || exit_code=1
    check_file "$DEMO_DATA_FILE" "Demo Data Configuration" || exit_code=1
    
    echo -e "\n${BLUE}✅ YAML Validation${NC}"
    validate_yaml "$DASHBOARD_FILE" "Dashboard" || exit_code=1
    validate_yaml "$DEMO_DATA_FILE" "Demo Data" || exit_code=1
    
    echo -e "\n${BLUE}🖼️ SVG Validation${NC}"
    validate_svg "$SVG_FILE" || exit_code=1
    
    echo -e "\n${BLUE}🎨 CSS Validation${NC}"
    validate_css "$CSS_FILE" || exit_code=1
    
    echo -e "\n${BLUE}⚡ JavaScript Validation${NC}"
    validate_js "$JS_FILE" || exit_code=1
    
    check_dashboard_entities "$DASHBOARD_FILE"
    run_dashboard_tests
    generate_report $exit_code
    
    return $exit_code
}

# Run validation
main "$@"
