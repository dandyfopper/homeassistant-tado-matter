# 🏠 Home Assistant Tado Smart Thermostat Integration

[![Home Assistant](https://img.shields.io/badge/Home%20Assistant-2024.1+-blue.svg)](https://www.home-assistant.io/)
[![Matter](https://img.shields.io/badge/Matter-Protocol-green.svg)](https://matter.home/)
[![Tado](https://img.shields.io/badge/Tado-Smart%20Thermostat-orange.svg)](https://www.tado.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Home Assistant integration for **Tado Smart Radiator Thermostat X** and **Tado Wireless Smart Thermostat X** devices connected via the **Matter protocol**. Features dynamic room configuration, beautiful dashboards, and intelligent automation.

## ✨ Features

- 🎨 **Beautiful Tado-themed Dashboard** with interactive house layout
- 🏠 **Dynamic Room Configuration** supporting 1-6 bedrooms + garage/loft
- 📱 **Responsive Design** optimized for desktop, tablet, and mobile
- 🤖 **Intelligent Automations** for presence, scheduling, and energy saving
- 📊 **Real-time Monitoring** with temperature/humidity graphs
- 🎛️ **Quick Control Scripts** for different heating modes
- 🏗️ **Modular Architecture** for easy customization

## 🚀 Quick Start

1. **Prerequisites**: Home Assistant with Matter integration enabled
2. **Install**: Copy configuration files to your HA config directory
3. **Setup**: Add your Tado devices via Matter integration
4. **Configure**: Update entity names to match your devices
5. **Enjoy**: Access your new Tado dashboard!

Detailed instructions in [INSTALLATION.md](INSTALLATION.md)

## 📱 Dashboard Preview

The dashboard automatically adapts to your home layout with:
- Interactive SVG house visualization
- Real-time temperature and humidity displays  
- One-touch climate control for each room
- Quick preset buttons for common scenarios
- Temperature history graphs and trends

## 🏘️ Supported Home Layouts

Choose from preset configurations or customize your own:

| Layout | Bedrooms | Garage | Loft | Total Zones |
|--------|----------|--------|------|-------------|
| Studio Apartment | 1 | ❌ | ❌ | 4 |
| Small House | 2 | ✅ | ❌ | 6 |
| Family Home | 3 | ✅ | ✅ | 8 |
| Large Family | 4 | ✅ | ✅ | 9 |
| Executive Home | 5 | ✅ | ✅ | 10 |
| Manor House | 6 | ✅ | ✅ | 11 |

*Core rooms (Living Room, Kitchen, Bathroom) are always included*

## Prerequisites

1. **Tado Devices Connected to Matter**
   - Ensure all your Tado devices are connected to your Matter network
   - Your Tado devices should appear in your Matter controller

2. **Home Assistant Setup**
   - Home Assistant should be running on homeassistant.local:8123
   - Matter integration should be enabled

## Installation Instructions

### 1. Copy Configuration Files

Copy all the configuration files to your Home Assistant configuration directory:

```bash
# Navigate to your Home Assistant config directory
cd /config

# Copy the main configuration
cp configuration.yaml configuration.yaml.backup  # Backup existing config
# Then merge the contents or use the provided configuration.yaml

# Create necessary directories
mkdir -p themes dashboards www

# Copy theme files
cp themes/tado_theme.yaml themes/

# Copy dashboard configuration
cp dashboards/tado-home.yaml dashboards/

# Copy static assets
cp www/house-layout.svg www/

# Copy automation and script files
cp automations.yaml .
cp scripts.yaml .
cp ui-lovelace.yaml .
```

### 2. Install Required Custom Components

You'll need the `button-card` custom component for the enhanced dashboard:

1. **Install HACS** (if not already installed):
   - Follow the instructions at https://hacs.xyz/docs/setup/download

2. **Install button-card**:
   - Go to HACS → Frontend
   - Search for "button-card"
   - Install the component

### 3. Configure Matter Integration

1. **Enable Matter Integration**:
   - Go to Settings → Devices & Services
   - Add Integration → Matter
   - Follow the setup wizard

2. **Add Tado Devices**:
   - Your Tado devices should automatically discover via Matter
   - If not, manually add them through the Matter integration

### 4. Update Entity Names

After your Tado devices are discovered, you'll need to update the entity names in the configuration files to match your actual device entities:

1. Check your actual entity names in Developer Tools → States
2. Update the following files with your actual entity names:
   - `configuration.yaml` (template sensors and groups)
   - `dashboards/tado-home.yaml` (dashboard entities)
   - `automations.yaml` (automation entities)
   - `scripts.yaml` (script entities)

Common entity naming patterns:
- `climate.tado_smart_radiator_thermostat_x_living_room`
- `sensor.tado_smart_radiator_thermostat_x_living_room_temperature`
- `sensor.tado_smart_radiator_thermostat_x_living_room_humidity`

### 5. Restart Home Assistant

After copying all files and updating entity names:
1. Go to Developer Tools → YAML
2. Check configuration
3. Restart Home Assistant

### 6. Add Dashboard

1. Go to your Home Assistant dashboard
2. Click the "+" to add a new dashboard
3. Select "Take control" and then import the Lovelace configuration
4. Or manually create a new dashboard and copy the contents from `dashboards/tado-home.yaml`

## Customization

### Room Layout
- Edit `www/house-layout.svg` to match your actual house layout
- Adjust the positions of thermostat icons in the dashboard YAML

### Device Mapping
Update the entity mappings based on your actual Tado device locations:

```yaml
# Example mapping - update with your actual entities
Living Room: climate.tado_smart_radiator_thermostat_x_living_room
Bedroom: climate.tado_smart_radiator_thermostat_x_bedroom  
Kitchen: climate.tado_smart_radiator_thermostat_x_kitchen
Office: climate.tado_wireless_smart_thermostat_x_office
```

### Automation Personalization
- Update `person.user` in automations.yaml with your actual person entity
- Adjust temperature settings and timing to match your preferences
- Add additional rooms or devices as needed

## Features

### Dashboard Features
- **Visual House Layout**: Interactive SVG showing your home with thermostat positions
- **Real-time Temperature**: Live temperature and humidity readings
- **Quick Controls**: Easy access to adjust each thermostat
- **Temperature History**: 24-hour temperature graph
- **Status Indicators**: Visual indicators for heating status

### Automation Features
- **Presence Detection**: Automatically adjust heating when away/home
- **Night Mode**: Lower bedroom temperature at night
- **Morning Warmup**: Pre-heat living areas in the morning
- **Window Open Detection**: Turn off heating when windows are open (if supported)

### Script Features
- **Eco Mode**: Set all thermostats to energy-saving temperature
- **Comfort Mode**: Set all thermostats to comfortable temperature
- **Party Mode**: Warm up social areas for entertaining
- **Sleep Mode**: Optimize temperatures for sleeping
- **Vacation Mode**: Minimal heating when away for extended periods

## Troubleshooting

### Common Issues

1. **Devices Not Appearing**:
   - Ensure Tado devices are properly connected to Matter
   - Check Matter integration status
   - Restart Home Assistant

2. **Dashboard Not Loading**:
   - Check that button-card is properly installed
   - Verify all entity names are correct
   - Check Home Assistant logs for errors

3. **Automations Not Working**:
   - Verify person entity exists and is correct
   - Check that climate entities support the required services
   - Enable automation debugging in logger

### Logs
Enable debugging for Tado/Matter components:

```yaml
logger:
  default: info
  logs:
    homeassistant.components.matter: debug
    homeassistant.components.climate: debug
```

## Support

For additional help:
- Check Home Assistant documentation for Matter integration
- Visit Tado support for device-specific issues
- Home Assistant community forums for configuration help

## License

This configuration is provided as-is for personal use. Modify as needed for your specific setup.

## 🏠 Dynamic Room Configuration

This Tado integration includes a flexible room layout system that adapts to different home configurations:

### 🔧 Configuration Options

- **Number of Bedrooms**: 1-6 bedrooms supported
- **Garage**: Toggle to include/exclude garage climate control
- **Loft**: Toggle to include/exclude loft climate control
- **Layout Presets**: Quick presets for common home types

### 🏘️ Supported Layout Presets

1. **Studio Apartment**: 1 bedroom, no garage, no loft (4 zones total)
2. **Small House**: 2 bedrooms, garage, no loft (6 zones total)
3. **Family Home**: 3 bedrooms, garage, loft (8 zones total)
4. **Large Family Home**: 4 bedrooms, garage, loft (9 zones total) - **DEFAULT**
5. **Executive Home**: 5 bedrooms, garage, loft (10 zones total)
6. **Manor House**: 6 bedrooms, garage, loft (11 zones total)

### 🎛️ How It Works

1. **Automatic Layout Detection**: The system automatically detects your current configuration
2. **Dynamic Dashboard**: Cards and room controls adapt based on your selection
3. **SVG House Layout**: Visual representation updates to show your exact room layout
4. **Entity Management**: Groups and sensors automatically include only active rooms
5. **Quick Switching**: Use preset buttons or manual configuration to change layouts

### 🏗️ Core Rooms (Always Present)

- Living Room
- Kitchen  
- Bathroom

### 🛏️ Variable Rooms

- **Bedrooms**: 1-6 configurable bedrooms with individual climate control
- **Garage**: Optional garage with climate control
- **Loft**: Optional loft/attic space with climate control

### 🎯 Default Configuration

The system defaults to a **Large Family Home** configuration:
- 4 Bedrooms
- Garage included
- Loft included
- **Total: 9 climate zones**

### 📊 Dynamic Features

All dashboard elements automatically adapt:
- Room control cards show only active rooms
- Temperature graphs include only configured spaces
- House layout SVG highlights active areas
- Automation scripts target only active zones
- Statistics and overviews reflect current configuration

### ⚙️ Entity Naming Convention

Entities follow this pattern:
- `climate.bedroom_1_tado` through `climate.bedroom_6_tado`
- `climate.garage_tado` (when enabled)
- `climate.loft_tado` (when enabled)
- `sensor.bedroom_1_tado_temperature` etc.

## 🚀 Quick Setup
