#!/bin/bash


# Author: Aaron M. Allen
# Date: 2021.12.14

# Description:
# This script launches the Strand Camera application from a users directory. Strand Camera saves videos, by default, to the directory it is
# started from. So we prompt the user for the name and change into a directory of today's date in their video directory before starting
# Strand Camera.



printf $(date)
today=$(date +%Y%m%d)

read -p 'Username: ' user_name

user_dir="/mnt/local_data/videos/${user_name}"



if [[ -d "${user_dir}" ]]; then
    printf "Found your video directory."
    mkdir "${user_dir}/${today}"
    cd "${user_dir}/${today}"
else
    printf "Can't find your video directory."
    printf "\nRecording your video in orphan_videos folder."
    printf "Strand Camera will start shortly."
    sleep 15s
    cd "/mnt/local_data/videos/orphan_videos"
fi

strand-cam-pylon &

printf "Don't close this window until you are all finished recording."
