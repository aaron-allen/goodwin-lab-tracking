#!/bin/bash


# Author: Aaron M. Allen
# Date: 2021.12.14

# Description:
# This script launches the Strand Camera application from a users directory. Strand Camera saves videos, by default, to the directory it is
# started from. So we prompt the user for the name and change into a directory of today's date in their video directory before starting
# Strand Camera.



printf "$(date)\n\n"
today=$(date +%Y-%m-%d)


# Check if transfer scipt is running and don't record if it is.
if [[ $(pgrep -fc "start_transfer_script.sh") -gt 0 ]]; then
    printf 'Transfer software is still running ...\n'
    printf 'Please wait until whomever has finished transfering before recording your videos.\n'
    printf 'Close this window and try again later.\n'
    sleep infinity
    return
fi


# Run nvidia-smi (and capture its output) to check to see if the GPU is available
output=$(nvidia-smi)
exit_code=$?

# Check the exit code
if [ $exit_code -eq 0 ]; then
    printf "GPU driver detected.\n"
else
    printf "\n\n\n\n\n\n"
    printf "\e[1;31mERROR! - Can't find the GPU driver!\e[0m\n"
    printf "\t1. Sorry, but you can't record righ now. Please go find Aaron to help sort out this issue.\n\n\n\n"
    sleep infinity
    return
fi



printf "
Good [morning/afternoon/eveing],
This script will start the recording software. Please enter the following information...\n\n
"

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
sleep 3s

today_plus=$(date +%Y%m%d-%H%M%S)
strand-cam-pylon >> \
    "/mnt/data/_logs/recording_logs/${today_plus}_${user_name}_recording.log" 2>&1
