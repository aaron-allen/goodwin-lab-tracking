# Goodwin-Lab-Tracking

"Pipeline" (I use the the term very loosely...) for processing and tracking courtship videos



# **UNDER CONSTRUCTION**

I would not advise trying to use any of this at the moment ...




# Dependencies:

So far this has only been used/tested on Ubuntu 16.04.


MATLAB 2018b (we haven't tested any other versions yet)
* [Kristin Branson's modified Caltech FlyTracker](https://github.com/kristinbranson/FlyTracker)
* [JAABA](https://github.com/kristinbranson/JAABA)


R 3.5.3 (we haven't tested any other versions yet)
* tidyverse vX.X.X
* data.table vX.X.X
* cowplot vX.X.X
* zoo vX.X.X


# Usage:

## Recoding Station:

### Video Transfer:

Settings file description:

The settings file is a comma separated values plain text file (*.txt) where the user can specify multiple parameters to ensure their video gets tracked accordingly. These parameters need to be in this exact order and all should be present.
* `user`: your first name, as it appears in the video recording directory.
* `video_name_with_extension`: The name of your video to be tracked.
* `video_type`: The container used for the video (will typically be "mkv" or "ufmf", but can also be "mp4", "avi", "fmf", etc).
* `tracking_start_time_in_seconds`: The time (in seconds) that you want tracking to start for your video.
* `flies_per_arena`: The number of flies per arena.
* `sex_ratio`: The proportion of male flies per arena (one male and one female would be 0.5, two males and one female would be 0.67, all females would be 0).
* `number_of_arenas`: How many full arenas are visible in the video (default for courtship is 20, but may also be 1 or 5).
* `arena_shape`: Either "circle" or "rectangle".
* `assay_type`: This will be "courtship" for the most part, but potentially "oviposition" or "phototaxis" as we and support for other behaviours.
* `optogenetics_light`: "true" or "false". Whether the optogenetics indication light was used, and should attempt detection of it.
* `recording_station`: Which station was used. Either A, B, or C. This is only for documentation purposes and to keep track of any issues.

An example line for a settings file:
`Aaron,my_test_video.mkv,mkv,13,2,0.5,20,circle,courtship,false,C`

# Previous "version"

For scipts used in ["Nojima, Rings, et al., 2021, A sex-specific switch between visual and olfactory inputs underlies adaptive sex differences in behavior"](https://www.sciencedirect.com/science/article/pii/S0960982220318996?via%3Dihub), please refer to the `aDN` branch.
