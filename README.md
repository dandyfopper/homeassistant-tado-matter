# 🏠 Enhanced Tado Smart Thermostat Integration for Home Assistant

## 🚀 One-Click Installation & Automatic Configuration

**The easiest way to set up Tado devices in Home Assistant!**

This enhanced version features **automatic device discovery**, **intelligent entity mapping**, and a **guided setup process** that adapts to your specific Tado devices.

---

## ✨ What's New in the Enhanced Version

### 🔧 **Automatic Setup**
- **One-click installation script** that handles everything
- **Automatic Tado device discovery** - no manual entity editing needed
- **Intelligent entity mapping** based on room names
- **Guided configuration wizard** with step-by-step instructions

### 🎯 **Smart Adaptation**
- **Dynamic configuration** that adapts to available devices
- **Flexible entity support** - works with any Tado entity names
- **Real-time device detection** and configuration updates
- **Fallback configurations** for missing devices

### 🎨 **Enhanced Dashboard**
- **Modern, responsive design** that works on all devices
- **Conditional cards** that only show available rooms
- **Real-time status indicators** for heating activity
- **Smart temperature controls** with presets and scenes

---

## 📋 What You Get

### 🎛️ **Enhanced Dashboard Features**
- 🏠 **Adaptive Room Grid** - Only shows your actual Tado devices
- 🌡️ **Smart Temperature Controls** - Comfort, Eco, Boost, and Party modes
- 📊 **Real-time Analytics** - Energy savings and efficiency tracking
- 📱 **Mobile Optimized** - Perfect for phones and tablets
- 🎨 **Beautiful Design** - Modern gradient-based theme

### 🤖 **Intelligent Automations**
- 🏠 **Home/Away Detection** - Automatic temperature adjustment
- 🌙 **Sleep Mode** - Optimized nighttime temperatures
- 🌅 **Morning Warmup** - Pre-heat before you wake up
- 🎉 **Party Mode** - Social area heating with bedroom economy
- 🌿 **Eco Scheduling** - Smart energy-saving patterns

### ⚙️ **Easy Configuration**
- 🔍 **Auto-Discovery** - Finds your Tado devices automatically
- 🎯 **Smart Mapping** - Matches devices to rooms intelligently
- 🔧 **Configuration Dashboard** - Easy setup and management
- 🔄 **Live Updates** - Real-time configuration changes

---

## 🚀 Super Easy Installation

### Option 1: One-Line Installation (Recommended)

Run this command from your Home Assistant configuration directory:

```bash
cd /config && curl -sSL https://raw.githubusercontent.com/your-repo/tado-enhanced/main/install_tado_enhanced.sh | bash
```

### Option 2: Manual Installation

1. **Download the files:**
```bash
cd /config
git clone https://github.com/your-repo/tado-enhanced.git
cd tado-enhanced
```

2. **Run the setup script:**
```bash
chmod +x install_tado_enhanced.sh
./install_tado_enhanced.sh
```

### Option 3: Step-by-Step Installation

1. **Download and extract** the files to your `/config` directory
2. **Copy the files** to the correct locations:
   - `packages/tado_enhanced.yaml` → `packages/`
   - `packages/tado_device_discovery.yaml` → `packages/`
   - `dashboards/tado-dashboard-enhanced.yaml` → `dashboards/`
   - `dashboards/tado-configuration.yaml` → `dashboards/`
3. **Update your `configuration.yaml`** to include packages:
```yaml
homeassistant:
  packages: !include_dir_named packages
```
4. **Restart Home Assistant**

---

## 📝 Post-Installation Setup

### 1. Install Dependencies (if not done automatically)
- **HACS**: Install from https://hacs.xyz if not already installed
- **button-card**: HACS → Frontend → Search "button-card" → Install
- **card-mod** (optional): HACS → Frontend → Search "card-mod" → Install

