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

## How to customize the exposures
To change the default exposure time and the number of exposures, open the script with your favourite text editor and change the values for `NUM_EXPOSURES` and `EXPOSURE TIME`.  
If you want to change the default save location, then also change the path specified in the `SAVE_PATH` variable.
