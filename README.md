# Goodwin-Lab-Tracking

"Pipeline" (I use the the term very loosely...) for processing and tracking courtship videos



# **UNDER CONSTRUCTION**

I would not advise trying to use any of this at the moment ...




# Dependencies:

So far this has only been used/tested on Ubuntu 20.04.


MATLAB 2018b (we haven't tested any other versions yet)
* [Kristin Branson's modified Caltech FlyTracker](https://github.com/kristinbranson/FlyTracker)
* [JAABA](https://github.com/kristinbranson/JAABA)


R 3.5.3 (we haven't tested any other versions yet)
* tidyverse vX.X.X
* data.table vX.X.X
* cowplot vX.X.X
* zoo vX.X.X


# Usage:

This _"user guide"_ is intended to aid the members of the Gooodwin Lab to use this _"pipline"_ as it is currently deployed. It is not intended as general user guide for any other end user who wishes to use any of this code. But do feel free to use any of this code if you'd like, or if it may be useful to you. We'd only ask that you cite ["Nojima, Rings, et al., 2021"](https://www.sciencedirect.com/science/article/pii/S0960982220318996?via%3Dihub).


## Recoding Station:

### Starting a video recording:

### Video Transfer:

Settings file description:

The settings file is a comma separated values plain text file (*.txt) where the user can specify multiple parameters to ensure their video gets tracked accordingly. These parameters need to be in this exact order and all should be present.
* `user`: your first name, as it appears in the video recording directory.
* `video_name_with_extension`: The name of your video to be tracked.
* `video_type`: The container used for the video (will typically be "mkv" or "ufmf", but can also be "mp4", "avi", "fmf", etc).
* `tracking_start_time_in_seconds`: The time (in seconds) that you want tracking to start for your video.
* `flies_per_arena`: The number of flies per arena.
* `sex_ratio`: The proportion of male flies per arena (one male and one female would be 0.5, two males and one female would be 0.67, all females would be 0, etc).
* `number_of_arenas`: How many full arenas are visible in the video (default for courtship is 20, but may also be 1 or 5).
* `arena_shape`: Either "circle" or "rectangle".
* `assay_type`: This will be "courtship" for the most part, but potentially "oviposition" or "phototaxis" as we add support for other behaviours.
* `optogenetics_light`: "true" or "false". Whether the optogenetics indication light was used, and should attempt detection of it.
* `recording_station`: Which station was used. Either A, B, or C. This is only for documentation purposes and to keep track of any issues.

An example line for a settings file:

`Aaron,my_test_video.mkv,mkv,13,2,0.5,20,circle,courtship,false,C`


## Tracking

The tracking  _"pipline"_ is scheduled to run every Friday evening to process all videos accumulated through the week. In a low volume week, your results will be available by Monday morning. In a busy week, they may not be ready until the following Wednesday or Thursday of the following week after tracking has started. So, if you record a video on a Monday your results will be ready in 7-10 days, and if you record on a Friday morning your results will be ready in 3-6 days (again, depending on the number of videos that need to be tracked that week).

During this stage, you (the end user) do not need to do anything except wait. Thank you for your patience.

### Where are my results?

Your tracking results will automatically be transferred to the `Tracked` volume on our `VideosUpload` Synology.

To access your data you either need to be attached to a wired internet connection in the CNCB, or connected via the [MSD VPN](https://www.medsci.ox.ac.uk/divisional-services/support-services-1/information-technology/document-and-file-storage/vpn). You will need to use the MSD VPN if you are at home, but will also have to use it if you are connected to eduroam while in the CNCB. Due to addition security required for the MSD, eduroam connections do not have access to the local network in the CNCB.

You can access your data multiple ways. The preferred methods would be to use either [FileZilla](https://filezilla-project.org/) or map a network drive (see below). All methods will require for you to have a user name and password for the Synology's. If you currently don't have any login information (or forget your information), please see Aaron or Annika to sort this out for you.

It should also be noted that these Synology's are not centrally managed, University of Oxford, network drives. These are just a couple of file server computers sitting in the CNCB.


#### FileZilla:

[FileZilla](https://filezilla-project.org/) is a free and open source piece of software that allows you to make an `ftp` connection. To make a connection to the Synology, you'll need to enter the following:
* `Host`: the ip address of the Synology, of the form xxx.x.xx.xxx
* `Username`: your username
* `Password`: your password
* `Port`: 22

When making a connection for the first time you will be prompted with ...


There is extension documentation available online for how to use FileZilla; if you have any further questions, please look there first.

#### Map a network drive:

By using "Map a network drive" or "Connect to Server", you will be able to view and access the contents of the Synology from "Finder" or "File Explorer".


macOS - here are a few links that may help:
* [link1](https://support.apple.com/en-mt/guide/mac-help/mchlp1140/mac)
* [link2](https://setapp.com/how-to/map-a-network-drive-on-mac)
* [link3](https://www.lifewire.com/how-to-map-network-drive-mac-4707917)

Windows - here are a few links that may help:
* [link1](https://support.microsoft.com/en-us/windows/map-a-network-drive-in-windows-10-29ce55d1-34e3-a7e2-4801-131475f9557d)
* [link2](https://www.dummies.com/article/technology/information-technology/networking/general-networking/mapping-network-drives-164954)
* [link3](https://www.howtogeek.com/762111/how-to-map-a-network-drive-on-windows-10/)







If any of the links are either not working or maybe not the most up to date, feel free to use this handy [tool](https://www.google.co.uk/).


### Navigating your results:



# Previous "version"

For scipts used in ["Nojima, Rings, et al., 2021, A sex-specific switch between visual and olfactory inputs underlies adaptive sex differences in behavior"](https://www.sciencedirect.com/science/article/pii/S0960982220318996?via%3Dihub), please refer to the `aDN` branch.
