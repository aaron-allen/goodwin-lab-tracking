#!/bin/bash


# Author: Aaron M. Allen
# Date: 2021.12.14

# Description:
# This script launches the Strand Camera application from a users directory. Strand Camera saves videos, by default, to the directory it is
# started from. So we prompt the user for the name and change into a directory of today's date in their video directory before starting
# Strand Camera.



printf "$(date)\n\n"
today=$(date +%Y-%m-%d)

read -p 'Username: ' user_name

user_dir="/mnt/data/videos/${user_name}"



if [[ -d "${user_dir}" ]]; then
    printf "Found your video directory.\n"
    if [[ ! -d "${user_dir}/${today}" ]]; then
        mkdir "${user_dir}/${today}"
    fi
    cd "${user_dir}/${today}"
else
    printf "Can't find your video directory.\n"
    printf "\nRecording your video in orphan_videos folder.\n"
    cd "/mnt/data/videos/_orphan_videos"
fi

printf "Strand Camera will start shortly.\n"
printf "\nDon't close this window until you are all finished recording ...\n"
sleep 5s

today_plus=$(date +%Y%m%d-%H%M%S)
strand-cam-pylon >> \
    "/mnt/data/_logs/recording_logs/${today_plus}_${user_name}_recording.log" 2>&1
