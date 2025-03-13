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

# Ensure the save directory exists
mkdir -p "$SAVE_PATH"

# Detect camera and set Bulb mode
gphoto2 --auto-detect
gphoto2 --set-config-index shutterspeed=61  # Set shutter speed to Bulb

# Add buffer time to ensure we don't time out too early
WAIT_TIME=$((EXPOSURE_TIME + 5))

for ((i=1; i<=NUM_EXPOSURES; i++)); do
    TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
    FILENAME="$SAVE_PATH/image_$TIMESTAMP.arw"

    echo "Starting exposure #$i at $TIMESTAMP"
    
    # Capture and download image
    gphoto2 --capture-image-and-download --wait-event=${WAIT_TIME}s --filename "$FILENAME"; then
    echo "Exposure #$i completed -> $FILENAME"

    sleep 5  # Short delay between exposures
done

echo "All exposures completed!"
