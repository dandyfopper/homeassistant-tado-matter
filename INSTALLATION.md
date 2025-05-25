# Tado Smart Thermostat Integration Setup

## 🏠 Complete Home Assistant Configuration for Tado Devices

This repository contains a complete Home Assistant setup for managing your Tado Smart Radiator Thermostats and Wireless Smart Thermostats through the Matter protocol, featuring a beautiful custom dashboard with house visualization.

## 📋 What You Get

### 🎛️ Custom Dashboard Features
- **Interactive House Layout**: Visual representation of your home with room-specific thermostat controls
- **Real-time Temperature Display**: Live temperature and humidity readings for each room
- **Quick Control Buttons**: Easy access to adjust individual thermostats
- **Temperature History Graph**: 24-hour temperature tracking
- **Status Indicators**: Visual heating status for each device
- **Mobile Responsive**: Works perfectly on phones and tablets

### 🤖 Smart Automations
- **Presence Detection**: Automatically adjust heating when you leave/return home
- **Night Mode**: Lower temperatures for optimal sleep
- **Morning Warmup**: Pre-heat your home before you wake up
- **Window Open Detection**: Turn off heating when windows are detected open
- **Mode Synchronization**: Coordinate all thermostats based on home mode

### 🎮 Control Scripts
- **Eco Mode**: Energy-saving temperatures across all devices
- **Comfort Mode**: Optimal comfort temperatures
- **Party Mode**: Warm up social areas for entertaining
- **Sleep Mode**: Bedroom cooling with living area economy
- **Vacation Mode**: Minimal heating for extended absences
- **Quick Boost**: Temporary temperature increase with auto-restore

## 🚀 Quick Start

### Prerequisites
- Home Assistant OS/Supervised/Container installation
- Tado devices connected to Matter network
- HACS (Home Assistant Community Store) installed

### 1. Download Files
Clone or download this repository to your Home Assistant configuration directory:

```bash
cd /config
git clone <this-repository> tado-setup
cd tado-setup
```

### 2. Run Setup Script
```bash
./setup_tado.sh
```

### 3. Install Dependencies
1. **Install HACS** (if not already installed):
   - Visit: https://hacs.xyz/docs/setup/download

2. **Install button-card**:
   - HACS → Frontend → Search "button-card" → Install

3. **Install card-mod** (optional, for advanced styling):
   - HACS → Frontend → Search "card-mod" → Install

### 4. Configure Matter Integration

1. **Add Matter Integration**:
   ```
   Settings → Devices & Services → Add Integration → Matter
   ```

2. **Discover Tado Devices**:
   - Your Tado devices should auto-discover
   - If not, manually add through Matter integration

### 5. Update Entity Names

After device discovery, update entity names in configuration files to match your actual devices:

**Common Tado Entity Patterns:**
```yaml
# Radiator Thermostats
climate.tado_smart_radiator_thermostat_x_[room]
sensor.tado_smart_radiator_thermostat_x_[room]_temperature
sensor.tado_smart_radiator_thermostat_x_[room]_humidity

# Wireless Thermostats  
climate.tado_wireless_smart_thermostat_x_[room]
sensor.tado_wireless_smart_thermostat_x_[room]_temperature
sensor.tado_wireless_smart_thermostat_x_[room]_humidity
```

**Files to Update:**
- `packages/tado.yaml`
- `dashboards/tado-home.yaml`
- `automations.yaml`
- `scripts.yaml`

### 6. Add Dashboard

1. **Method 1: UI Configuration**
   - Home Assistant → Dashboards → Add Dashboard
   - Choose "Take Control"
   - Copy contents from `dashboards/tado-home.yaml`

2. **Method 2: YAML Mode**
   - Replace `ui-lovelace.yaml` with provided file
   - Restart Home Assistant

### 7. Customize House Layout

Edit `www/house-layout.svg` to match your home:
- Adjust room positions and sizes
- Add/remove rooms as needed
- Update room labels
- Modify thermostat indicator positions

## 🎯 Dynamic Room Configuration

### Overview
This setup includes a revolutionary **dynamic room configuration system** that adapts to any home layout from studio apartments to large manor houses.

### 🏠 Supported Configurations

| Layout Type | Bedrooms | Garage | Loft | Total Zones |
|-------------|----------|--------|------|-------------|
| Studio Apartment | 1 | ❌ | ❌ | 4 |
| Small House | 2 | ✅ | ❌ | 6 |
| Family Home | 3 | ✅ | ✅ | 8 |
| **Large Family Home** | **4** | **✅** | **✅** | **9** (Default) |
| Executive Home | 5 | ✅ | ✅ | 10 |
| Manor House | 6 | ✅ | ✅ | 11 |
| Custom | 1-6 | ✅/❌ | ✅/❌ | 4-11 |

### 🔧 Configuration Methods

**1. Quick Presets** (Recommended for new users)
- Use preset buttons on the dashboard
- Instantly configure common home layouts
- Automatically sets bedrooms, garage, and loft

**2. Manual Configuration**
- Individual controls for each room type
- Perfect for custom layouts
- Automatically switches to "Custom" mode

