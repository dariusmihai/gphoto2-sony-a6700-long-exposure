# Why this exists
The Sony A6700 is a bit weird when it comes to doing long exposures (bulb) remotely.
Sometimes you just want to set up your camera and let it do multiple long exposures in a row. For example for timelapses or astrophotography.


[Gphoto2](https://github.com/gphoto/gphoto2) is a great tool for this. Unfortunately the Sony A6700 has some quirks that doesn't let gphoto2 do its thing.
For more info on the quirks, see the feature request that I posted on the gphoto2 repo: [Issue link](https://github.com/gphoto/gphoto2/issues/678)


## How to use this script
First you have to install gphoto2 of course. 

The easy way is to use your package manager to do it. For example `sudo apt-get install gphoto2`.  
The other way is to compile it from source using the very good guide available on the [gphoto2 repo's readme](https://github.com/gphoto/gphoto2).  


Then do the following:
`git clone https://github.com/dariusmihai/gphoto2-sony-a6700-long-exposure`
`cd gphoto2-sony-a6700-long-exposure`
`chmod +x a6700-bulb.sh`
`./a6700-bulb.sh`

This will trigger 5 exposures of 120 seconds each.  

## Setup your camera
Set the camera to photo mode.  
Set the mode to Manual.  
Set the shutter speed to Bulb.
In the camera menu, go to Camera Settings -> Exposure/Color -> Exposure -> Bulb Timer Settings
Set the Bulb Timer to on and Exposure to 120s

## How to customize the exposures
To change the default exposure time and the number of exposures, open the script with your favourite text editor and change the values for `NUM_EXPOSURES` and `EXPOSURE TIME`.  
Make sure to also change the Exposure to the new value on-camera under Camera Settings -> Exposure/Color -> Exposure -> Bulb Timer Settings.  

If you want to change the default save location, then also change the path specified in the `SAVE_PATH` variable.

## The future
Hopefully this A6700 quirk can be addressed within gphoto2, at which point this script will no longer be necessary.
