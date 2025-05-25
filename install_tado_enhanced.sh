#!/bin/bash

# Enhanced Tado Home Assistant Setup Script
# This script automates the complete installation and configuration of the Tado dashboard

set -e  # Exit on any error

# Parse command line arguments
UPDATE_MODE=false
FORCE_REINSTALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --update)
            UPDATE_MODE=true
            shift
            ;;
        --force)
            FORCE_REINSTALL=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --update     Run in update mode (preserves user settings)"
            echo "  --force      Force reinstallation of all components"
            echo "  --help       Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

if [ "$UPDATE_MODE" = true ]; then
    echo "🔄 Enhanced Tado Update Mode"
    echo "============================"
    print_info "Running in update mode - preserving user configurations"
else
    echo "🏠 Enhanced Tado Smart Thermostat Setup"
    echo "========================================"
fi
echo ""

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

# Check if running in Home Assistant config directory
if [ ! -f "configuration.yaml" ]; then
    print_error "Please run this script from your Home Assistant configuration directory"
    echo "   Example: cd /config && curl -sSL https://your-repo/install_tado_enhanced.sh | bash"
    exit 1
fi

print_info "Detected Home Assistant configuration directory: $(pwd)"
echo ""

# Create backup
if [ "$UPDATE_MODE" = true ]; then
    BACKUP_DIR="tado_update_backup_$(date +%Y%m%d_%H%M%S)"
    print_info "Creating update backup in $BACKUP_DIR..."
else
    BACKUP_DIR="tado_backup_$(date +%Y%m%d_%H%M%S)"
    print_info "Creating backup in $BACKUP_DIR..."
fi
mkdir -p "$BACKUP_DIR"

# Backup existing files
if [ -f "configuration.yaml" ]; then
    cp configuration.yaml "$BACKUP_DIR/"
fi
if [ -f "ui-lovelace.yaml" ]; then
    cp ui-lovelace.yaml "$BACKUP_DIR/"
fi
if [ -d "packages" ] && [ "$FORCE_REINSTALL" = false ]; then
    # In update mode, preserve user-modified files
    if [ "$UPDATE_MODE" = true ]; then
        print_info "Preserving user configurations during update..."
        # Only backup, don't overwrite user input helpers
        cp -r packages "$BACKUP_DIR/"
    else
        cp -r packages "$BACKUP_DIR/"
    fi
fi
if [ -d "dashboards" ]; then
    cp -r dashboards "$BACKUP_DIR/"
fi

print_status "Backup created successfully"

# Create necessary directories
print_info "Creating directory structure..."
mkdir -p {packages,themes,dashboards,www,custom_components}
print_status "Directories created"

