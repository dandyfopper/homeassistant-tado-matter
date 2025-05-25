# Contributing to Home Assistant Tado Smart Thermostat Integration

Thank you for your interest in contributing to this project! This Home Assistant configuration provides a comprehensive integration for Tado Smart Thermostats via Matter protocol.

## How to Contribute

### 🐛 Bug Reports
If you find a bug, please create an issue with:
- Clear description of the problem
- Steps to reproduce
- Your Home Assistant version
- Your Tado device models
- Relevant logs or error messages

### 💡 Feature Requests
For new features:
- Describe the feature and why it would be useful
- Consider if it fits with the project's scope
- Check if similar functionality already exists

### 🔧 Code Contributions
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Test your changes thoroughly
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

### 📝 Documentation
Help improve the documentation:
- Fix typos or unclear instructions
- Add examples for different home configurations
- Update installation steps

## Development Guidelines

### Code Style
- Follow Home Assistant YAML conventions
- Use clear, descriptive entity names
- Comment complex automation logic
- Keep configurations modular

### Testing
- Test with different room configurations
- Verify automations work as expected
- Check dashboard responsiveness on mobile
- Validate configuration syntax

### Room Configuration Testing
When adding new room layouts:
- Test all preset configurations
- Verify dynamic SVG updates correctly
- Ensure entities are properly grouped
- Check automation compatibility

## Project Structure

```
├── README.md                      # Main documentation
├── INSTALLATION.md               # Detailed setup guide
├── configuration.yaml            # Main HA configuration
├── packages/
│   ├── tado.yaml                 # Core Tado package
│   └── room_configuration.yaml   # Dynamic room system
├── dashboards/
│   └── tado-home.yaml           # Dashboard configuration
├── themes/
│   └── tado_theme.yaml          # Tado-themed styling
├── www/
│   ├── house-layout.svg         # Static house layout
│   ├── house-layout-dynamic.svg # Dynamic house layout
│   ├── room-layout-mini.svg     # Mini layout preview
│   └── tado-dashboard.css       # Dashboard styling
├── automations.yaml             # Tado automations
├── scripts.yaml                 # Control scripts
└── ui-lovelace.yaml            # Dashboard config
```

## Questions?

Feel free to open an issue for any questions about:
- Installation and setup
- Customizing for your home layout
- Adding new device types
- Troubleshooting integrations

## Code of Conduct

Please be respectful and constructive in all interactions. This project is maintained by volunteers in their spare time.
