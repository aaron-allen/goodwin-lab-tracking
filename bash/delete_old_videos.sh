#!/bin/bash

# Author: Aaron M. Allen
# Date: 2019.02.26
#    updated: 2021.12.14

# Description:
#
# This script is used to delete old video files in the event that the videos disk gets too full.
# If the disk usage ('CAPACITY') is more than the set limit ('CAPACITY_LIMIT'), then
# the script starts to delete video files. The script finds all '.avi', '.mp4', '.mkv', '.fmf', and '.ufmf' files in the
# /mnt/local_data/videos/ directory and ranks by modification date (oldest to newest). The script then checks to
# see if it is now below the capacity limit; if it is, then the sript stops, otherwise it continues to the next video.



today=$(date)
printf "\n\n\n\n${today}\n"

video_dir=/mnt/local_data/videos
CAPACITY_LIMIT=80
printf "Videos directory = ${video_dir}\n"
printf "CAPACITY_LIMIT = ${CAPACITY_LIMIT}\n"

CAPACITY=$(df -k ${video_dir} | awk '{gsub("%",""); capacity=$5}; END {print capacity}')
printf "CAPACITY = ${CAPACITY}\n"
if [ ${CAPACITY} -gt ${CAPACITY_LIMIT} ]
then
    cd ${video_dir}
    find . -type f -name \*.avi \
                -o -name \*.mp4 \
                -o -name \*.mkv \
                -o -name \*.fmf \
                -o -name \*.ufmf \
                -printf "%T@ %Tc %p\n" | \
        sort -n | \
        cut -f 2- -d '/' > "${video_dir}/list_of_videos_by_date.txt"

    while read line
    do
        printf "removing ${video_dir}/${line}\n"
        rm -f "${video_dir}/${line}"

        printf "removing ${video_dir}/#recycle/${line}\n"
        rm -f "${video_dir}/#recycle/${line}"
        rm -rf "~/.local/share/Trash/files/*.avi"

        sleep 30
        printf "Deleted ${line} in ${video_dir}/\n"
        CAPACITY=$(df -k ${video_dir} | awk '{gsub("%",""); capacity=$5}; END {print capacity}')
        printf "Current capacity is ${CAPACITY}\n"
        if [ ${CAPACITY} -le ${CAPACITY_LIMIT} ]
        then
           # we're below the limit, so stop deleting
           printf "All done.\n"
           exit
        fi
    done < "${video_dir}/list_of_videos_by_date.txt"
fi

exit
