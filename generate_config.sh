#!/bin/bash

# Tado Enhanced Configuration Generator
# This script helps create advanced configurations for specific needs

set -e

echo "⚙️ Tado Enhanced Configuration Generator"
echo "========================================"
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

# Configuration options
echo "Select configuration type:"
echo "1) 🏠 Multi-zone configuration (3+ rooms)"
echo "2) 🌡️ Advanced automation with weather integration"
echo "3) 📱 Mobile-friendly compact dashboard"
echo "4) 🔋 Energy monitoring configuration"
echo "5) 🎯 Custom room configuration"
echo "6) 🚪 Window sensor integration"
echo ""

read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        print_info "Generating multi-zone configuration..."
        CONFIG_TYPE="multizone"
        ;;
    2)
        print_info "Generating weather integration configuration..."
        CONFIG_TYPE="weather"
        ;;
    3)
        print_info "Generating mobile-friendly configuration..."
        CONFIG_TYPE="mobile"
        ;;
    4)
        print_info "Generating energy monitoring configuration..."
        CONFIG_TYPE="energy"
        ;;
    5)
        print_info "Generating custom room configuration..."
        CONFIG_TYPE="custom"
        ;;
    6)
        print_info "Generating window sensor configuration..."
        CONFIG_TYPE="windows"
        ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

# Create configurations directory
mkdir -p configurations/

case $CONFIG_TYPE in
    "multizone")
        cat > configurations/tado_multizone.yaml << 'EOF'
# Multi-zone Tado Configuration
# Supports unlimited rooms with dynamic discovery

template:
  - sensor:
      # Zone Summary Sensor
      - name: "Tado Zones Summary"
        unique_id: "tado_zones_summary"
        state: >
          {% set zones = states.climate | selectattr('entity_id', 'search', 'tado') | list %}
          {{ zones | length }} zones configured
        attributes:
          total_zones: >
            {% set zones = states.climate | selectattr('entity_id', 'search', 'tado') | list %}
            {{ zones | length }}
          active_zones: >
            {% set zones = states.climate | selectattr('entity_id', 'search', 'tado') | selectattr('attributes.hvac_action', 'eq', 'heating') | list %}
            {{ zones | length }}
          average_temperature: >
            {% set zones = states.climate | selectattr('entity_id', 'search', 'tado') | list %}
            {% set temps = zones | map(attribute='attributes.current_temperature') | select('number') | list %}
            {% if temps | length > 0 %}
              {{ (temps | sum / temps | length) | round(1) }}°C
            {% else %}Unknown{% endif %}
          zones_heating: >
            {% set zones = states.climate | selectattr('entity_id', 'search', 'tado') | selectattr('attributes.hvac_action', 'eq', 'heating') | map(attribute='name') | list %}
            {{ zones | join(', ') if zones else 'None' }}

automation:
  # Master zone control
  - id: tado_master_zone_control
    alias: "Tado Master Zone Control"
    trigger:
      - platform: state
        entity_id: input_boolean.tado_master_control
    action:
      - choose:
          - conditions:
              - condition: state
                entity_id: input_boolean.tado_master_control
                state: 'on'
            sequence:
              - service: climate.set_temperature
                target:
                  entity_id: >
                    {{ states.climate | selectattr('entity_id', 'search', 'tado') | map(attribute='entity_id') | list }}
                data:
                  temperature: "{{ states('input_number.tado_master_temperature') | float }}"
          - conditions:
              - condition: state
                entity_id: input_boolean.tado_master_control
                state: 'off'
            sequence:
              - service: climate.set_hvac_mode
                target:
                  entity_id: >
                    {{ states.climate | selectattr('entity_id', 'search', 'tado') | map(attribute='entity_id') | list }}
                data:
                  hvac_mode: "off"

input_boolean:
  tado_master_control:
    name: "Master Zone Control"
    icon: mdi:thermostat

input_number:
  tado_master_temperature:
    name: "Master Temperature"
    min: 5
    max: 30
    step: 0.5
    unit_of_measurement: "°C"
    icon: mdi:thermometer
EOF
        print_status "Multi-zone configuration created: configurations/tado_multizone.yaml"
        ;;

    "weather")
        cat > configurations/tado_weather.yaml << 'EOF'
# Weather Integration for Tado
# Automatically adjusts heating based on weather conditions

