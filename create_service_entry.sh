#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_FILE="$SCRIPT_DIR/a6700.service"

# Resolve current user and home directory
CURRENT_USER=$USER
HOME_DIR=$HOME

# Create the service file
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=A6700 Camera Control Script
After=network.target

[Service]
ExecStart=/usr/bin/bash $SCRIPT_DIR/a6700.sh
Restart=always
RestartSec=5
User=$CURRENT_USER
Group=$CURRENT_USER
WorkingDirectory=$SCRIPT_DIR
StandardOutput=append:journal
StandardError=append:journal
Environment=PATH=/usr/bin:/bin:/usr/sbin:/sbin
Environment=HOME=$HOME_DIR

[Install]
# WantedBy=multi-user.target
EOF

echo "Service file generated: $SERVICE_FILE"
echo "Copy or Move it to /etc/systemd/system/"
echo "Run: mv ./a6700.service /etc/systemd/system/"
echo "Then run: sudo systemctl daemon-reload"
echo "Then run: sudo systemctl start a6700.service"
echo " "
echo "This service DOES NOT run at startup."
echo "If you want it to run at startup, uncomment the '# WantedBy=multi-user.target' line."
echo " "
echo "Once the service is running, you can see its output by running:"
echo "journalctl -xefu a6700.service"