**3. Configuration Files**
- Direct edit of `input_number` and `input_boolean` entities
- Useful for advanced users or automation setup

### 🎛️ How It Works

1. **Real-time Adaptation**: All dashboard elements instantly adapt to layout changes
2. **Visual Updates**: House SVG layout shows/hides rooms based on configuration
3. **Smart Entities**: Groups and sensors automatically include only active rooms
4. **Conditional Cards**: Cards appear/disappear based on room availability
5. **Dynamic Automations**: Scripts and automations target only configured spaces

### 📱 Dashboard Features

- **Interactive House Layout**: Visual representation with clickable thermostats
- **Room Status Grid**: Compact overview with temperature and humidity
- **Quick Control Buttons**: Easy access to individual room controls
- **Configuration Panel**: Live preview of current layout
- **Preset Buttons**: One-click switching between common layouts

## 🏗️ File Structure

```
/config/
├── configuration.yaml          # Main HA config with Tado integration
├── packages/
│   └── tado.yaml              # Complete Tado package configuration
├── themes/
│   └── tado_theme.yaml        # Custom Tado theme
├── dashboards/
│   └── tado-home.yaml         # Main dashboard configuration
├── www/
│   ├── house-layout.svg       # Interactive house layout
│   └── tado-dashboard.css     # Custom dashboard styling
├── automations.yaml           # Tado-specific automations
├── scripts.yaml              # Tado control scripts
└── ui-lovelace.yaml          # Dashboard configuration
```

## 🎨 Customization Guide

### Dashboard Customization

**Update Room Layout:**
```yaml
# In dashboards/tado-home.yaml
elements:
  - type: state-icon
    entity: climate.your_room_tado
    style:
      top: 25%    # Adjust vertical position
      left: 25%   # Adjust horizontal position
```

**Change Color Scheme:**
```yaml
# In themes/tado_theme.yaml
primary-color: "#YOUR_COLOR"
accent-color: "#YOUR_COLOR"
```

**Add New Room:**
1. Add climate entity to `packages/tado.yaml`
2. Create template sensor for room status
3. Add room to dashboard layout
4. Update house SVG with new room
5. Add to automation and script entities

### Automation Customization

**Adjust Temperature Settings:**
```yaml
# In automations.yaml
data:
  temperature: 21  # Change to your preferred temperature
```

**Modify Timing:**
```yaml
# Change automation trigger times
trigger:
  - platform: time
    at: "06:30:00"  # Adjust wake-up time
```

**Add Person Entity:**
```yaml
# Update with your person entity
entity_id: person.your_name
```

## 🔧 Advanced Configuration

### Energy Monitoring
If your Tado devices support energy monitoring, uncomment the utility meter sections in `packages/tado.yaml`.

### Multiple Zones
For homes with multiple heating zones, create additional climate groups and adjust automations accordingly.

### Geofencing
Integrate with Home Assistant's zone detection for more sophisticated presence-based heating control.

## 📱 Mobile App Integration

The dashboard is fully responsive and works great with the Home Assistant mobile app. Key features:
- Touch-friendly controls
- Optimized layouts for phone screens  
- Quick access to all thermostat functions
- Real-time status updates

## 🐛 Troubleshooting

### Common Issues

**Devices Not Discovered:**
```bash
# Check Matter integration logs
Settings → System → Logs → Filter by "matter"
```

**Dashboard Not Loading:**
```bash
# Verify button-card installation
HACS → Frontend → Installed → Search "button-card"
```

**Automations Not Triggering:**
```yaml
# Enable automation debugging
logger:
  logs:
    homeassistant.components.automation: debug
```

**Entity Names Don't Match:**
```bash
# Check actual entity names
Developer Tools → States → Search "tado"
```

### Performance Tips

1. **Reduce Update Frequency**: Adjust scan intervals if you have many devices
2. **Optimize Dashboard**: Remove unused cards for faster loading
3. **Database Cleanup**: Use recorder filters to limit stored data

## 📊 Dashboard Screenshots

*(Note: Add actual screenshots here when available)*

- Main dashboard with house layout
- Individual room controls
- Temperature history graphs
- Mobile view optimization

## 🤝 Contributing

Feel free to contribute improvements:
1. Fork the repository
2. Create feature branch
3. Submit pull request

Common contribution areas:
- Additional room layouts
- New automation scenarios
- Enhanced visualizations
- Bug fixes and optimizations

## 📄 License

This configuration is provided under MIT License for personal and commercial use.

## 🆘 Support

For help with this configuration:
1. **Home Assistant Community**: Post in the Tado or Matter integration forums
2. **Tado Support**: For device-specific issues
3. **Issue Tracker**: Report bugs or request features

## 🔗 Useful Links

- [Home Assistant Documentation](https://www.home-assistant.io/docs/)
- [Matter Integration Guide](https://www.home-assistant.io/integrations/matter/)
- [Tado Developer Documentation](https://developer.tado.com/)
- [HACS Installation Guide](https://hacs.xyz/docs/setup/download)
- [Button Card Documentation](https://github.com/custom-cards/button-card)

---

**Happy Home Automating! 🏡🤖**