automation:
  # Weather-based heating adjustment
  - id: tado_weather_adjustment
    alias: "Tado Weather Adjustment"
    trigger:
      - platform: state
        entity_id: weather.home
        attribute: temperature
      - platform: time
        at: "06:00:00"
      - platform: time
        at: "18:00:00"
    condition:
      - condition: state
        entity_id: input_boolean.tado_weather_control
        state: 'on'
    action:
      - service: script.tado_weather_adjust

  # Forecast-based pre-heating
  - id: tado_forecast_preheat
    alias: "Tado Forecast Pre-heating"
    trigger:
      - platform: time
        at: "05:00:00"
    condition:
      - condition: template
        value_template: >
          {{ state_attr('weather.home', 'forecast')[0].temperature < 5 }}
    action:
      - service: climate.set_temperature
        target:
          entity_id: >
            {{ states.climate | selectattr('entity_id', 'search', 'tado') | map(attribute='entity_id') | list }}
        data:
          temperature: "{{ states('input_number.tado_cold_weather_temp') | float }}"

script:
  tado_weather_adjust:
    alias: "Adjust Tado Based on Weather"
    sequence:
      - service: climate.set_temperature
        target:
          entity_id: >
            {{ states.climate | selectattr('entity_id', 'search', 'tado') | map(attribute='entity_id') | list }}
        data:
          temperature: >
            {% set outdoor_temp = state_attr('weather.home', 'temperature') | float %}
            {% if outdoor_temp < 0 %}
              {{ states('input_number.tado_freezing_temp') | float }}
            {% elif outdoor_temp < 10 %}
              {{ states('input_number.tado_cold_temp') | float }}
            {% else %}
              {{ states('input_number.tado_mild_temp') | float }}
            {% endif %}

input_boolean:
  tado_weather_control:
    name: "Weather-based Control"
    icon: mdi:weather-partly-cloudy

input_number:
  tado_freezing_temp:
    name: "Freezing Weather Temperature"
    min: 18
    max: 25
    step: 0.5
    initial: 22
    unit_of_measurement: "°C"
  
  tado_cold_temp:
    name: "Cold Weather Temperature"
    min: 16
    max: 23
    step: 0.5
    initial: 20
    unit_of_measurement: "°C"
    
  tado_mild_temp:
    name: "Mild Weather Temperature"
    min: 14
    max: 21
    step: 0.5
    initial: 18
    unit_of_measurement: "°C"
EOF
        print_status "Weather integration configuration created: configurations/tado_weather.yaml"
        ;;

    "mobile")
        cat > configurations/tado_mobile_dashboard.yaml << 'EOF'
# Mobile-Optimized Tado Dashboard
title: Tado Mobile
views:
  - title: Quick Control
    path: quick
    icon: mdi:speedometer
    cards:
      - type: grid
        columns: 2
        square: false
        cards:
          - type: tile
            entity: climate.living_room_tado
            features:
              - type: climate-hvac-modes
              - type: target-temperature
            
          - type: tile  
            entity: climate.bedroom_tado
            features:
              - type: climate-hvac-modes
              - type: target-temperature

      - type: entities
        title: Quick Actions
        entities:
          - entity: input_boolean.tado_master_control
            name: Master Control
          - entity: input_number.tado_master_temperature
            name: Set All Zones
          - entity: script.tado_all_zones_off
            name: Turn Off All

      - type: horizontal-stack
        cards:
          - type: button
            entity: script.tado_comfort_mode
            name: Comfort
            icon: mdi:sofa
            tap_action:
              action: call-service
              service: script.turn_on
              target:
                entity_id: script.tado_comfort_mode
                
          - type: button
            entity: script.tado_eco_mode
            name: Eco
            icon: mdi:leaf
            tap_action:
              action: call-service
              service: script.turn_on
              target:
                entity_id: script.tado_eco_mode

  - title: Detailed
    path: detailed
    icon: mdi:details
    cards:
      - type: thermostat
        entity: climate.living_room_tado
        
      - type: thermostat
        entity: climate.bedroom_tado
        
      - type: history-graph
        entities:
          - climate.living_room_tado
          - climate.bedroom_tado
        hours_to_show: 24
EOF
        print_status "Mobile dashboard configuration created: configurations/tado_mobile_dashboard.yaml"
        ;;

    "energy")
        cat > configurations/tado_energy.yaml << 'EOF'
# Energy Monitoring for Tado
# Tracks heating costs and efficiency

template:
  - sensor:
      # Daily heating cost estimate
      - name: "Tado Daily Heating Cost"
        unique_id: "tado_daily_heating_cost"
        state: >
          {% set active_zones = states.climate | selectattr('entity_id', 'search', 'tado') | selectattr('attributes.hvac_action', 'eq', 'heating') | list | length %}
          {% set cost_per_hour = states('input_number.heating_cost_per_hour') | float %}
          {% set hours_today = now().hour %}
          {{ (active_zones * cost_per_hour * hours_today) | round(2) }}
        unit_of_measurement: "£"
        device_class: monetary

      # Efficiency score
      - name: "Tado Efficiency Score"
        unique_id: "tado_efficiency_score"
        state: >
          {% set zones = states.climate | selectattr('entity_id', 'search', 'tado') | list %}
          {% set total_zones = zones | length %}
          {% set active_zones = zones | selectattr('attributes.hvac_action', 'eq', 'heating') | list | length %}
          {% if total_zones > 0 %}
            {{ ((total_zones - active_zones) / total_zones * 100) | round(0) }}
          {% else %}0{% endif %}
        unit_of_measurement: "%"

