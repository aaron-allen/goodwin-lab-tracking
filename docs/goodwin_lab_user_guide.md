<!-- TOC START min:1 max:3 link:true asterisk:false update:true -->
- [Usage:](#usage)
    - [Caution:](#caution)
- [Recording Station:](#recording-station)
    - [Preparing the setup:](#preparing-the-setup)
        - [Double Check Camera Settings:](#double-check-camera-settings)
        - [Backlight Intensity:](#backlight-intensity)
    - [Starting a video recording:](#starting-a-video-recording)
        - [Using Strand Camera](#using-strand-camera)
    - [Video Transfer:](#video-transfer)
- [Tracking:](#tracking)
- [Tracking Results:](#tracking-results)
    - [Where are my results?](#where-are-my-results)
        - [FileZilla:](#filezilla)
        - [Map a network drive:](#map-a-network-drive)
    - [Navigating your results:](#navigating-your-results)
        - [Results/my_video_1_ALLDATA_R.csv.gz:](#resultsmy_video_1_alldata_rcsvgz)
        - [Results/my_video_1_Diagnostic_Plots_R.pdf:](#resultsmy_video_1_diagnostic_plots_rpdf)
        - [Results/my_video_1_Ethogram.pdf:](#resultsmy_video_1_ethogrampdf)
        - [Results/my_video_1_Indices.csv:](#resultsmy_video_1_indicescsv)
        - [Other files:](#other-files)
        - [Arena and Fly Numbering:](#arena-and-fly-numbering)
<!-- TOC END -->





# Usage:

This _"user guide"_ is intended to aid the members of the Gooodwin Lab to use this _"pipeline"_ as it is currently deployed. It is not intended as general user guide for any other end user who wishes to use any of this code. But do feel free to use any of this code if you'd like, or if it may be useful to you. We'd only ask that you cite ["Nojima, Rings, et al., 2021"](https://www.sciencedirect.com/science/article/pii/S0960982220318996?via%3Dihub).

The _"pipeline"_ can accommodate our usual 20 arena chambers. You can also adjust the camera to zoom into 5 of the 20 arenas, or a single arena.

Here we show an example still from one of our 20 arena chambers.
![Example Video Still](/docs/images/video_still--20arena_example.png)

## Caution:

When loading your flies into the chambers please follow these instructions:
- Put the same number of flies in each chamber. For example, do not mix a 2-fly and a 3-fly experiment in the same video.
- Ensure at least 5 arenas contain flies. The Caltech Flytracker can run into issues if too many of the arenas are empty in a multi-arena video.
- If you are not using all 20 arenas, place your flies in the top arenas. FlyTracker will not work if the top 10 arenas (as seen in the video) of the 20 arenas are empty.


# Recording Station:

Please ensure that you have reserved your time slot for either Station's A, B, or C on the Goodwin Lab behaviour room Google calendar. You should reserve the station even if you are not using the computer - if you are occupying the space, then no one else is able to use it.

## Preparing the setup:

First, login with the `Recoding` user name.

### Double Check Camera Settings:

It is important to double check the camera settings before you start recording. Different assay require different configurations.


### Backlight Intensity:

It is important that the light intensity is set appropriately in order to get accurate tracking results. The intensity knob on the Falcon light source should be turned to its maximum. Then the aperture of the camera should be adjusted such that the brightest part of the video registers less than 255 (and typically more than 240) and the darkest part of the video registers more than 0 (and typically less than 15). Adjusting the aperture in this way prevents clipping (either the brightest spot stuck on 255 or the darkest spot stuck on 0) and ensures that we will be recording all the data that we can, without washing anything out. We adjust this by the aperture of the camera, and not by the intensity knob of the backlight to ensure maximum [depth of field](https://en.wikipedia.org/wiki/Depth_of_field). If the depth of field is too shallow and someone has inappropriately adjusted the camera such that its sensor is not parallel to the arenas, then not all flies will be in focus and tracking errors may occur.

![Backlight Intensity](/docs/images/video_still--backlight_intensity.png)


## Starting a video recording:

To start a recording session double click the `launch_strand_cam.sh` shell script on the desktop. After launching, you will be prompted to enter your user name. This is the same as it appears in the `videos` directory. This script will automatically generate a new folder named with todays date (`<YYYMMDD>`) in your videos folder. For example, if I (Aaron) ran this script on January 25th 2022, it would create the following folder: `/mnt/local_data/videos/Aaron/20220125/`. Once this folder is created, Strand-Camera will launch. You will then be able to record videos from this web interface. By default the videos will be named `movie<YYYMMDD_hhmmss>.<ext>`.

Once the you are finished recording, you may change the names of these videos if you'd like, but do make sure that the names of the videos match the names in you settings file (see below). And please **do not** use commas in your file names.

### Using Strand Camera

We will now be using Strand Camera software to record our behaviour videos. More information about Strand Camera software is available [here](https://strawlab.org/strand-cam/) from its developers.

For now, we will be recording `.mkv` video files. We may in the future sort how to deal with videos recorded directly to `.ufmf`, but are not for now - currently Caltech FlyTracker does not support reading of Straw Lab `.ufmf` videos.

To close Strand Camera ... - add info

## Video Transfer:

Settings file description:

The settings file is a comma separated values plain text file (*.txt) where the user can specify multiple parameters to ensure their video gets tracked accordingly. These parameters need to be in this exact order and all should be present.
- `user`: your first name, as it appears in the video recording directory.
- `video_name_with_extension`: The name of your video to be tracked.
- `video_type`: The container used for the video (will typically be "mp4", but can also be "mkv", "ufmf", "fmf", "avi", etc).
- `fps`: frames per second of the video.
- `tracking_start_time_in_seconds`: The time (in seconds) that you want tracking to start for your video.
- `flies_per_arena`: The number of flies per arena.
- `sex_ratio`: The proportion of male flies per arena (one male and one female would be 0.5, two males and one female would be 0.67, all females would be 0, etc).
- `number_of_arenas`: How many full arenas are visible in the video (default for courtship is 20, but may also be 1 or 5).
- `arena_shape`: Either "circle" or "rectangle".
- `assay_type`: This will be "courtship" for the most part, but potentially "oviposition" or "phototaxis" as we add support for other behaviours.
- `optogenetics_light`: "true" or "false". Whether the optogenetics indication light was used, and should attempt detection of it.
- `recording_station`: Which station was used. Either A, B, or C. This is only for documentation purposes and to keep track of any issues.

An example line for a settings file:

`Aaron,my_test_video.mp4,mp4,25,13,2,0.5,20,circle,courtship,false,C`

The settings file should only have a line for each video. Do not have an empty line at the start, and do not have an empty line at the end.


# Tracking:

The tracking  _"pipline"_ is scheduled to run every Friday evening to process all videos accumulated through the week. In a low volume week, your results will be available by Monday morning. In a busy week, they may not be ready until the following Wednesday or Thursday of the following week after tracking has started. So, if you record a video on a Monday your results will be ready in 7-10 days, and if you record on a Friday morning your results will be ready in 3-6 days (again, depending on the number of videos that need to be tracked that week).

During this stage, you (the end user) do not need to do anything except wait. Thank you for your patience.


# Tracking Results:

## Where are my results?

Your tracking results will automatically be transferred to the `Tracked` volume on our `VideosUpload` Synology.

To access your data you either need to be attached to a wired internet connection in the CNCB, or connected via the [MSD VPN](https://www.medsci.ox.ac.uk/divisional-services/support-services-1/information-technology/document-and-file-storage/vpn). You will need to use the MSD VPN if you are at home, but will also have to use it if you are connected to eduroam while in the CNCB. Due to addition security required for the MSD, eduroam connections do not have access to the local network in the CNCB.

You can access your data multiple ways. The preferred methods would be to use either [FileZilla](https://filezilla-project.org/) or map a network drive (see below). All methods will require for you to have a user name and password for the Synology's. If you currently don't have any login information (or forget your information), please see Aaron or Annika to sort this out for you.

It should also be noted that these Synology's are not centrally managed, University of Oxford, network drives. These are just a couple of file server computers sitting in the CNCB.


### FileZilla:

[FileZilla](https://filezilla-project.org/) is a free and open source piece of software that allows you to make an `ftp` connection. To make a connection to the Synology, you'll need to enter the following:
* `Host`: the ip address of the Synology, of the form xxx.x.xx.xxx
* `Username`: your username
* `Password`: your password
* `Port`: 22

When making a connection for the first time you will be prompted with ...


There is extension documentation available online for how to use FileZilla; if you have any further questions, please look there first.

### Map a network drive:

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


## Navigating your results:

Once the tracking results are ready, they will be transferred to the `VideosUpload` Synology in a new folder, named for the date that the tracking started, inside your existing folder. Inside this folder (e.g. `Tracted/Aaron/20220125-110453/`) there will be a folder for each video that was tracked for you this week.

The directory structure is as follows for each video:
- my_video_1/
    - Backups/...
    - Logs/...
    - Results/
        - my_video_1_ALLDATA_R.csv.gz
        - my_video_1_Diagnostic_Plots_R.pdf
        - my_video_1_Ethogram.pdf
        - my_video_1_Indices.csv
    - my_video_1/
        - my_video_1_JAABA/...
        - ids.mat
        - my_video_1-bg.mat
        - my_video_1-feat.mat
        - my_video_1-params.mat
        - my_video_1-track.mat
    - my_video_1.mp4
    - calibration.mat

For the most part, you will likely want to focus on the files in the `Results/` folder. This folder contains summary plots and summary statistics of the tracking data. The description of the files within are as follows:



### Results/my_video_1_ALLDATA_R.csv.gz:

A compressed csv file containing all the data extracted from the `my_video_1-track.mat` file, the `my_video_1-feat.mat` file, and data from the `my_video_1/my_video_1_JAABA/scores_*.mat` files, if they exist. This file is used to load the data into R to make the `Results/my_video_1_Diagnostic_Plots_R.pdf` file, the `Results/my_video_1_Ethogram.pdf`, and the `Results/my_video_1_Indices.csv`. This file can be loaded into any other software you like. But beware, it is large - for tracking of 40 flies for 15 minutes at 25 frames per second, this file is ~5GB when uncompressed. The columns of this table is as follows:
- `Frame`: The frame number.
- `Fly_Id`: The Id of the fly.
- `Feature`: The name of the measured feature.
- `Units`: The unit of the measured feature.
- `Value`: The value of the measured feature.
- `Data_Source`: Where the data was extracted from - either "track.mat", "feat.mat", or "jaaba".



### Results/my_video_1_Diagnostic_Plots_R.pdf:

A series of A4 pdf plots showing some of the raw tracking data. This can be used to quickly visually inspect how well the tracking performed. Contains 2 pages per arena that contained flies.

An example of the "Area" diagnostic plot for fly Id 1 and 2 in arena 1.
![Fly Area](/docs/images/diagnostic_plots--area.png)


### Results/my_video_1_Ethogram.pdf:

A series of A4 pdf plots showing the results of the JAABA annotated behaviours for each fly. This file is only generated for courtship assays with 2 flies per arena. There is 1 page per arena with one plot for each fly.

An example of the ethogram plot for a fly can be seen below. This shows the JAABA predictions for the 6 scored courtship behaviours, and copulation. A verticle black line is drawn if JAABA predicted that the fly performed the behaviour for that frame.

![Ethogram](/docs/images/ethogram--example.png)



### Results/my_video_1_Indices.csv:

A csv file containing the computed courtship indices derived from the JAABA annotated behaviour scores. The columns of this table is as follows:
- `FileName`: The name of your video.
- `ArenaNumber`: The arena number, numbered from left to right and top to bottom.
- `FlyId`: The Id of the fly.
- `CI`: Courtship index (excluding the facing behaviour).
- `CIwF`: Courtship index (including the facing behaviour).
- `approaching`: Approaching index.
- `contact`: Contact index.
- `circling`: Circling index.
- `facing`: Facing index.
- `turning`: Turning index.
- `wing`: Wing index.
- `denominator`: The duration of the time window (in seconds) for which these indices were calculated.
- `predicted_sex`: The predicted sex of the flies, as determined by the user supplied proportion of male flies per arena and the relative sizes of the flies per arena.

By default flies need to "initiate courtship" before we will calculate an index. Flies need to perform any of the courtship-like behaviours for at least 3 seconds of a 6 second window (the facing behaviour is not used to assess courtship initiation). These indices are then from the courtship initiation until either 1. the flies copulate, 2. 10 minutes has passed since courtship initiation, or 3. we've reached the end of the tracking data, which ever occurs first.


### Other files:


- `Backups/...`: We make multiple changes to the generated tracking files. Before we make any of our changes, we copy the file that will be modified to this directory.
- `Logs/...`: This folder contains multiple log files and error files that can be useful while diagnosing tracking error.
- `my_video_1/my_video_1_JAABA/...`: This folder contains all of the files needed for performing the JAABA analysis, as well as the `scores_*.mat` results files.
- `my_video_1/ids.mat`: This file is generated while re-assigning identities.
- `my_video_1/my_video_1-bg.mat`: This is the background model used during tracking.
- `my_video_1/my_video_1-feat.mat`: "[F]eatures derived from tracking data (e.g. velocity, distance to wall)"
- `my_video_1/my_video_1-params.mat`: A log of the parameters used while tracking.
- `my_video_1/my_video_1-track.mat`: "[R]aw tracking data (e.g. position, orientation, left wing angle)"

### Arena and Fly Numbering:

An example of the arena numbering can be seen below for one of our 20 arena chambers.

![Arena Numbering](/docs/images/video_still--arena_numbering.png)


An example of the fly numbering can be seen below for one of our 20 arena chambers.

![Fly Numbering](/docs/images/video_still--fly_numbering.png)