### 2. Follow the Setup Wizard
1. **Restart Home Assistant** after installation
2. **Go to "Tado Configuration"** in your sidebar
3. **Click "Auto-Discover Devices"** to find your Tado entities
4. **Review and apply** the automatic configuration
5. **Visit the main dashboard** to see your devices!

### 3. Customize (Optional)
- **Adjust room layouts** using the configuration dashboard
- **Modify temperature presets** to your preferences
- **Set up automations** for your daily routines

---

## 🎯 How It Works

### Smart Device Discovery
The system automatically:
1. **Scans for Tado entities** in your Home Assistant
2. **Matches devices to rooms** based on entity names
3. **Creates dynamic templates** that adapt to your devices
4. **Updates the dashboard** to show only available rooms

### Intelligent Entity Mapping
- **Living Room**: Looks for entities with "living", "lounge", or "main"
- **Bedroom**: Matches "bedroom", "bed", "sleep", or "master"
- **Kitchen**: Finds "kitchen", "dining", or "cook"
- **Office**: Matches "office", "study", "work", or "den"

### Fallback Support
If a device isn't found:
- **Dashboard adapts** to hide unavailable rooms
- **Scripts continue working** with available devices
- **Manual override** available through configuration

---

## 🎨 Dashboard Features

### Main Dashboard Views

#### 🏠 **Smart Home Overview**
- **Quick status bar** with home temperature and energy savings
- **One-click mode buttons** for Comfort, Eco, Boost, and Party
- **Adaptive room grid** showing only your actual devices
- **Individual room cards** with temperature and heating status

#### ⚙️ **Device Configuration**
- **Auto-discovery controls** for finding devices
- **Entity mapping interface** for manual configuration
- **Real-time status display** of discovered devices
- **Entity reference guide** for troubleshooting

#### 📊 **Temperature History**
- **24-hour temperature graphs** for all rooms
- **Daily average statistics** for efficiency tracking
- **Energy efficiency gauges** with visual indicators
- **Historical trend analysis** for optimization

---

## 🔧 Advanced Configuration

### Custom Entity Names
If you have non-standard entity names, manually configure them:

1. **Go to the Configuration dashboard**
2. **Set "Device Setup Mode" to "Manual Configuration"**
3. **Enter your entity names** in the text fields
4. **Click "Apply Configuration"**

### Adding More Rooms
To add additional rooms beyond the standard four:

1. **Add new input_text entities** in `packages/tado_device_discovery.yaml`
2. **Create corresponding template sensors** in `packages/tado_enhanced.yaml`
3. **Add new room cards** to the dashboard configuration
4. **Update scripts** to include the new entities

### Custom Temperature Presets
Modify the temperature settings in the Configuration dashboard:
- **Comfort Temperature**: Default 21°C
- **Eco Temperature**: Default 18°C
- **Boost Temperature**: Default 25°C

---

## 🤝 Supported Tado Devices

### ✅ **Fully Supported**
- **Tado Smart Radiator Thermostats** (all versions)
- **Tado Wireless Smart Thermostats** (all versions)
- **Tado devices via Matter integration**
- **Tado devices via official integration**

### 🔌 **Integration Methods**
- **Matter Protocol** (recommended for new setups)
- **Official Tado Integration** (cloud-based)
- **Custom Integrations** (community solutions)

### 📡 **Entity Patterns Detected**
The system automatically detects these common patterns:
- `climate.tado_smart_radiator_thermostat_*`
- `climate.tado_wireless_smart_thermostat_*`
- `climate.*tado*` (any entity containing "tado")
- Custom patterns can be manually configured

---

## 🔧 Troubleshooting

### Common Installation Issues

#### Issue: CLI commands not working / API requires authentication
**Symptoms:** Installation script reports CLI errors or API authentication failures
**Solutions:**
This is completely normal! The installation script no longer depends on CLI commands or API access for entity discovery. Instead:

