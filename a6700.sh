#!/bin/bash

############################################################################################
# On the Sony A6700, set the bulb timer from the camera settings                         ###
# Menu -> Exposure -> Bulb timer. Set to On and Exposure time to the desired length      ###
############################################################################################

############################################################################################
# Usage:                                                                                 ###
# This script automates long exposure photography using a Sony A6700 camera.             ###
# It uses gphoto2 to capture multiple long exposures and download the images to the      ###
# specified save path.                                                                   ###
#                                                                                        ###
# Arguments:                                                                             ###
#   -e, --exposure-length   [DEPRECATED, DO NOT USE]                                     ###
#   -n, --num-exposures     Set the number of exposures to take (default: 5)             ###
#   -s, --save-path         Specify the directory to save the images (default: ~/a6700)  ###
#   -i, --iso               Specify the ISO for the captures (default: 800)              ###
#                                                                                        ###
# Example usage:                                                                         ###
#   ./a6700.sh -e 60 -n 10 -s ~/photos                                                   ###
#   This will take 10 exposures, each lasting 60 seconds, and save them in the           ###
#   ~/photos directory.                                                                  ###
############################################################################################

# Default values. Change them if you want to run the script without any arguments and 
# still get your desired outcome
NUM_EXPOSURES=9999
EXPOSURE_TIME=120  # A6700 quirk. Set this to match the bulb timer setting in the camera
SAVE_PATH="$HOME/a6700"
CAMERA_ISO=800

############################################################################################
# Do not change anything below this line unless you know what you're doing               ###
############################################################################################

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
        -i|--iso)
            CAMERA_ISO="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [-n num-exposures] [-s save-path] [-i iso]"
            exit 1
            ;;
    esac
done

# Ensure the save directory exists
mkdir -p "$SAVE_PATH"

# Function to handle graceful exit when Ctrl+C is pressed
cleanup() {
    echo "Gracefully shutting down..."
    gphoto2 --reset
    echo "Available cameras: "
    gphoto2 --auto-detect
    exit 0
}

# Trap Ctrl+C (SIGINT) and call the cleanup function
trap cleanup SIGINT

get_battery_level() {
    BATTERY_LEVEL_OUTPUT=$(gphoto2 --get-config batterylevel)
    BATTERY_PERCENTAGE=$(echo "$BATTERY_LEVEL_OUTPUT" | grep -oP 'Current: \K[0-9]+%')
    echo "Battery: $BATTERY_PERCENTAGE"
}

# Detect camera and set Bulb mode
gphoto2 --auto-detect
gphoto2 --set-config shutterspeed=61  # Set shutter speed to Bulb
gphoto2 --set-config iso="$CAMERA_ISO"

# Add buffer time to ensure we don't time out too early
WAIT_TIME=$((EXPOSURE_TIME + 5))

echo " "
echo "#####################################################################################"
echo " "
echo "MAKE SURE TO SET THE BULB EXPOSURE TIME ON THE CAMERA TO THE DESIRED EXPOSURE LENGTH"
echo " "
echo "#####################################################################################"
echo " "

for ((i=1; i<=NUM_EXPOSURES; i++)); do
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    FILENAME="$SAVE_PATH/image_$TIMESTAMP.arw"

    echo "Starting exposure #$i at $TIMESTAMP"
    
    # Capture and download image; Disregard spammy messages in the output.
    gphoto2 --capture-image-and-download --wait-event-and-download=CAPTURECOMPLETE --filename "$FILENAME" 2>&1 | grep -v "UNKNOWN PTP Property 00000000 changed"

    # OLDER VERSIONS OF THE gphoto2 LINE
    # gphoto2 --capture-image-and-download --wait-event=${WAIT_TIME}s --filename "$FILENAME" 2>&1 | grep -v "UNKNOWN PTP Property 00000000 changed"
    
    # With debug
    #gphoto2 --capture-image-and-download --wait-event=${WAIT_TIME}s --filename "$FILENAME" 2>&1 | tee -a "$SAVE_PATH/gphoto2_debug.log" | grep -v "UNKNOWN PTP Property 00000000 changed"

    # Slightly better version
    # gphoto2 --capture-image-and-download --wait-event=CAPTURECOMPLETE --filename "$FILENAME" 2>&1 | tee -a "$SAVE_PATH/gphoto2_debug.log" | grep -v "UNKNOWN PTP Property 00000000 changed"

    

    echo "Exposure #$i completed -> $FILENAME"

    get_battery_level
    sleep 5  # Short delay between exposures
done

echo "All exposures completed!"
