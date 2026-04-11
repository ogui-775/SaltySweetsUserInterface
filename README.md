# Salty Sweets User Interface

This macOS application lets you theme your Dock and replace system icons. It's a straightforward tool for customizing your desktop appearance.

## Features
- **Dock Themer:** Apply different themes to your Dock, with the option to add back classic Mac OS X window reflections and icon reflections to your Dock.
- **Icon Replacement:** Replace system icons with your own designs, using file types like ICNS, PNG, BMP, and more.

## Getting Started
1. Download and install the application or build from this source.
2. Download and place the dylibs in "binaries" in /var/ammonia/core/tweaks/ along with appropriately named blacklist files (or use the default provided ones).
3. Open the Dock Themer section and select a theme using the File menu.
4. Go to Icon Replacement to add your custom icons.
5. Apply your changes.
6. If icons were applied, clear the system icon caches using the File menu option. Restart the Dock and the Finder.

## Requirements
- macOS 10.15 or later (for best support, use Tahoe 26.4 or newer).
- ammonia (https://github.com/CoreBedtime/ammonia).
-- libDockReflections, libIconRefCapture, and icon-server, provided in the "binaries" folder. These are the core components that are used with ammonia.

## License
MIT License - see the [LICENSE](LICENSE) file for details.

## Issues
Report any issues in the "Issues" section.
