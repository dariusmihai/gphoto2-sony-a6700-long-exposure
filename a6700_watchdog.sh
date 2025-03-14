#!/bin/bash

# Path to your script
SCRIPT="/home/stellarmate/cameracontrol/a6700/a6700.sh"

# Loop to restart the script if it crashes
while true; do
    # Start the script
    echo "Starting the a6700 script..."
    /bin/bash $SCRIPT

    # If the script exits (crashes), restart it after a short delay
    echo "a6700 script crashed or exited. Restarting in 5 seconds..."
    sleep 5
done