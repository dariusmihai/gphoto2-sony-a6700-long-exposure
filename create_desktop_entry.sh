#!/bin/bash

# Get the absolute path of the current directory
script_path="$(pwd)/a6700_watchdog.sh"

# Define fixed values
app_name="A6700 Watchdog"
app_desc="Start and monitor the a6700 watchdog"
app_icon="utilities-system-monitor"  # Or replace with a path to an icon

# Define the output desktop file name
desktop_file="./${app_name// /_}.desktop"

# Write the .desktop file
echo "[Desktop Entry]" > "$desktop_file"
echo "Version=1.0" >> "$desktop_file"
echo "Name=$app_name" >> "$desktop_file"
echo "Comment=$app_desc" >> "$desktop_file"
echo "Exec=$script_path" >> "$desktop_file"
echo "Icon=$app_icon" >> "$desktop_file"
echo "Terminal=true" >> "$desktop_file"
echo "Type=Application" >> "$desktop_file"
echo "Categories=Utility;" >> "$desktop_file"

# Make it executable
chmod +x "$desktop_file"

echo "The .desktop file has been created: $desktop_file"