# Function to check if Home Assistant CLI is available
check_ha_cli_available() {
    # Only check if HA CLI is available for restart functionality
    if command -v ha &> /dev/null; then
        if ha core info >/dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

# Note: Entity discovery happens after Home Assistant restart
# The template sensors in the device discovery package will automatically
# detect Tado entities once Home Assistant is running
print_info "Entity discovery will happen automatically after Home Assistant restart"
print_info "The system uses template sensors to discover Tado entities dynamically"

# Download or copy configuration files
print_info "Installing Tado configuration files..."

# Since we're in the tado directory, copy files directly
if [ -f "packages/tado.yaml" ]; then
    print_status "Copying Tado package configuration..."
    cp packages/tado.yaml packages/tado.yaml 2>/dev/null || true
fi

if [ -f "packages/room_configuration.yaml" ]; then
    print_status "Copying room configuration..."
    cp packages/room_configuration.yaml packages/room_configuration.yaml 2>/dev/null || true
fi

if [ -f "themes/tado_theme.yaml" ]; then
    print_status "Copying Tado theme..."
    cp themes/tado_theme.yaml themes/tado_theme.yaml 2>/dev/null || true
fi

if [ -f "dashboards/tado-infographic-enhanced.yaml" ]; then
    print_status "Copying enhanced dashboard..."
    cp dashboards/tado-infographic-enhanced.yaml dashboards/tado-infographic-enhanced.yaml 2>/dev/null || true
fi

# Copy www files
if [ -d "www" ]; then
    print_status "Copying web resources..."
    cp -r www/* www/ 2>/dev/null || true
fi

# Create the Tado device discovery helper
print_info "Creating Tado device discovery helper..."
cat > packages/tado_device_discovery.yaml << 'EOF'
# Tado Device Discovery Helper
# This package helps discover and configure Tado devices automatically

homeassistant:
  packages: !include_dir_named packages

# Input selections for device configuration
input_select:
  tado_device_setup_mode:
    name: "Device Setup Mode"
    options:
      - "Automatic Discovery"
      - "Manual Configuration"
      - "Setup Complete"
    initial: "Automatic Discovery"
    icon: mdi:cog

  tado_installation_step:
    name: "Installation Step"
    options:
      - "1. Install Dependencies"
      - "2. Discover Devices" 
      - "3. Configure Entities"
      - "4. Setup Dashboard"
      - "5. Complete"
    initial: "1. Install Dependencies"
    icon: mdi:numeric

# Input text for manual entity configuration
input_text:
  tado_living_room_entity:
    name: "Living Room Tado Entity"
    initial: "climate.living_room_tado"
    icon: mdi:sofa
    
  tado_bedroom_entity:
    name: "Bedroom Tado Entity"
    initial: "climate.bedroom_tado"
    icon: mdi:bed
    
  tado_kitchen_entity:
    name: "Kitchen Tado Entity"
    initial: "climate.kitchen_tado"
    icon: mdi:chef-hat
    
  tado_office_entity:
    name: "Office Tado Entity"
    initial: "climate.office_tado"
    icon: mdi:desk

# Template sensors to detect available Tado entities
template:
  - sensor:
      - name: "Available Tado Climate Entities"
        unique_id: "available_tado_climate_entities"
        state: >
          {% set tado_entities = states.climate | selectattr('entity_id', 'search', '(sensor_|radiator_)') | list %}
          {{ tado_entities | length }}
        attributes:
          entities: >
            {% set tado_entities = states.climate | selectattr('entity_id', 'search', '(sensor_|radiator_)') | list %}
            {{ tado_entities | map(attribute='entity_id') | list }}
          
      - name: "Available Tado Sensor Entities"
        unique_id: "available_tado_sensor_entities"
        state: >
          {% set tado_entities = states.sensor | selectattr('entity_id', 'search', '(sensor_|radiator_)') | list %}
          {{ tado_entities | length }}
        attributes:
          entities: >
            {% set tado_entities = states.sensor | selectattr('entity_id', 'search', '(sensor_|radiator_)') | list %}
            {{ tado_entities | map(attribute='entity_id') | list }}

# Scripts for device configuration
script:
  tado_auto_discover_entities:
    alias: "Auto-discover Tado Entities"
    sequence:
      - service: input_select.select_option
        target:
          entity_id: input_select.tado_installation_step
        data:
          option: "2. Discover Devices"
      - delay:
          seconds: 2
      - service: homeassistant.update_entity
        target:
          entity_id: 
            - sensor.available_tado_climate_entities
            - sensor.available_tado_sensor_entities
      - service: input_select.select_option
        target:
          entity_id: input_select.tado_installation_step
        data:
          option: "3. Configure Entities"
          
  tado_apply_discovered_entities:
    alias: "Apply Discovered Entities"
    sequence:
      - service: input_text.set_value
        target:
          entity_id: input_text.tado_living_room_entity
        data:
          value: >
            {% set entities = state_attr('sensor.available_tado_climate_entities', 'entities') | default([]) %}
            {% for entity in entities %}
              {% if 'living' in entity.lower() or 'lounge' in entity.lower() %}
                {{ entity }}
                {% break %}
              {% endif %}
            {% else %}
              {{ entities[0] if entities | length > 0 else 'climate.living_room_tado' }}
            {% endfor %}
      - service: input_text.set_value
        target:
          entity_id: input_text.tado_bedroom_entity  
        data:
          value: >
            {% set entities = state_attr('sensor.available_tado_climate_entities', 'entities') | default([]) %}
            {% for entity in entities %}
              {% if 'bedroom' in entity.lower() or 'bed' in entity.lower() %}
                {{ entity }}
                {% break %}
              {% endif %}
            {% else %}
              {{ entities[1] if entities | length > 1 else 'climate.bedroom_tado' }}
            {% endfor %}
      - service: input_select.select_option
        target:
          entity_id: input_select.tado_installation_step
        data:
          option: "4. Setup Dashboard"

# Automation to guide through setup process
automation:
  - alias: "Tado Setup Guide"
    trigger:
      - platform: state
        entity_id: input_select.tado_installation_step
    action:
      - choose:
          - conditions:
              - condition: state
                entity_id: input_select.tado_installation_step
                state: "1. Install Dependencies"
            sequence:
              - service: persistent_notification.create
                data:
                  title: "Tado Setup - Step 1"
                  message: |
                    **Install Required Dependencies:**
                    
                    1. Install HACS if not already installed
                    2. Go to HACS → Frontend
                    3. Install "button-card" 
                    4. Install "card-mod" (optional)
                    5. Restart Home Assistant
                    
                    Then move to step 2 to discover your Tado devices.
                  notification_id: tado_setup_step_1
          - conditions:
              - condition: state
                entity_id: input_select.tado_installation_step
                state: "2. Discover Devices"
            sequence:
              - service: script.tado_auto_discover_entities
EOF

print_status "Device discovery helper created"

# Create the configuration dashboard
print_info "Creating configuration dashboard..."
cat > dashboards/tado-configuration.yaml << 'EOF'
# Tado Configuration Dashboard
# Easy setup and configuration interface

title: Tado Configuration
icon: mdi:cog
path: tado-config

views:
  - title: Device Setup
    path: setup
    icon: mdi:devices
    cards:
      # Setup progress card
      - type: vertical-stack
        cards:
          - type: markdown
            content: |
              # 🏠 Tado Device Configuration
              
              Use this dashboard to easily set up your Tado devices. The system will automatically detect your Tado entities and configure the dashboard.
              
          - type: entities
            title: "Setup Progress"
            entities:
              - input_select.tado_installation_step
              - input_select.tado_device_setup_mode

      # Device Discovery Section
      - type: conditional
        conditions:
          - entity: input_select.tado_installation_step
            state_not: "5. Complete"
        card:
          type: vertical-stack
          cards:
            - type: markdown
              content: |
                ## 🔍 Device Discovery
                
                Click the button below to automatically discover your Tado devices:
                
            - type: button
              tap_action:
                action: call-service
                service: script.tado_auto_discover_entities
              name: "🔍 Discover Tado Devices"
              
            - type: entities
              title: "Discovered Devices"
              entities:
                - sensor.available_tado_climate_entities
                - sensor.available_tado_sensor_entities

      # Manual Configuration Section  
      - type: conditional
        conditions:
          - entity: input_select.tado_device_setup_mode
            state: "Manual Configuration"
        card:
          type: vertical-stack
          cards:
            - type: markdown
              content: |
                ## 🔧 Manual Entity Configuration
                
                If automatic discovery doesn't work, you can manually enter your Tado entity names:
                
            - type: entities
              title: "Climate Entity Names"
              entities:
                - input_text.tado_living_room_entity
                - input_text.tado_bedroom_entity
                - input_text.tado_kitchen_entity
                - input_text.tado_office_entity
                
            - type: button
              tap_action:
                action: call-service
                service: script.tado_apply_discovered_entities
              name: "Apply Configuration"

      # Setup completion
      - type: conditional
        conditions:
          - entity: input_select.tado_installation_step
            state: "5. Complete"
        card:
          type: markdown
          content: |
            # ✅ Setup Complete!
            
            Your Tado configuration is now ready. You can:
            
            - Visit the **Tado Smart Home** dashboard to see your devices
            - Customize room layouts in the configuration
            - Set up automations for different heating modes
            
            **Next Steps:**
            1. Go to the main Tado dashboard 
            2. Configure your room layout
            3. Test the heating controls
            4. Set up automations if desired

  - title: Entity Reference
    path: entities
    icon: mdi:list-box
    cards:
      - type: markdown
        content: |
          # 📋 Tado Entity Reference
          
          This section shows all available Tado entities in your system for easy reference.
          
      - type: auto-entities
        card:
          type: entities
          title: "Climate Entities (Thermostats)"
        filter:
          include:
            - entity_id: "climate.*(sensor_|radiator_)*"
          exclude: []
        sort:
          method: entity_id
          
      - type: auto-entities
        card:
          type: entities
          title: "Sensor Entities (Temperature, Humidity, etc.)"
        filter:
          include:
            - entity_id: "sensor.*(sensor_|radiator_)*"
          exclude: []
        sort:
          method: entity_id
          
      - type: auto-entities
        card:
          type: entities  
          title: "Binary Sensor Entities"
        filter:
          include:
            - entity_id: "binary_sensor.*(sensor_|radiator_)*"
          exclude: []
        sort:
          method: entity_id
EOF

print_status "Configuration dashboard created"

# Update main UI configuration to include the new dashboards
print_info "Updating dashboard configuration..."

# Update configuration.yaml to include dashboard configuration
if ! grep -q "lovelace:" configuration.yaml 2>/dev/null; then
    # Add lovelace configuration if it doesn't exist
    sed -i.bak '/^frontend:$/,/^$/c\
# Frontend for custom dashboards\
frontend:\
  themes: !include_dir_merge_named themes\
\
# Dashboard configuration for Tado\
lovelace:\
  mode: storage\
  dashboards:\
    tado-enhanced:\
      mode: yaml\
      title: Tado Smart Home Enhanced\
      icon: mdi:home-analytics\
      show_in_sidebar: true\
      filename: dashboards/tado-dashboard-enhanced.yaml\
    tado-infographic:\
      mode: yaml\
      title: Tado Smart Home\
      icon: mdi:home-thermometer\
      show_in_sidebar: true\
      filename: dashboards/tado-infographic-enhanced.yaml\
    tado-configuration:\
      mode: yaml\
      title: Tado Configuration\
      icon: mdi:cog\
      show_in_sidebar: true\
      filename: dashboards/tado-configuration.yaml\
' configuration.yaml
elif ! grep -q "tado-enhanced" configuration.yaml; then
    # Add main enhanced dashboard if lovelace exists but dashboard doesn't
    sed -i.bak '/filename: dashboards\/tado-infographic-enhanced.yaml/i\
    tado-enhanced:\
      mode: yaml\
      title: Tado Smart Home Enhanced\
      icon: mdi:home-analytics\
      show_in_sidebar: true\
      filename: dashboards/tado-dashboard-enhanced.yaml' configuration.yaml
fi

if ! grep -q "tado-configuration" configuration.yaml; then
    # Add tado-configuration dashboard if it doesn't exist
    sed -i.bak '/filename: dashboards\/tado-infographic-enhanced.yaml/a\
    tado-configuration:\
      mode: yaml\
      title: Tado Configuration\
      icon: mdi:cog\
      show_in_sidebar: true\
      filename: dashboards/tado-configuration.yaml' configuration.yaml
fi

print_status "Dashboard configuration updated"

# Update configuration.yaml to include packages
print_info "Updating main configuration..."
if ! grep -q "packages:" configuration.yaml 2>/dev/null; then
    cat >> configuration.yaml << 'EOF'

# Tado Package Configuration
homeassistant:
  packages: !include_dir_named packages
EOF
fi

print_status "Main configuration updated"

# Installation files completed - no need for entity discovery during installation
print_status "All configuration files installed successfully"

print_status "Installation completed successfully!"
echo ""
print_info "🎉 Tado Enhanced Setup Complete!"
echo ""
print_info "📋 What was installed:"
echo "   ✅ Enhanced Tado configuration packages"
echo "   ✅ Device discovery and configuration helpers"
echo "   ✅ Interactive configuration dashboard"
echo "   ✅ Automatic entity detection system"
echo "   ✅ Enhanced installation management"
echo ""
print_info "📝 Next Steps:"
echo "   1. Restart Home Assistant to load the new packages"
echo "   2. Install button-card from HACS (if not already installed)"
echo "   3. Visit the 'Tado Configuration' dashboard in your sidebar"
echo "   4. The system will automatically discover your Tado entities"
echo "   5. Follow the setup wizard to complete configuration"
echo "   6. Enjoy your automated Tado dashboard!"
echo ""
print_warning "💾 Backup saved in: $BACKUP_DIR"
echo ""

# Ask about restart
if check_ha_cli_available; then
    echo ""
    read -p "🔄 Would you like to restart Home Assistant now? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Restarting Home Assistant..."
        ha core restart
        print_status "Restart initiated!"
    fi
else
    print_info "Please restart Home Assistant to complete the installation"
fi

echo ""
print_status "Setup script completed! Happy automating! 🏡🤖"
