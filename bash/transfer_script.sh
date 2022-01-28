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

tobetracked_vid_dir="/mnt/Synology/ToBeTracked/VideosFromStaions/videos"
tobetracked_list_file="/mnt/Synology/ToBeTracked/VideosFromStaions/list_of_videos.csv"

tracking_duration=15    # in minutes
ff_t_stop=$(( ${tracking_duration} * 60 ))   # convert to seconds for ffmpeg


# Define the transfer function
function transfer_function(video in_dir to_dir) {
    mkdir -p "${to_dir}/"
    printf "\tCopying ${video} ...\n"
    cp "${in_dir}/${video}" "${to_dir}/"
    local_size=wc -c "${in_dir}/${video}" | awk '{print $1}'
    remote_size=wc -c "${to_dir}/${video}" | awk '{print $1}'
    printf "\tLocal file size = ${local_size}\n"
    printf "\tRemote file size = ${remote_size}\n"
    if [[ ${local_size} == ${remote_size} ]]; then
        printf "\tLocal and remote file sizes are equal. Copying was succesfull.\n"
    else
        printf "\tLocal and remote file sizes are NOT equal. Something has gone wrong ...\n"
    fi
    printf "\n\n"
}




# Check if the supplied local user directory exists
if [[ -d "${full_path}" ]]; then
    # first, copy a version to the archive directory
    # second, copy a version to the users directory on GoodwinGroup
    if [[ -f "/mnt/Synology/Archive/mount_test.txt" ]] && \
        [[ -f "/mnt/Synology/GoodwinGroup/mount_test.txt" ]]; then

        printf "Backup Synologys are moutned.\n"
        printf "\tWe will now start copying the original videos ...\n\n"
        for file in "$arg"/*.{avi,mp4,mkv,fmf,ufmf} ; do
            if [[ ! -f "${full_path}/${file}" ]]; then
                printf "\tCan't find the video "${file}", so skipping it ...\n"
                continue
            fi
            transfer_function "${file}" "${full_path}" "/mnt/Synology/Archive/FromStations/${user_name}/${vid_dir}"
            transfer_function "${file}" "${full_path}" "/mnt/Synology/GoodwinGroup/${user_name}/BehaviourVideos/${vid_dir}"
        done
    else
        printf "The Synology is not mounted.\n...\n\t... go find Aaron ...\n\n"
        sleep infinity
    fi

    # third and last, transfer videos in settings files to ToBeTracked directory
    if [[ -f "/mnt/synology/tobetracked/mount_test.txt" ]]; then
        printf "ToBeTracked Synology is moutned.\n"
        printf "\tWe will now start transcoding and copying the videos in settings file ...\n\n"

        while IFS=',' read -r user \
    							video_name \
    							video_type \
    							fps \
    							start_time \
    							flies_per_arena \
    							sex_ratio \
    							number_of_arenas \
    							arena_shape \
    							assay_type \
    							optogenetics_light \
    							station;
        do
            # Check if video type has a period
            if [[ "${video_type}" == *.* ]]; then
                video_type="${video_type:1}"
            fi
            # Check if file has extension
            if [[ "${video_name}" != *.* ]]; then
                video_name="${video_name}.${video_type}"
            fi

            if [[ "${video_type}" == "mkv" ]]; then
                # --------------------------------------------------------------------------------------------------------------------------------------------------------------
                ### need to convert Strand-Camera mkv files to constant frame rate videos
                ffmpeg \
                    -hide_banner \
                    -hwaccel cuda \
                    -hwaccel_output_format cuda \
                    -extra_hw_frames 4 \
                    -ss "${start_time}.000" \
                    -i "${full_path}/${video_name}" \
                    -t "${ff_t_stop}.000" \
                    -filter:v fps="${fps}" \
                    -c:v h264_nvenc \
                    -tune ull \
                    -rc cbr \
                    -preset p7 \
                    -multipass 1 \
                    -y \
                    "${full_path}/${video_name: -4}.mp4"
                # --------------------------------------------------------------------------------------------------------------------------------------------------------------

                # Check that destination directory and video list file exits
                if [[ ! -d "${tobetracked_vid_dir}" ]]; then
                    mkdir -p "${tobetracked_vid_dir}"
                fi
                if [[ ! -f "${tobetracked_list_file}" ]]; then
                    touch "${tobetracked_list_file}"
                fi

                # Transfer video and append info to list file
                transfer_function "${video_name: -4}.mp4" ${full_path} "${tobetracked_vid_dir}"
                printf "${user},${video_name: -4}.mp4,${video_type},${fps},${start_time},${flies_per_arena},${sex_ratio},${number_of_arenas},${arena_shape},${assay_type},${optogenetics_light},${station}\n" \
                    >> "${tobetracked_list_file}"
            fi
        done < "${full_path}/${settings_file}"
    else
        printf "The Synology is not mounted.\n...\n\t... go find Aaron ...\n\n"
        sleep infinity
    fi
else
    printf "\nStill can't find your local recording folder ...\n"
    printf "Probably best to find Aaron or Annika ...\n\n"
    sleep infinity
fi
