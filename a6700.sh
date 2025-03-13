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
#   -e, --exposure-length   [NON-FUNCTIONAL on A6700]  See comment at the top            ###
#   -n, --num-exposures     Set the number of exposures to take (default: 5)             ###
#   -s, --save-path         Specify the directory to save the images (default: ~/a6700)  ###
#   -i, --iso               Specify the ISO for the captures (default: 800)              ###
#                                                                                        ###
# Example usage:                                                                         ###
#   ./a6700.sh -n 10 -i 800 -s ~/photos                                                  ###
#   This will take 10 exposures, and save them in the  ~/photos directory.               ### 
#   The length of each exposure is determined by the camera, and can be set in:          ###
#       Menu -> Exposure -> Bulb timer. Set to On and Exposure time to the desired length  #
############################################################################################

###############################
# Default values.           ### 
###############################
# Change them if you want to run the script without any arguments and still get your desired outcome
NUM_EXPOSURES=9999
CAMERA_ISO=800
SAVE_PATH="$HOME/a6700"

# [NON-FUNCTIONAL] EXPOSURE_TIME=120  # A6700 quirk.

############################################################################################
# Do not change anything below this line unless you know what you're doing               ###
############################################################################################

# Start time for elapsed time calculation
START_TIME=$(date +%s)

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--num-exposures)
            NUM_EXPOSURES="$2"
            shift 2
            ;;
        -i|--iso)
            CAMERA_ISO="$2"
            shift 2
            ;;
        -s|--save-path)
            SAVE_PATH="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [-n num-exposures] [-i iso] [-s save-path]"
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

check_camera_connection() {
    local retries="$1"  # The number of retries passed to the function
    local silent="$2"   # If "silent" is passed, suppress output
    local attempt=1

    # Check camera connection
    while [ $attempt -le $retries ]; do
        # Check for camera connection with or without output based on silent mode
        if gphoto2 --auto-detect | grep -q "Sony"; then
            if [ "$silent" != "silent" ]; then
                echo "✅ Camera is connected."
            elif [ $attempt -gt 1 ]; then
                echo "✅ Camera reconnected."
            fi
            return 0  # Camera detected, exit with success
        else
            if [ "$silent" != "silent" ]; then
                echo "⚠️  ERROR: No camera found (Attempt $attempt/$retries). Retrying in 5 seconds..."
            fi
        fi

        # Increment attempt counter and wait before retrying
        attempt=$((attempt + 1))
        sleep 5  # Wait before retrying
    done

    # If no camera found after all retries
    echo "❌ ERROR: No camera detected after multiple attempts."
    return 1  # Camera not detected after retries
}

# Function to initialize camera settings
camera_init() {
    echo "Initializing camera settings..."

    # Set shutter speed to Bulb. 61 is the correct setting for bulb on the Sony A6700
    if ! gphoto2 --set-config shutterspeed=61; then
        echo "⚠️  ERROR: Failed to set shutter speed."
        return 1
    fi
    
    if ! gphoto2 --set-config iso="$CAMERA_ISO"; then
        echo "⚠️  ERROR: Failed to set ISO."
        return 1
    fi

    echo "✅ Camera initialized successfully!"
    return 0
}

get_battery_level() {
    BATTERY_LEVEL_OUTPUT=$(gphoto2 --get-config batterylevel)
    BATTERY_PERCENTAGE=$(echo "$BATTERY_LEVEL_OUTPUT" | grep -oP 'Current: \K[0-9]+%')
    echo "🔋 Battery: $BATTERY_PERCENTAGE"
}

get_elapsed_time() {
    CURRENT_TIME=$(date +%s)
    ELAPSED_SECONDS=$((CURRENT_TIME - START_TIME))
    ELAPSED_HOURS=$((ELAPSED_SECONDS / 3600))
    ELAPSED_MINUTES=$(((ELAPSED_SECONDS % 3600) / 60))
    ELAPSED_SECONDS=$((ELAPSED_SECONDS % 60))
    printf "⏳Elapsed Time: %02d:%02d:%02d\n" "$ELAPSED_HOURS" "$ELAPSED_MINUTES" "$ELAPSED_SECONDS"
}

get_exposure_stats() {
    EXPOSURE_START_TIME=$1
    CURRENT_ITERATION=$2
    CURRENT_TIME=$(date +%s)
    EXPOSURE_DURATION=$((CURRENT_TIME - EXPOSURE_START_TIME))
    AVERAGE_EXPOSURE_TIME=$(((CURRENT_TIME - START_TIME) / CURRENT_ITERATION))
    printf "⌚ Current Exposure Time: %02d seconds\n" "$EXPOSURE_DURATION"
    printf "⌚ Average Time per Exposure: %02d seconds\n" "$AVERAGE_EXPOSURE_TIME"
}

# Function to capture an image with retry logic
capture_image() {
    local retries=3  # Number of retries if an error occurs
    local wait_time=10  # Wait time between retries (seconds)
    local exposure_number="$1"
    local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    local filename="$SAVE_PATH/image_$timestamp.arw"

    # Retry the exposure capture up to the number of retries
    for ((attempt=1; attempt<=retries; attempt++)); do
        echo " "
        echo "------------------------------------------------------------------------"
        echo "📸 Starting exposure #$exposure_number (Attempt $attempt/$retries)..."

        # Check camera connection before each capture
        check_camera_connection 9999 "silent"
        
        # If the camera is not detected, handle it and exit after retries
        if [ $? -eq 1 ]; then
            echo "❌ Camera check failed after retries. Exiting."
            exit 1  # Exit after failed connection retries
        fi

        # Capture and download image; Disregard spammy messages in the output.
        if gphoto2 --capture-image-and-download --wait-event-and-download=CAPTURECOMPLETE --filename "$filename" 2>&1 | grep -v "UNKNOWN PTP Property 00000000 changed"; then
            echo "✅ Exposure #$exposure_number completed -> $filename"
            get_battery_level
            get_elapsed_time
            get_exposure_stats "$EXPOSURE_START_TIME" "$exposure_number"
            return 0  # Success
        else
            echo "⚠️  ERROR: Failed to capture image. Checking camera connection..."

            # Check the camera connection only if there's an issue with capturing the image
            check_camera_connection 9999 || { echo "❌ Camera check failed after retries. Exiting."; exit 1; }

            echo "🔄 Reinitializing camera..."
            # Reinitialize camera settings after failure
            camera_init || { echo "❌ Camera reinitialization failed. Exiting."; exit 1; }
            sleep $wait_time
        fi
    done

    echo "❌ ERROR: Capture failed after multiple attempts. Exiting."
    exit 1
}

# Detect camera and set Bulb mode
check_camera_connection 5 || { echo "❌ Camera not found after multiple attempts. Exiting."; exit 1; } 
camera_init || { echo "❌ Camera initialization failed. Exiting."; exit 1; }

# Add buffer time to ensure we don't time out too early
# [DEPRECATED] WAIT_TIME=$((EXPOSURE_TIME + 5))

echo " "
echo "#####################################################################################"
echo " "
echo "MAKE SURE TO SET THE BULB EXPOSURE TIME ON THE CAMERA TO THE DESIRED EXPOSURE LENGTH"
echo " "
echo "#####################################################################################"
echo " "

for ((i=1; i<=NUM_EXPOSURES; i++)); do
    if ! capture_image "$i"; then
        echo "⚠️ Skipping exposure #$i due to repeated errors."
    fi
    sleep 3  # Short delay between exposures
done

echo "✅ All exposures completed!"
