# Tado Infographic Dashboard - Installation Guide

## Quick Start

This guide will help you set up the enhanced Tado Infographic Dashboard in your Home Assistant installation.

### Prerequisites

- ✅ Home Assistant 2023.4 or later
- ✅ HACS (Home Assistant Community Store) installed
- ✅ Tado devices configured in Home Assistant (via Matter or native integration)

## Step-by-Step Installation

### 1. Install Required HACS Components

#### Install button-card
1. Open HACS in Home Assistant
2. Go to **Frontend** section
3. Search for **"button-card"**
4. Click **Install**

#### Install ApexCharts (Optional - for Analytics)
1. In HACS **Frontend** section
2. Search for **"apexcharts-card"**  
3. Click **Install**

### 2. Copy Dashboard Files

Copy these files to your Home Assistant configuration directory:

```bash
# Create directories if they don't exist
mkdir -p /config/dashboards
mkdir -p /config/www
mkdir -p /config/packages

# Copy dashboard files
cp dashboards/tado-infographic-enhanced.yaml /config/dashboards/
cp www/house-layout-infographic.svg /config/www/
cp www/tado-infographic.css /config/www/
cp www/tado-infographic.js /config/www/
cp packages/tado_demo_data.yaml /config/packages/
```

### 3. Configure Packages (Optional)

If you want demo data and enhanced sensors, add to your `configuration.yaml`:

```yaml
homeassistant:
  packages: !include_dir_named packages
```

### 4. Update Entity Names

Edit `/config/dashboards/tado-infographic-enhanced.yaml` and replace these example entities with your actual Tado device entities:

**Replace these examples:**
```yaml
climate.living_room_thermostat    # → your living room thermostat
climate.kitchen_thermostat        # → your kitchen thermostat  
climate.bedroom_1_thermostat      # → your bedroom thermostat
climate.office_thermostat         # → your office thermostat
```

**Find your actual entity names:**
1. Go to **Developer Tools** → **States**
2. Search for entities starting with `climate.`
3. Note down your Tado thermostat entity IDs

### 5. Add Dashboard to Home Assistant

#### Method A: Dashboard UI
1. Go to **Settings** → **Dashboards**
2. Click **+ Add Dashboard**
3. Choose **New dashboard**
4. Toggle **YAML mode** 
5. Paste the contents of `tado-infographic-enhanced.yaml`
6. Save as "Tado Infographic"

#### Method B: Configuration File
Add to your `ui-lovelace.yaml`:
```yaml
dashboards:
  tado-infographic:
    mode: yaml
    filename: dashboards/tado-infographic-enhanced.yaml
    title: Tado Smart Home
    icon: mdi:home-thermometer
    show_in_sidebar: true
```

### 6. Restart Home Assistant

Restart Home Assistant to load the new configuration and packages.

## Configuration Options

### Enable Demo Mode

If you want to test the dashboard with simulated data:

1. Go to **Developer Tools** → **Services**
2. Call service: `input_boolean.turn_on`
3. Entity: `input_boolean.tado_demo_mode`

### Configure Room Layout

Adjust the number of rooms shown:

```yaml
# Set number of bedrooms (1-6)
input_number.tado_number_of_bedrooms: 4

# Include optional rooms  
input_boolean.tado_include_garage: true
input_boolean.tado_include_loft: true
```

### Customize Room Layout

Edit `input_select.tado_room_layout` options in your packages configuration:

```yaml
input_select:
  tado_room_layout:
    name: "House Layout"
    options:
      - "4 Bed + Garage + Loft"
      - "3 Bed + Garage" 
      - "2 Bed Apartment"
      - "Custom Layout"
```

## Troubleshooting

### Dashboard Not Loading
1. **Check HACS components installed:**
   - `button-card` is required
   - `apexcharts-card` needed for analytics view

2. **Verify file locations:**
   ```bash
   ls -la /config/dashboards/tado-infographic-enhanced.yaml
   ls -la /config/www/house-layout-infographic.svg
   ls -la /config/www/tado-infographic.css
   ```

3. **Check configuration errors:**
   - Go to **Developer Tools** → **Check Configuration**
   - Look for YAML syntax errors

### Entities Not Found
1. **Update entity names** in dashboard YAML to match your devices
2. **Check Tado integration** is working:
   ```
   Developer Tools → States → search "climate."
   ```

### No Temperature Data
1. **Enable demo mode** temporarily:
   ```yaml
   input_boolean.tado_demo_mode: true
   ```
2. **Check Matter integration** is configured properly
3. **Verify device connectivity** in Tado app

### SVG Layout Not Showing
1. **Check file permissions:**
   ```bash
   chmod 644 /config/www/house-layout-infographic.svg
   ```
2. **Clear browser cache** (Ctrl+F5)
3. **Check Home Assistant logs** for file access errors

### Styling Issues
1. **Verify CSS file** is accessible at `/local/tado-infographic.css`
2. **Check browser console** for CSS loading errors
3. **Clear browser cache** completely

## Validation

Run the validation script to check your installation:

```bash
cd /path/to/tado/project
./validate_infographic.sh
```

This will verify:
- ✅ All files exist and are valid
- ✅ YAML syntax is correct  
- ✅ SVG structure is valid
- ✅ CSS and JavaScript have no syntax errors
- ✅ Required components are configured

## Advanced Configuration

### Custom Themes

Create your own color scheme by editing `/config/www/tado-infographic.css`:

```css
/* Custom color scheme */
.infographic-container {
  background: linear-gradient(135deg, #your-color1, #your-color2);
}

.temp-zone-comfortable {
  background: radial-gradient(circle, #your-green, #your-light-green);
}
```

### Additional Sensors

Add custom sensors to the demo data package:

```yaml
template:
  - sensor:
      - name: "Your Custom Metric"
        state: "{{ your_calculation }}"
        unit_of_measurement: "units"
```

### Custom Room Layouts

Modify the SVG file to match your house layout:

1. Edit `/config/www/house-layout-infographic.svg`
2. Adjust room positions and sizes
3. Update room labels and thermostat positions
4. Test with browser SVG preview

## Support

### Getting Help

1. **Check the logs:**
   ```
   Settings → System → Logs
   Search for "tado" or "dashboard"
   ```

2. **Test individual components:**
   - Try loading SVG directly: `http://your-ha:8123/local/house-layout-infographic.svg`
   - Check CSS: `http://your-ha:8123/local/tado-infographic.css`

3. **Validate your configuration:**
   ```bash
   ./validate_infographic.sh
   ```

### Common Solutions

| Problem | Solution |
|---------|----------|
| Blank dashboard | Install button-card via HACS |
| No house layout | Check SVG file location and permissions |
| Wrong entities | Update entity names in YAML |
| No styling | Verify CSS file is accessible |
| Missing data | Enable demo mode or check Tado integration |

### Performance Optimization

- **Update intervals:** Adjust sensor update frequency
- **Image optimization:** Use compressed SVG files  
- **Browser cache:** Leverage caching for better performance
- **Mobile responsiveness:** Test on various screen sizes

## Next Steps

Once installed successfully:

1. **🎨 Customize** the layout to match your home
2. **📊 Explore** the analytics dashboard for insights
3. **🔧 Configure** automations for optimal comfort
4. **📱 Test** mobile responsiveness 
5. **⚡ Optimize** for performance

Enjoy your beautiful new Tado Infographic Dashboard! 🏠✨
