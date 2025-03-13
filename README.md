# How to use this script
1. Install gphoto2.
    - The easy way is to use your package manager to do it. For example `sudo apt-get install gphoto2`.  
    - The other way is to compile it from source using the very good guide available on the [gphoto2 repo's readme](https://github.com/gphoto/gphoto2).  
1. Set the bulb exposure time **on the camera (A6700 quirk)**
    - Menu -> Exposure -> Bulb timer. Set to On and set Exposure Time to the desired length.
1. Clone this repo and run the script
    - `git clone https://github.com/dariusmihai/gphoto2-sony-a6700-long-exposure`
    - `cd gphoto2-sony-a6700-long-exposure`
    - `chmod +x a6700.sh`
    - `./a6700.sh`

Step 3 will trigger 9999 exposures. The length of each exposure is determined by the camera. **Menu -> Exposure -> Bulb timer**. Set to On and Exposure time to the desired length.

You can also do:  
`./a6700.sh -n 5 -s ~/photos` to trigger:
- 5 exposures
- all saved to ~/photos  

## Camera setup
Set the camera to photo mode.  
Set the mode to Manual.  
Set the shutter speed to Bulb.
In the camera menu, go to Camera Settings -> Exposure/Color -> Exposure -> Bulb Timer Settings
Set the Bulb Timer to on and Exposure to 120s or any length you want.

## How to customize the exposures
To change the the number of exposures, open the script with your favourite text editor and change the values for the variables in the "Default Values" section at the beginning of the script.   
Make sure to also **change the Exposure on-camera** under **Camera Settings -> Exposure/Color -> Exposure -> Bulb Timer Settings**.  

If you want to change the default save location, then also change the path specified in the `SAVE_PATH` variable.

## Compatibility  
This script can be used on:
- Linux computers that can run gphoto2.
- Raspberry Pi. Tested on Pi 5.

# Why this exists
The Sony A6700 is a bit weird when it comes to doing long exposures (bulb) remotely.
Sometimes you just want to set up your camera and let it do multiple long exposures in a row. For example for timelapses or astrophotography.  

Unfortunately most cameras only allow exposures up to 30 seconds, especially in interval shooting. The Sony A6700 does have an internal bulb timer
 that lets you go up to 999 seconds for the shutter speed, but that only works in single-exposure mode, not in interval shooting.  
 
To top it all up, The Sony A6700 doesn't even have a port for an external intervalometer.  
But wait, the quirks don't stop here with this camera. Repeated long exposures don't even work from the official mobile apps: Imaging Edge Mobile and Sony Creator's App.   

The only one that somewhat works, but very unreliable, is Sony Imaging Edge Desktop. This runs on windows machines and it does work sometimes. The problem is that it randomly disconnect after 3 exposures, 5 exposures or 20 exposures.

## The solution

[Gphoto2](https://github.com/gphoto/gphoto2) is a great tool for this. Unfortunately the Sony A6700 has some quirks that doesn't let gphoto2 do its thing.
For more info on the quirks, see the feature request that I posted on the gphoto2 repo: [Issue link](https://github.com/gphoto/gphoto2/issues/678)  

To resolve the issues described above, I wrote this wrapper script that uses gphoto2 in a way that the A6700 supports.

## The future
Hopefully this A6700 quirk can be addressed within gphoto2, at which point this script will no longer be necessary.
