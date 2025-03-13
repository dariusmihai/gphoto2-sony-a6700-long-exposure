#!/bin/bash

#######################################################################################
# On the Sony A6700, set the bulb timer from the camera settings                    ###
# Menu -> Exposure -> Bulb timer. Set to On and Exposure time to the desired length ###
#######################################################################################

# Change the following values according to what you're trying to achieve
NUM_EXPOSURES=5
EXPOSURE_TIME=120  # Set this to match the bulb timer setting in the camera
SAVE_PATH="$HOME/a6700"

########################################################################################
# Do not change anything below this line unless you know what you're doing           ###
########################################################################################

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -e|--exposure-length)
            EXPOSURE_TIME="$2"
            shift 2
            ;;
        -n|--num-exposures)
            NUM_EXPOSURES="$2"
            shift 2
            ;;
        -s|--save-path)
            SAVE_PATH="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [-e exposure-length] [-n num-exposures] [-s save-path]"
            exit 1
            ;;
    esac
done

# Ensure the save directory exists
mkdir -p "$SAVE_PATH"

# Function to handle graceful exit when Ctrl+C is pressed
cleanup() {
    echo "Gracefully shutting down..."
    gphoto2 --exit  # Disconnects the camera from gphoto2
    exit 0
}

# Trap Ctrl+C (SIGINT) and call the cleanup function
trap cleanup SIGINT

# Detect camera and set Bulb mode
gphoto2 --auto-detect
gphoto2 --set-config shutterspeed=61  # Set shutter speed to Bulb

# Add buffer time to ensure we don't time out too early
WAIT_TIME=$((EXPOSURE_TIME + 5))

for ((i=1; i<=NUM_EXPOSURES; i++)); do
    TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
    FILENAME="$SAVE_PATH/image_$TIMESTAMP.arw"

    echo "Starting exposure #$i at $TIMESTAMP"
    
    # Capture and download image
    gphoto2 --capture-image-and-download --wait-event=${WAIT_TIME}s --filename "$FILENAME"
    echo "Exposure #$i completed -> $FILENAME"

    sleep 5  # Short delay between exposures
done

echo "All exposures completed!"
