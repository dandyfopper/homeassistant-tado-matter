# Alternative Dashboard Configuration Instructions

If the configuration.yaml approach doesn't work, here are alternative methods:

## Option A: Manual UI Addition (Easiest)
1. Go to Settings → Dashboards in Home Assistant
2. Click "Add Dashboard"
3. Title: "Tado Configuration"
4. Icon: mdi:cog
5. URL: tado-configuration
6. Check "Show in sidebar"
7. Create, then edit and paste YAML content

## Option B: Using ui-lovelace.yaml (Alternative)
If you prefer file-based configuration, you can use ui-lovelace.yaml instead:

1. Remove the lovelace section from configuration.yaml
2. Update ui-lovelace.yaml to include dashboard references
3. Restart Home Assistant

## Option C: Storage Mode with Manual Addition
Keep lovelace in storage mode and manually add dashboards through UI.
This is often the most reliable approach for Home Assistant.

## Troubleshooting Tips:
- Ensure the dashboard file exists: dashboards/tado-configuration.yaml
- Check Home Assistant logs for YAML errors
- Try restarting Home Assistant after configuration changes
- Verify no YAML syntax errors in configuration.yaml
