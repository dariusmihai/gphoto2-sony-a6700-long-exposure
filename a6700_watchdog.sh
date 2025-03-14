#!/bin/bash

# Path to your script
SCRIPT="/home/stellarmate/cameracontrol/a6700/a6700.sh"

# Loop to restart the script if it crashes
while true; do
    # Start the script
    echo "Starting the a6700 script..."
    /bin/bash $SCRIPT

     # Check if the script exited with a non-zero exit code
    if [ $? -ne 0 ]; then
        echo "a6700.sh exited with an error. Restarting..."
    else
        echo "a6700.sh exited successfully. No restart needed."
        exit 0
    fi

    # If the script exits (crashes), restart it after a short delay
    echo "a6700 script crashed or exited. Restarting in 5 seconds..."
    sleep 5
done