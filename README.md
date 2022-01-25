<!-- TOC START min:1 max:3 link:true asterisk:false update:true -->
- [Goodwin-Lab-Tracking](#goodwin-lab-tracking)
- [Usage:](#usage)
- [**UNDER CONSTRUCTION**](#under-construction)
- [Dependencies:](#dependencies)
- [Previous _"version"_](#previous-_version_)
<!-- TOC END -->






# Goodwin-Lab-Tracking

_"Pipeline"_ (I use the term very loosely...) for processing and tracking courtship videos. This repository contains custom scripts for file handling and processing of our behaviour video data. To record our behaviour videos we us [Strand Camera](https://strawlab.org/strand-cam/). We then use the [Caltech FlyTracker](http://www.vision.caltech.edu/Tools/FlyTracker/) to track our videos and [Janelia Automatic Animal Behavio(u)r Annotator (JAABA)](http://jaaba.sourceforge.net/) to annotate courtship behaviour.

# Usage:

For a user guide for members of the Goodwin Lab, please refer to the [user guide](docs/goodwin_lab_user_guide.md) found in the [docs folder](docs/)



# **UNDER CONSTRUCTION**

I would not advise trying to use any of this at the moment ...




# Dependencies:

So far this has only been used/tested on Ubuntu 20.04.


MATLAB 2018b (we haven't tested any other versions yet)
- [Kristin Branson's modified Caltech FlyTracker](https://github.com/kristinbranson/FlyTracker)
    - I've also made some modifications for improved mp4 video tracking and playback available [here](https://github.com/aaron-allen/FlyTracker/tree/mp4_playback)
    - the original Caltech FlyTracker website, with user guides and other info, can be found [here](http://www.vision.caltech.edu/Tools/FlyTracker/)
- [JAABA](https://github.com/kristinbranson/JAABA)
    - we also need to update the `JAABA/perframe/params/featureConfigEyrun.xml` file
    - `featureConfigEyrun.xml` file compatible with 2-Fly FlyTracker data can be downloaded from [here](http://www.vision.caltech.edu/Tools/FlyTracker/FAQ.html)
    - I have forked a copy of JAABA and updated this file [here](https://github.com/aaron-allen/JAABA/tree/goodwinlab)


R 3.5.3 (we haven't tested any other versions yet)
* tidyverse vX.X.X
* data.table vX.X.X
* cowplot vX.X.X
* zoo vX.X.X



# Previous _"version"_

For scipts used in ["Nojima, Rings, et al., 2021, A sex-specific switch between visual and olfactory inputs underlies adaptive sex differences in behavior"](https://www.sciencedirect.com/science/article/pii/S0960982220318996?via%3Dihub), please refer to the `aDN` branch.
