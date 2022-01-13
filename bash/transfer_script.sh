#!/bin/bash


# Author: Aaron M. Allen
# Date: 2021.12.14

# Description:
# This script transfers the users videos to the Synologys for tracking.



printf "$(date)\n\n"
today=$(date +%Y-%m-%d)

user_name="${1}"
vid_dir="${2}"
settings_file="${3}"

printf "Username = ${user_name}\n"
printf "Recording directory = ${vid_dir}\n"
printf "Settings file = ${settings_file}\n\n\n"

user_dir="/mnt/local_data/videos/${user_name}"
full_path="/mnt/local_data/videos/${user_name}/${vid_dir}"

# Check if the supplied local user directory exists
if [[ -d "${full_path}" ]]; then
    if [[ -f "/mnt/synology/tobetracked/mount_test.txt" ]]; then
        printf "Remote Synology is moutned. We will now start copying the videos...\n\n"
        for file in "$arg"/*.{avi,mp4,mkv,fmf,ufmf} ; do

            # # --------------------------------------------------------------------------------------------------------------------------------------------------------------
            # ### need to convert Strand-Camera mkv files to constant frame rate videos

            # test_fps=$(ffprobe -v quiet -print_format json -show_streams "${file}" | grep avg_frame_rate)
            # if [[ ${test_fps} != *"0/0"* ]]; then
            #     echo "vfr";
            # else
            #     if [[ ${test_fps} != *"/1"* ]]; then
            #         echo "cfr";
            #     fi
            # fi



            # if [[ ${video_type} == "mkv" ]]; then
            #     my_bitrate=4M
            #     n_cores=nproc --all
            #     ffmpeg \
            #         -hide_banner \
            #         -i "${OutputDirectory}/${FileName}/"${video_name}" \
            #         -filter:v fps=25 \
            #         -c:v libx264 \
            #         #-x264-params "nal-hrd=cbr" \
            #         #-b:v ${my_bitrate} \
            #         #-minrate ${my_bitrate} \
            #         #-maxrate ${my_bitrate} \
            #         #-bufsize ${my_bitrate} \
            #         -crf 18 \
            #         -preset fast \
            #         -threads ${n_cores} \
            #         -y \
            #         "${OutputDirectory}/${FileName}/"${video_name}"
            # fi
            # # --------------------------------------------------------------------------------------------------------------------------------------------------------------

            printf "\tCopying ${file} ...\n"
            cp "${file}" "/mnt/Synology/ToBeTracked/VideosFromStaions/videos/"
            local_size=wc -c "${file}" | awk '{print $1}'
            remote_size=wc -c "/mnt/Synology/ToBeTracked/VideosFromStaions/videos/${file}" | awk '{print $1}'
            printf "\tLocal file size = ${local_size}\n"
            printf "\tRemote file size = ${remote_size}\n"
            if [[ ${local_size} == ${remote_size} ]]; then
                printf "\tLocal and remote file sizes are equal. Copying was succesfull.\n"
            else
                printf "\tLocal and remote file sizes are NOT equal. Something has gone wrong ...\n"
            fi
            printf "\n\n"
        done
        cat "${full_path}/${settings_file}" >> "/mnt/Synology/ToBeTracked/VideosFromStaions/video_list.csv"
    else
        printf "The Synology is not mounted.\n...\n\t... go find Aaron ...\n\n"
        sleep infinity
    fi
else
    printf "\nStill can't find your local recording folder ...\n"
    printf "Probably best to find Aaron or Annika ...\n\n"
    sleep infinity
fi