automation:
  # High energy usage alert
  - id: tado_high_energy_alert
    alias: "Tado High Energy Usage Alert"
    trigger:
      - platform: numeric_state
        entity_id: sensor.tado_daily_heating_cost
        above: input_number.max_daily_heating_cost
    action:
      - service: notify.mobile_app_your_phone
        data:
          title: "High Heating Cost Alert"
          message: "Today's heating cost is £{{ states('sensor.tado_daily_heating_cost') }}"

input_number:
  heating_cost_per_hour:
    name: "Heating Cost per Hour"
    min: 0.10
    max: 2.00
    step: 0.05
    initial: 0.25
    unit_of_measurement: "£"
    
  max_daily_heating_cost:
    name: "Max Daily Heating Cost"
    min: 5
    max: 50
    step: 1
    initial: 15
    unit_of_measurement: "£"
EOF
        print_status "Energy monitoring configuration created: configurations/tado_energy.yaml"
        ;;

    "custom")
        echo ""
        read -p "Enter the number of rooms you want to configure: " num_rooms
        read -p "Enter room names (comma-separated): " room_names
        
        # Generate custom configuration
        cat > configurations/tado_custom.yaml << EOF
# Custom Tado Configuration
# Generated for: $room_names

input_text:
EOF
        
        IFS=',' read -ra ROOMS <<< "$room_names"
        for room in "${ROOMS[@]}"; do
            room_clean=$(echo "$room" | tr '[:upper:]' '[:lower:]' | sed 's/ /_/g' | tr -d '[:space:]')
            cat >> configurations/tado_custom.yaml << EOF
  tado_${room_clean}_entity:
    name: "Tado ${room^} Entity"
    initial: "climate.${room_clean}_tado"
EOF
        done
        
        print_status "Custom configuration created: configurations/tado_custom.yaml"
        ;;

    "windows")
        cat > configurations/tado_windows.yaml << 'EOF'
# Window Sensor Integration for Tado
# Automatically turns off heating when windows are open

automation:
  # Turn off heating when window opens
  - id: tado_window_open_heating_off
    alias: "Tado Window Open - Turn Off Heating"
    trigger:
      - platform: state
        entity_id: 
          - binary_sensor.living_room_window
          - binary_sensor.bedroom_window
          - binary_sensor.kitchen_window
        to: 'on'
    action:
      - service: climate.set_hvac_mode
        target:
          entity_id: >
            {% set room = trigger.entity_id.split('.')[1].replace('_window', '') %}
            climate.{{ room }}_tado
        data:
          hvac_mode: 'off'
      - service: script.store_previous_tado_state

  # Restore heating when window closes
  - id: tado_window_close_heating_restore
    alias: "Tado Window Close - Restore Heating"
    trigger:
      - platform: state
        entity_id:
          - binary_sensor.living_room_window
          - binary_sensor.bedroom_window  
          - binary_sensor.kitchen_window
        to: 'off'
        for: "00:02:00"  # 2 minute delay
    action:
      - service: script.restore_previous_tado_state

script:
  store_previous_tado_state:
    alias: "Store Previous Tado State"
    sequence:
      - service: input_text.set_value
        target:
          entity_id: input_text.tado_previous_state
        data:
          value: >
            {% set room = trigger.entity_id.split('.')[1].replace('_window', '') %}
            {% set climate_entity = 'climate.' + room + '_tado' %}
            {{ states(climate_entity) }}

  restore_previous_tado_state:
    alias: "Restore Previous Tado State" 
    sequence:
      - service: climate.set_hvac_mode
        target:
          entity_id: >
            {% set room = trigger.entity_id.split('.')[1].replace('_window', '') %}
            climate.{{ room }}_tado
        data:
          hvac_mode: "{{ states('input_text.tado_previous_state') }}"

input_text:
  tado_previous_state:
    name: "Previous Tado State"
EOF
        print_status "Window sensor configuration created: configurations/tado_windows.yaml"
        ;;
esac

echo ""
print_info "Configuration file created in the 'configurations/' directory"
print_warning "To use this configuration:"
echo "  1. Copy the generated file to your packages/ directory"
echo "  2. Restart Home Assistant"
echo "  3. Configure any required input helpers in the UI"
echo ""
print_info "For more advanced configurations, edit the generated file as needed"
