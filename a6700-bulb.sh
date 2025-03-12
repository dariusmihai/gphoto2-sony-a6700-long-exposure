#!/bin/bash
 
# On Sony A6700, set the bulb timer from the camera settings
# Menu -> Exposure -> Bulb timer. Set to On and Exposure time to the desired length
 
# Change the following values according to what you're trying to achieve
NUM_EXPOSURES=5
EXPOSURE_TIME=120
SAVE_PATH="$HOME/a6700"
 
 
# Do not change anything below unless you know what you're doing
 
gphoto2 --auto-detect
gphoto2 --set-config shutterspeed=61 # This sets shutter speed to Bulb
 
WAIT_TIME=$((EXPOSURE_TIME + 2))
 
for((i=1; i<=NUM_EXPOSURES; i++))
do
    #gphoto2 --capture-image
    TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
    FILENAME="$SAVE_PATH/image_$TIMESTAMP.arw"
    echo "Starting exposure #$i"
    gphoto2 --capture-image-and-download --wait-event=${WAIT_TIME}s --filename "$FILENAME"
    echo "Exposure #$i completed -> $FILENAME"
    sleep 5 # Take a break
done
 
echo "All exposures completed!"