1. **Entity discovery happens automatically** after Home Assistant restarts through template sensors
2. **No CLI dependency** - the script only copies files and updates configuration
3. **No API authentication needed** - discovery happens inside Home Assistant
4. **Works with all HA installation types** - OS, Supervised, Container, Core

**What the script does now:**
- ✅ Copies configuration files to correct locations
- ✅ Creates device discovery helpers  
- ✅ Sets up configuration dashboard
- ✅ Updates configuration.yaml to include packages
- ✅ Entity discovery happens after restart via templates

#### Issue: "ha supervisor api" command doesn't exist
**Solution:** This command was removed from the script. Entity discovery now happens through Home Assistant's built-in template sensors after restart.

#### Issue: Entity discovery not working during installation
**This is normal!** Entity discovery no longer happens during installation.

**How it works now:**
1. **Installation script** copies files and sets up configuration
2. **Restart Home Assistant** to load the new packages
3. **Template sensors automatically discover** Tado entities
4. **Use the Configuration dashboard** to see discovered entities and complete setup

**No manual CLI commands needed** - everything happens automatically through Home Assistant's template system.

#### Issue: Home Assistant CLI not available
**This is completely normal!** The installation script no longer requires CLI access.

**For different installation types:**
- **Home Assistant OS/Supervised:** CLI available but not needed
- **Container/Core installations:** CLI typically not available, but not needed
- **All installations:** Entity discovery works through template sensors after restart

**No additional software needed** - the script works without any CLI dependencies.

#### Issue: Package configuration not loading
**Symptoms:** Tado helpers not appearing in Home Assistant
**Solutions:**
1. Check that `configuration.yaml` includes packages:
   ```yaml
   homeassistant:
     packages: !include_dir_named packages
   ```
2. Validate YAML syntax:
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('packages/tado_device_discovery.yaml'))"
   ```
3. Check Home Assistant logs for package loading errors
4. Restart Home Assistant after adding packages

#### Issue: Dashboard not appearing in sidebar
**Solutions:**
1. Check that `ui-lovelace.yaml` exists and includes dashboard configuration
2. Make sure dashboard mode is set to YAML in Configuration → Dashboards
3. Verify the dashboard file exists in `dashboards/tado-configuration.yaml`
4. Clear browser cache and refresh

#### Issue: Button-card not working
**Symptoms:** Dashboard cards showing as "Custom element doesn't exist"
**Solutions:**
1. Install button-card via HACS:
   - Go to HACS → Frontend
   - Search for "button-card"
   - Install and restart
2. Clear browser cache after installation
3. Check that HACS is properly configured

### Advanced Debugging

#### Check Entity Discovery
```bash
# Run health check script
./health_check.sh

# Manual entity checking
grep -r "tado" /config/packages/
ha supervisor api --raw-json /core/api/states | grep -i tado
```

#### Validate Installation
```bash
# Check file structure
ls -la packages/tado*.yaml
ls -la dashboards/tado*.yaml

# Check YAML syntax
python3 -c "import yaml; [yaml.safe_load(open(f)) for f in ['packages/tado_enhanced.yaml', 'packages/tado_device_discovery.yaml']]"
```

#### Reset Installation
If you need to start over:
```bash
# Run with force reinstall
./install_tado_enhanced.sh --force

# Or manual cleanup
rm -rf packages/tado*.yaml dashboards/tado*.yaml
# Then reinstall
```

#### Common Entity Patterns
If automatic discovery fails, check for these common Tado entity patterns:
- `climate.tado_smart_thermostat_*`
- `climate.*_tado`
- `sensor.tado_*_temperature`
- `sensor.*_tado_*`

### Getting Help

If you're still having issues:

1. **Check the logs:** Go to Settings → System → Logs and look for Tado-related errors
2. **Run health check:** Execute `./health_check.sh` to identify specific issues  
3. **Validate setup:** Use the Tado Configuration dashboard to check device detection
4. **Update:** Try running `./update_tado.sh` to get the latest fixes
5. **Create an issue:** Include your Home Assistant version, installation method, and error logs

---
